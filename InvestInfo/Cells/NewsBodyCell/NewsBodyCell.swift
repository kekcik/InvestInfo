//
//  NewsBodyCell.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import UIKit

struct NewsBodyCellVM: CommonCellVM {
    let classId = "NewsBodyCell"
    
    let body: String
}

class NewsBodyCell: CommonCell {

    @IBOutlet private var bodyLabel: UILabel!
    
    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? NewsBodyCellVM else { return }
        bodyLabel.text = vm.body
    }
}
