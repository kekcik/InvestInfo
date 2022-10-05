//
//  SettingsController.swift
//  InvestInfo
//
//  Created by Владимир Микищенко on 20.09.2022.
//

import UIKit

final class SettingsController: UITableViewController {
    private var vms: [CommonCellVM] = []
    private var settingsDataSource: SettingsDataProtocol = SettingsDataSouce.shared
    private lazy var addImageService: AddImageServiceProtocol = AddImageService()
    private var newUserName: String?
    private var isUserDetailsEditing = false {
        didSet {
            updateNavBar()
        }
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
        case .pushNotifications:    settingsDataSource.setValue(state, for: .pushNotifications)
        case .createNews:           settingsDataSource.setValue(state, for: .createNews)
        default: break
        }
    }
}

// MARK: - UserDetailsEditingProtocol
extension SettingsController: UserDetailsEditingProtocol {
    func editAvatar() {
        guard isUserDetailsEditing else { return }
        addImageService.showAddImage(isAvailable: settingsDataSource.getValue(.avatarAvailable), from: self) { [weak self] in
            self?.saveAvatar(nil)
        }
    }
    
    func editUserName() {
        guard isUserDetailsEditing else { return }
        let alert = UIAlertController(title: "Имя пользователя", message: "поможет в общении", preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.delegate = self
            textField.text = self?.settingsDataSource.getUserName()
        }
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self = self, let newUserName = self.newUserName else { return }
            self.settingsDataSource.setUserName(newUserName)
            self.reload()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension SettingsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newUserName = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        newUserName = textField.text
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
        vms = [
            UserDetailsCellVM(cellName: SettingsCellName(name: .userDetails),
                              avatarData: settingsDataSource.getAvatarData(),
                              userName: settingsDataSource.getUserName()),
            SpaceCellVM(height: 20),
            SwitcherCellVM(cellName: SettingsCellName(name: .pushNotifications),
                           text: "Push-уведомления",
                           isOn: settingsDataSource.getValue(.pushNotifications)),
            SpaceCellVM(height: 20),
            SwitcherCellVM(cellName: SettingsCellName(name: .createNews),
                           text: "Создание новостей",
                           isOn: settingsDataSource.getValue(.createNews))
        ]
    }
    
    func saveAvatar(_ data: Data?) {
        settingsDataSource.setValue(data != nil, for: .avatarAvailable)
        settingsDataSource.setAvatar(data: data)
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
