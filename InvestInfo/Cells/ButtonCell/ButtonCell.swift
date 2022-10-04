import UIKit

struct ButtonCellVM: CommonCellVM, NameableCellVM, HeightableCellVM {
    let classId = String(describing: ButtonCell.self)
    let cellName: CommonCellNameProtocol
    let height: CGFloat? = 60
    var text = ""
    var isEnable = false
}

protocol ButtonCellVCProtocol where Self: UIViewController {
    func primaryButtonTap()
}

final class ButtonCell: CommonCell, CommonCellOutProtocol {
    weak var parentViewController: UIViewController?
    private let mainButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        mainButton.rounded()
        mainButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        contentView.addManualResizing(mainButton, heightConstant: 44)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? ButtonCellVM else { return }
        mainButton.setTitle(vm.text, for: .normal)
        mainButton.isEnabled = vm.isEnable
        mainButton.backgroundColor = vm.isEnable ? .red : .gray
    }
    
    @objc private func buttonTap() {
        (parentViewController as? ButtonCellVCProtocol)?.primaryButtonTap()
    }
}
