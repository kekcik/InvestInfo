//
//  CommonCellVM.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import UIKit

protocol CommonCellVM {
    var classId: String { get }
}

protocol NameableCellVM {
    var cellName: CommonCellNameProtocol { get }
}

protocol HeightableCellVM {
    var height: CGFloat? { get }
}
