//
//  TitleImageCell.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import UIKit

struct TitleImageCellVM: CommonCellVM {
    let classId = "TitleImageCell"
    let imageUrl: String
}

class TitleImageCell: CommonCell {

    @IBOutlet weak var mainImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImageView.kf.cancelDownloadTask() // first, cancel currenct download task
        mainImageView.kf.setImage(with: URL(string: "")) // second, prevent kingfisher from setting previous image
        mainImageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainImageView.layer.cornerRadius = 15
    }
    
    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? TitleImageCellVM else { return }
        
        if let url = URL(string: "\(Constants.baseHost)/images/\(vm.imageUrl)") {
            mainImageView.kf.indicatorType = .activity
            DispatchQueue.main.async {
                self.mainImageView.kf.setImage(with: url)
            }
        }
    }
}
