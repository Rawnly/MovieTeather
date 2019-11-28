//
//  MoviesVC.swift
//  Movie Theater
//
//  Created by Federico Vitale on 28/11/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class MoviesVC: UICollectionViewController {
    typealias DataSourceType = UICollectionViewDiffableDataSource<Section<Header, [Movie]>, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section<Header, [Movie]>, Movie>
    typealias Pagination = (page: Int, totalPages: Int)
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let client: TMDBApi = TMDBApi("1a8d1689f01251ca6ee058b29622441e")
    private var isFetching: Bool = false
    private var pagination: Pagination = (page: 1, totalPages: 0) {
        willSet {
            if pagination.page != newValue.page {
                let haptic = UIImpactFeedbackGenerator(style: .soft)
                haptic.impactOccurred()
                
                DispatchQueue.main.async {
                    if let query = self.searchController.searchBar.text, query.isEmpty == false {
                        self.fetchMovies(query: query)
                    } else {
                        self.fetchMovies()
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.label.text = "\(self.pagination.page) of \(self.pagination.totalPages)"
            }
        }
    }
    
    lazy var container: UIView = {
        let container = UIView()

        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        container.addParallaxEffect()
        container.addShadow()
        
        return container
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 14)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .darkGray
        label.text = "\(pagination.page) of \(pagination.totalPages)"
       
        return label
    }()
    
    struct Header: Hashable {
        let title: String
    }
    
    struct Section<U: Hashable, T: Hashable>: Hashable {
        let headerItem: U
        let items: T
    }
    
    struct DataSource<T> {
        let sections: [T]
    }
    
    
    // DataSource
    private var currentSnapshot: Snapshot?
    private var dataSource: DataSourceType!
    
    private var pinnedMovies: [Movie] = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        isModalInPresentation = true
        navigationController?.topViewController?.isModalInPresentation = true
        navigationController?.presentationController?.delegate = self
        
        collectionView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.autocorrectionType = .yes
        searchController.searchBar.keyboardType = .alphabet
        searchController.searchBar.returnKeyType = .search
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Background Color
        collectionView.backgroundColor = .secondarySystemGroupedBackground
        view.backgroundColor = collectionView.backgroundColor
        
        // NavigationController Stuff
        title = "Popular Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // DataSource
        collectionView.dataSource = dataSource
        
        // Register Stuff to UICollectionView
        MovieCell.register(to: collectionView)
        
        collectionView.register(
            MoviesHeader.self,
            forSupplementaryViewOfKind: Costants.moviesHeaderElementKind,
            withReuseIdentifier: Costants.moviesHeaderReuseIdentifier
        )
        
        // Buttons
        navigationItem.rightBarButtonItem = {
            let image = UIImage(systemName: "arrow.right")
            let b = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(self.nextPage)
            );
            
            b.accessibilityIdentifier = "NextPage"
            b.tintColor = navigationController?.navigationBar.tintColor
            
            return b;
        }()
        
        navigationItem.leftBarButtonItem = {
            let image = UIImage(systemName: "arrow.left")
            let b = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(self.prevPage)
            );
            
            b.isEnabled = pagination.page > 1
            b.accessibilityIdentifier = "PrevPage"
            b.tintColor = navigationController?.navigationBar.tintColor
            
            return b;
        }()

        let swipeBackward = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeBackward))
        swipeBackward.direction = .right
        swipeBackward.numberOfTouchesRequired = 1
        
        
        let swipeForward = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeForward))
        swipeForward.direction = .left
        swipeForward.numberOfTouchesRequired = 1
                
        collectionView.addGestureRecognizer(swipeForward)
        collectionView.addGestureRecognizer(swipeBackward)
        
        // DataSource Configuration
        configureDataSource()
        
        setupPageStepper()
        
        // Fetch Movies
        fetchMovies()
    }
    
    func setupPageStepper() {
        label
            .addToView(container)
            .fillSuperView()
        
        container
            .addToView(view)
            .centerInSuperView(axis: .x)
            .setConstraints([
                container.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2.25),
                container.heightAnchor.constraint(equalToConstant: 35),
                container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
            ])
        
        container.bringSubviewToFront(label)
        view.bringSubviewToFront(container)
    }
    
    @objc
    func nextPage() {
        if !isFetching && pagination.page < pagination.totalPages {
            pagination.page += 1
        }
    }
    
    @objc
    func prevPage() {
        if pagination.page > 1 && !isFetching {
            pagination.page -= 1
        }
    }
    
    @objc
    func onSwipeBackward(_ gesture: UISwipeGestureRecognizer) {
        prevPage()
    }
    
    @objc
    func onSwipeForward(_ gesture: UISwipeGestureRecognizer) {
        nextPage()
    }
}

extension MoviesVC {
    func makeContextMenu(_ movie: Movie) -> UIMenu {
        var pin = UIAction(title: "Pin Movie", image: UIImage(systemName: "pin")) { (action) in
            self.pinnedMovies.append(movie)
            self.fetchMovies()
        }
        
        if let pinnedIndex = pinnedMovies.firstIndex(of: movie) {
            pin = UIAction(title: "UnPin", image: UIImage(systemName: "pin.fill"), attributes: .destructive, handler: { (_) in
                self.pinnedMovies.remove(at: pinnedIndex)
                self.fetchMovies()
            })
        }

        // Create a UIAction for sharing
        let share = UIAction(title: "Share Movie", image: UIImage(systemName: "square.and.arrow.up")) { action in
            // Show system share sheet
            print("Shared")
        }

        // Create and return a UIMenu with the share action
        return UIMenu(title: movie.title, children: [share, pin])
    }
}

extension MoviesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let query = searchController.searchBar.text, !query.isEmpty {
            fetchMovies(query: query)
        } else {
            fetchMovies()
        }
    }
}

extension MoviesVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        searchController.searchBar.becomeFirstResponder()
    }
}

extension MoviesVC {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -300 && !searchController.searchBar.isFirstResponder {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.makeContextMenu(self.dataSource.itemIdentifier(for: indexPath)!)
        })
    }
}

extension MoviesVC {
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, movie) -> UICollectionViewCell? in
            let cell = MovieCell.dequeque(from: collectionView, at: indexPath) as! MovieCell
            
            cell.movie = movie
            
            return cell
        })
                
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            if kind == Costants.moviesHeaderElementKind {
                if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Costants.moviesHeaderReuseIdentifier, for: indexPath) as? MoviesHeader {
                    
                    if let section = self?.currentSnapshot?.sectionIdentifiers[indexPath.section] {
                        header.label.text = section.headerItem.title
                    } else {
                        header.label.text = "Section: \(indexPath.section)"
                    }
                    
                    return header
                }
            }
            
            fatalError("failed to load")
        }
    }
    
    func fetchMovies(query: String? = nil) {
        var response: PagedResponse?
        isFetching = true
        
        DispatchQueue.global(qos: .background).async {
            if let query = query {
                response = self.client.get(.searchMovie(query: query), page: self.pagination.page)
            } else {
                response = self.client.get(.popularMovies, page: self.pagination.page)
            }

            guard response != nil else {
               self.isFetching = false
               return
            }
            
            self.isFetching = false
            self.pagination.totalPages = response!.totalPages
           
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem?.isEnabled = response!.page > 1
                self.navigationItem.rightBarButtonItem?.isEnabled = response!.page < response!.totalPages
                
                self.handle(response!.results)
            }
        }
    }
    
    func handle(_ movies: [Movie]) {
        var sectionItems = [Section<Header, [Movie]>]()
        let titles: [String] = ["Pinned", "GoodMovies (Over 7.5)", "Decent Movies (Between 7.5 and 5.0)", "Bad Movies (Under 5.0)"]
        let splittedArray = [
            pinnedMovies,
            movies.filter({ $0.voteAverage > 7.5 && pinnedMovies.firstIndex(of: $0) == nil }).sorted(by: { $0.voteAverage > $1.voteAverage }),
            movies.filter({ $0.voteAverage < 7.5 && $0.voteAverage > 5.0 && pinnedMovies.firstIndex(of: $0) == nil }).sorted(by: { $0.voteAverage > $1.voteAverage }),
            movies.filter({ $0.voteAverage < 5.0 && pinnedMovies.firstIndex(of: $0) == nil  }).sorted(by: { $0.voteAverage > $1.voteAverage })
        ]
        
        for (title, movies) in zip(titles, splittedArray) {
            sectionItems.append(.init(headerItem: Header(title: title), items: movies))
        }
        
        let payload = DataSource(sections: sectionItems)
        
        var snapshot = NSDiffableDataSourceSnapshot<Section<Header, [Movie]>, Movie>()
        
        payload.sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        self.currentSnapshot = snapshot
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
