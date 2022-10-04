import UIKit

struct AddNewsImageCellVM: CommonCellVM, NameableCellVM, HeightableCellVM {
    let classId = String(describing: AddNewsImageCell.self)
    let cellName: CommonCellNameProtocol
    let height: CGFloat? = 216
    let imageData: Data?
}

final class AddNewsImageCell: CommonCell, CommonCellOutProtocol {
    weak var parentViewController: UIViewController?
    private let newsImageButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        newsImageButton.addTarget(self, action: #selector(imageButtonTap), for: .touchUpInside)
        newsImageButton.rounded()
        contentView.addManualResizing(newsImageButton)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? AddNewsImageCellVM else { return }
        setImage(data: vm.imageData)
    }
}

// MARK: - Helper
private extension AddNewsImageCell {
    @objc func imageButtonTap() {
        (parentViewController as? AddNewsInputProtocol)?.editImage()
    }
    
    func setImage(data: Data?) {
        guard let data = data else {
            let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 150))
            let image = UIImage(systemName: "photo.fill", withConfiguration: config)
            newsImageButton.setImage(image, for: .normal)
            newsImageButton.backgroundColor = .lightGray
            newsImageButton.tintColor = .gray
            return
        }
        newsImageButton.setImage(UIImage(data: data), for: .normal)
        newsImageButton.tintColor = nil
        newsImageButton.backgroundColor = nil
    }
}
