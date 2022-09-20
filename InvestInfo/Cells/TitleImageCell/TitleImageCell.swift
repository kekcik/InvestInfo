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
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImageView.kf.cancelDownloadTask() // first, cancel currenct download task
        mainImageView.kf.setImage(with: URL(string: "")) // second, prevent kingfisher from setting previous image
        mainImageView.image = nil
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? TitleImageCellVM else { return }
        
        if let url = URL(string: "\(Constants.baseHost)\(vm.imageUrl)") {
            mainImageView.kf.indicatorType = .activity
            DispatchQueue.main.async {
                self.mainImageView.kf.setImage(with: url) { result in
                    switch result {
                    case .success(let data):
                        
                        let prop = data.image.size.width / data.image.size.height
                        let newHeight = CGFloat(Int((UIScreen.main.bounds.width) / prop))
                        self.imageHeight.constant = newHeight
                        
                        print(data.image.size.width, data.image.size.height, prop, newHeight)
                    default: break
                    }
                }
            }
        }
    }
    
}
