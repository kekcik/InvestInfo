import UIKit

struct AddNewsTitleCellVM: CommonCellVM, NameableCellVM {
    let classId = String(describing: AddNewsTitleCell.self)
    let cellName: CommonCellNameProtocol
}

final class AddNewsTitleCell: CommonCell, CommonCellOutProtocol {
    weak var parentViewController: UIViewController?
    private let textField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        textField.delegate = self
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 22, weight: .semibold)
        textField.placeholder = "Добавь заголовок"
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.rounded()
        contentView.addManualResizing(textField)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(with vm: CommonCellVM) {}
}

// MARK: - UITextFieldDelegate
extension AddNewsTitleCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        (parentViewController as? AddNewsInputProtocol)?.setNews(title: textField.text)
    }
}
