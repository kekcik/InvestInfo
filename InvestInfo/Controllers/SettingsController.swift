//
//  SettingsController.swift
//  InvestInfo
//
//  Created by Владимир Микищенко on 20.09.2022.
//

import UIKit

final class SettingsController: UITableViewController {
    private var vms: [CommonCellVM] = []
    private var settingsStorage: SettingsStorageProtocol = SettingsStorageService.shared
    private lazy var addImageService: AddImageServiceProtocol = AddImageService()
    private lazy var templateUserName: UserName = UserName()
    private enum UserNameTag: Int {
        case name, familyName
        var placeholder: String {
            switch self {
            case .name:         return "Имя"
            case .familyName:   return "Фамилия"
            }
        }
    }
    private var isUserDetailsEditing = false {
        didSet { updateNavBar() }
    }
    private enum CellName: String, Equatable { case noOne, userDetails, pushNotifications, createNews }
    private struct SettingsCellName: CommonCellNameProtocol { var name: CellName = .noOne }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        updateNavBar()
        tableView.separatorStyle = .none
        tableView.register(SwitcherCell.self, forCellReuseIdentifier: String(describing: SwitcherCell.self))
        tableView.register(UserDetailsCell.self, forCellReuseIdentifier: String(describing: UserDetailsCell.self))
        [ "SpaceCell" ].forEach {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
        updateData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = vms[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: vm.classId) as? CommonCell
        else { return UITableViewCell() }
        cell.update(with: vm)
        guard let cell = cell as? CommonCellOutProtocol else { return cell }
        cell.parentViewController = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vms.count
    }
}

// MARK: - SwitcherProtocol
extension SettingsController: SwitcherProtocol {
    func switcherChange(state: Bool, name: CommonCellNameProtocol) {
        guard let localName = (name as? SettingsCellName)?.name else { return }
        switch localName {
        case .pushNotifications:    settingsStorage.setValue(state, for: .pushNotifications)
        case .createNews:           settingsStorage.setValue(state, for: .createNews)
        default: break
        }
    }
}

// MARK: - UserDetailsEditingProtocol
extension SettingsController: UserDetailsEditingProtocol {
    func editAvatar() {
        guard isUserDetailsEditing else { return }
        addImageService.showAddImage(isAvailable: settingsStorage.getValue(.avatarAvailable), from: self) { [weak self] in
            self?.saveAvatar(nil)
        }
    }
    
    func editUserName() {
        guard isUserDetailsEditing else { return }
        let alert = UIAlertController(title: "Представьтесь", message: "это поможет в общении", preferredStyle: .alert)
        let userName = settingsStorage.getUserName()
        alert.addTextField { [weak self] textField in
            self?.setup(textField: textField, userName: userName, for: (alert.textFields?.count ?? 1) - 1)
        }
        alert.addTextField { [weak self] textField in
            self?.setup(textField: textField, userName: userName, for: (alert.textFields?.count ?? 1) - 1)
        }
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.settingsStorage.setUserName(self.templateUserName)
            self.reload()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension SettingsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        update(text: "", for: textField.tag)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            update(text: updatedText, for: textField.tag)
        }
        return true
    }
}

// MARK: - Helper
private extension SettingsController {
    func updateNavBar() {
        let item: UIBarButtonItem.SystemItem = isUserDetailsEditing ? .done : .edit
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: item, target: self, action: #selector(editButtonTap))
    }
    
    @objc func editButtonTap() {
        isUserDetailsEditing.toggle()
    }
    
    func updateData() {
        let userName = settingsStorage.getUserName()
        vms = [
            UserDetailsCellVM(cellName: SettingsCellName(name: .userDetails),
                              avatarData: settingsStorage.getAvatarData(),
                              userName: [userName.name ?? "", userName.familyName ?? ""].joined(separator: " ")),
            SpaceCellVM(height: 20),
            SwitcherCellVM(cellName: SettingsCellName(name: .pushNotifications),
                           text: "Push-уведомления",
                           isOn: settingsStorage.getValue(.pushNotifications)),
            SpaceCellVM(height: 20),
            SwitcherCellVM(cellName: SettingsCellName(name: .createNews),
                           text: "Создание новостей",
                           isOn: settingsStorage.getValue(.createNews))
        ]
    }
    
    func setup(textField: UITextField, userName: UserName, for tag: Int) {
        guard let userNameTag = UserNameTag(rawValue: tag) else { return }
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.tag = userNameTag.rawValue
        textField.placeholder = userNameTag.placeholder
        switch userNameTag {
        case .name:         textField.text = userName.name
        case .familyName:   textField.text = userName.familyName
        }
    }
    
    func update(text: String, for tag: Int) {
        guard let userNameTag = UserNameTag(rawValue: tag) else { return }
        switch userNameTag {
        case .name:         templateUserName.name = text.isEmpty ? nil : text
        case .familyName:   templateUserName.familyName = text.isEmpty ? nil : text
        }
    }
    
    func saveAvatar(_ data: Data?) {
        settingsStorage.setValue(data != nil, for: .avatarAvailable)
        settingsStorage.setAvatar(data: data)
        reload()
    }
    
    func reload() {
        updateData()
        tableView.reloadData()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension SettingsController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        saveAvatar((info[.originalImage] as? UIImage)?.getCroppedImage().pngData())
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
