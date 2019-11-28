//
//  UICollectionViewCell+Extension.swift
//  Movie Theater
//
//  Created by Federico Vitale on 28/11/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


extension UICollectionViewCell {
    static func register(to collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: "\(self)")
    }
    
    static func dequeque(from collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell? {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "\(self)", for: indexPath)
    }
}

