//
//  CommonCell.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import Foundation
import UIKit

protocol CommonCellOutProtocol where Self: UITableViewCell {
    var parentViewController: UIViewController? { get set }
}

protocol CommonCellNameProtocol {}

class CommonCell: UITableViewCell {
    func update(with: CommonCellVM) { }
}
