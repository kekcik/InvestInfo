//
//  NewsTitleCell.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import UIKit

struct NewsTitleCellVM: CommonCellVM {
    let classId = "NewsTitleCell"

    var title: String
    var date: Date
}

class NewsTitleCell: CommonCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? NewsTitleCellVM else { return }
        
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        
        titleLabel.text = vm.title
        dateLabel.text = df.string(from: vm.date)
    }
}
