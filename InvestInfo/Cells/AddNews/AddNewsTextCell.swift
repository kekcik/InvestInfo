import UIKit

struct AddNewsTextCellVM: CommonCellVM, NameableCellVM, HeightableCellVM {
    let classId = String(describing: AddNewsTextCell.self)
    let cellName: CommonCellNameProtocol
    let height: CGFloat? = 216
}

final class AddNewsTextCell: CommonCell, CommonCellOutProtocol {
    weak var parentViewController: UIViewController?
    private let textView = UITextView()
    private let placeholder = "Добавь основной текст новости"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        textView.delegate = self
        textView.autocorrectionType = .no
        textView.backgroundColor = .secondarySystemBackground
        textView.text = placeholder
        textView.textColor = .secondaryLabel
        textView.font = .preferredFont(forTextStyle: .body)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.rounded()
        contentView.addManualResizing(textView)
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 44.0)))
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(tapDone))
        toolBar.setItems([spaceButton, doneButton], animated: false)
        textView.inputAccessoryView = toolBar
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(with vm: CommonCellVM) {}
}

// MARK: - UITextViewDelegate
extension AddNewsTextCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text == placeholder ? nil : textView.text
        (parentViewController as? AddNewsInputProtocol)?.setNews(text: text)
    }
}

// MARK: - Helper
private extension AddNewsTextCell {
    @objc func tapDone() {
        textView.resignFirstResponder()
    }
}
