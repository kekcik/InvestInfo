//
//  SpaceCell.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import UIKit

struct SpaceCellVM: CommonCellVM {
    
    let classId = "SpaceCell"

    let height: Int
}

class SpaceCell: CommonCell {

    @IBOutlet weak var spaceHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? SpaceCellVM else { return }
        
        spaceHeight.constant = CGFloat(vm.height)
    }
    
}
