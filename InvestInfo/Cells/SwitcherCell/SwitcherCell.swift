import UIKit

protocol SwitcherProtocol: AnyObject {
    func switcherChange(state: Bool, name: CommonCellNameProtocol)
}

struct SwitcherCellVM: CommonCellVM {
    let classId = "SwitcherCell"
    let cellName: CommonCellNameProtocol
    let text: String
    var isOn: Bool
}

final class SwitcherCell: CommonCell, CommonCellOutProtocol {
    weak var parentViewController: UIViewController?
    private var cellName: CommonCellNameProtocol?
    private let stackView = UIStackView()
    private let nameLabel = UILabel()
    private let switcher = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        nameLabel.font = .systemFont(ofSize: 17)
        nameLabel.numberOfLines = 0
        switcher.addTarget(self, action: #selector(switcherChange(_:)), for: .valueChanged)
        [nameLabel, switcher].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        nameLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 16).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -16).isActive = true
        switcher.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? SwitcherCellVM else { return }
        cellName = vm.cellName
        nameLabel.text = vm.text
        switcher.isOn = vm.isOn
    }
    
    @objc func switcherChange(_ sender: UISwitch) {
        guard
            let parentViewController = parentViewController as? SwitcherProtocol,
            let cellName = cellName
        else { return }
        parentViewController.switcherChange(state: sender.isOn, name: cellName)
    }
}
