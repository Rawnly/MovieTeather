//
//  UITableViewCell+Extension.swift
//  Movie Theater
//
//  Created by Federico Vitale on 28/11/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    static func register(to tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: "\(self)")
    }
    
    static func dequeque(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: "\(self)", for: indexPath)
    }
}

