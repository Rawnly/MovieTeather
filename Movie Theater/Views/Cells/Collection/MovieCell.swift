//
//  MovieCell.swift
//  Movie Theater
//
//  Created by Federico Vitale on 28/11/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class MovieCell: UICollectionViewCell {
    var movie: Movie? {
        didSet {
            guard let movie = movie else { return }
            
            title.text = movie.title
            descr.text = movie.description
            fullDescr.text = movie.description
            
            if let url = URL(string: "https://image.tmdb.org/t/p/w500\(movie.backdrop ?? movie.poster)") {
                previewImage.kf.setImage(
                   with: url,
                   options: [
                        .backgroundDecode,
                       .transition(.fade(0.25)),
                       .cacheMemoryOnly,
                       .progressiveJPEG(.default),
                       .scaleFactor(UIScreen.main.scale)
                   ],
                   completionHandler: { result in
                       switch result {
                       case .success(_):
                           self.setupTitle()
                           self.setupDescription()
                           break
                       case .failure(let error):
                           print(error.errorCode, error.errorDescription ?? "")
                           break
                       }
                   }
               )
            }
        }
    }
    
    private var titleTopAnchor: NSLayoutConstraint?
    private var titleTopAnchorWithDescr: NSLayoutConstraint?

    private var previewImage:UIImageView = UIImageView()
    private var title:UILabel = UILabel()
    private var descr:UILabel = UILabel()
    private var fullDescr:UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    
    /*
     * -----------------------
     * MARK: - UI
     * ------------------------
     */
    
    private func setupUI() {
        layer.cornerRadius = 5
        layer.masksToBounds = false
        
        contentView.layer.cornerRadius = layer.cornerRadius
        contentView.layer.masksToBounds = true
        
        layoutIfNeeded()

        layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 5
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.contentsScale = UIScreen.main.scale
        
        setupPreviewImage()
        setupOverlay()
    }
    
    private func setupPreviewImage() {
        contentView.addSubview(previewImage)
        
        previewImage.backgroundColor = .darkGray
        previewImage.contentMode = .scaleAspectFill
        previewImage.layer.masksToBounds = true
        
        previewImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            previewImage.topAnchor.constraint(equalTo: self.topAnchor),
            previewImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            previewImage.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func setupOverlay() {
        let view = UIView(frame: .zero)
        
        view.alpha = 0.5
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: previewImage.topAnchor),
            view.bottomAnchor.constraint(equalTo: previewImage.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: previewImage.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: previewImage.leadingAnchor)
        ])
    }
    
    
    private func setupTitle(hasDescr: Bool = false) {
        contentView.addSubview(title)
        contentView.bringSubviewToFront(title)
        
        titleTopAnchor = title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        titleTopAnchorWithDescr = title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -55)
        
        title.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        title.text = title.text?.capitalized
        title.numberOfLines = 1
        title.textColor = .white
        
        title.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo:  self.leadingAnchor, constant: 15),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -55)
        ])
    }
    
    private func setupDescription() {
        contentView.addSubview(descr)
        contentView.bringSubviewToFront(descr)
        
        descr.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descr.numberOfLines = 2
        descr.textColor = .white
        
        descr.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descr.leadingAnchor.constraint(equalTo:  title.leadingAnchor),
            descr.topAnchor.constraint(equalTo:   title.bottomAnchor, constant: 5),
            descr.trailingAnchor.constraint(equalTo: title.trailingAnchor, constant: -15),
        ])
    }
    
    private func setupFullDescr() {
        fullDescr.hide()
        
        contentView.addSubview(fullDescr)
        contentView.bringSubviewToFront(fullDescr)
        
        fullDescr.font = .systemFont(ofSize: 16, weight: .regular)
        fullDescr.numberOfLines = 0
        fullDescr.textColor = .white
        fullDescr.textAlignment = .natural
        
        fullDescr.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fullDescr.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            fullDescr.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            fullDescr.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        ])
    }
}
