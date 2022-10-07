//
//  NewsCell.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import UIKit
import Kingfisher

struct NewsCellVM: CommonCellVM {
    let classId = "NewsCell"
    
    let title: String
    let date: Date
    let body: String
    
    var imageUrl: String? = nil
    
    init(with dto: NewsDTO) {
        title = dto.title
        date = Date(timeIntervalSince1970: TimeInterval(dto.date))
        body = dto.body
        imageUrl = dto.imageURL
    }
}

class NewsCell: CommonCell {

    //MARK:- Events
       override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           super.touchesBegan(touches, with: event)
           animate(isHighlighted: true)
       }

       override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           super.touchesEnded(touches, with: event)
           animate(isHighlighted: false)
       }

       override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
           super.touchesCancelled(touches, with: event)
           animate(isHighlighted: false)
       }

       //MARK:- Private functions
       private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)?=nil) {
           let animationOptions: UIView.AnimationOptions = [.allowUserInteraction]
           if isHighlighted {
               UIView.animate(withDuration: 0.5,
                              delay: 0,
                              usingSpringWithDamping: 1,
                              initialSpringVelocity: 0,
                              options: animationOptions, animations: {
                               self.transform = .init(scaleX: 0.96, y: 0.96)
               }, completion: completion)
           } else {
               UIView.animate(withDuration: 0.5,
                              delay: 0,
                              usingSpringWithDamping: 1,
                              initialSpringVelocity: 0,
                              options: animationOptions, animations: {
                               self.transform = .identity
               }, completion: completion)
           }
       }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.layer.cornerRadius = 20
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImageView.kf.cancelDownloadTask() // first, cancel currenct download task
        mainImageView.kf.setImage(with: URL(string: "")) // second, prevent kingfisher from setting previous image
        mainImageView.image = nil
    }

    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? NewsCellVM else { return }
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        
        titleLabel.text = vm.title
        bodyLabel.text = vm.body
        dateLabel.text = df.string(from: vm.date)
        
        if let imageUrl = vm.imageUrl, let url = URL(string: "\(Constants.baseHost)/images/\(imageUrl)") {
            mainImageView.kf.indicatorType = .activity
            DispatchQueue.main.async {
                self.mainImageView.kf.setImage(with: url) { result in
                    switch result {
                    case .success(let data):
                        
                        let prop = data.image.size.width / data.image.size.height
                        let newHeight = CGFloat(Int((UIScreen.main.bounds.width - 32) / prop))
                        self.imageHeight.constant = newHeight
                        
                        print(data.image.size.width, data.image.size.height, prop, newHeight)
                    default: break
                    }
                }
            }
        } else {
            imageHeight.constant = 0
        }
    }
    
}
