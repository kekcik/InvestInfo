import UIKit
import SwiftUI

protocol UserDetailsEditingProtocol {
    func editAvatar()
    func editUserName()
}

struct UserDetailsCellVM: CommonCellVM {
    let classId = String(describing: UserDetailsCell.self)
    let cellName: CommonCellNameProtocol
    let avatarData: Data?
    let userName: String
}

final class UserDetailsCell: CommonCell, CommonCellOutProtocol {
    weak var parentViewController: UIViewController?
    private var cellName: CommonCellNameProtocol?
    private let stackView = UIStackView()
    private let avatarButton = UIButton()
    private let nameButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        avatarButton.tintColor = .gray
        avatarButton.addTarget(self, action: #selector(avatarEdit), for: .touchUpInside)
        nameButton.addTarget(self, action: #selector(nameEdit), for: .touchUpInside)
        nameButton.setTitleColor(.black, for: .normal)
        nameButton.contentHorizontalAlignment = .left
        [ avatarButton, nameButton ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        avatarButton.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 16).isActive = true
        avatarButton.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -16).isActive = true
        avatarButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        avatarButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let avatarView = avatarButton.imageView else { return }
        avatarView.layer.cornerRadius = avatarView.frame.height / 2
        avatarView.clipsToBounds = true
    }
    
    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? UserDetailsCellVM else { return }
        cellName = vm.cellName
        let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 50))
        let defaultAvatar = UIImage(systemName: "person.crop.circle", withConfiguration: config)
        let image = UIImage(data: vm.avatarData ?? Data()) ?? defaultAvatar
        avatarButton.setImage(image, for: .normal)
        nameButton.setTitle(vm.userName, for: .normal)
    }
}

// MARK: - Helper
private extension UserDetailsCell {
    @objc func avatarEdit() {
        (parentViewController as? UserDetailsEditingProtocol)?.editAvatar()
    }
    
    @objc func nameEdit() {
        (parentViewController as? UserDetailsEditingProtocol)?.editUserName()
    }
}
