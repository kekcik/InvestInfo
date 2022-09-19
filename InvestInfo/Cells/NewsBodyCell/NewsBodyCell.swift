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

    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? NewsBodyCellVM else { return }
        
        
    }
    
}
