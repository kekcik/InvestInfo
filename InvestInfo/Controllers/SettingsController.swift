//
//  SettingsController.swift
//  InvestInfo
//
//  Created by Владимир Микищенко on 20.09.2022.
//

import UIKit
import AVFoundation
import Photos

final class SettingsController: UITableViewController {
    private var vms: [CommonCellVM] = []
    private var settingsDataSource: SettingsDataProtocol = SettingsDataSouce()
    private lazy var imagePicker: UIImagePickerController = { UIImagePickerController() }()
    private var newUserName: String?
    private let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
    private var isUserDetailsEditing = false {
        didSet {
            let item: UIBarButtonItem.SystemItem = isUserDetailsEditing ? .done : .edit
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: item, target: self, action: #selector(editButtonTap))
        }
    }
    
    private enum CellName: String, Equatable { case noOne, userDetails, pushNotifications, createNews }
    private struct SettingsCellName: CommonCellNameProtocol { var name: CellName = .noOne }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        setupNavBar()
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
        case .pushNotifications:
            settingsDataSource.setValue(state, for: .pushNotifications)
        case .createNews:
            settingsDataSource.setValue(state, for: .createNews)
            checkCameraAndPhotoLibraryPermitions {}
        default: break
        }
    }
}

// MARK: - UserDetailsEditingProtocol
extension SettingsController: UserDetailsEditingProtocol {
    func editAvatar() {
        guard isUserDetailsEditing else { return }
        checkCameraAndPhotoLibraryPermitions { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.camera), case .authorized = AVCaptureDevice.authorizationStatus(for: .video) {
                alert.addAction(UIAlertAction(title: "Сделать фото", style: .default) { [weak self] _ in
                    self?.showImagePicker(sourceType: .camera)
                })
            }
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary), case .authorized = PHPhotoLibrary.authorizationStatus() {
                alert.addAction(UIAlertAction(title: "Выбрать из Ваших фото", style: .default) { [weak self] _ in
                    self?.showImagePicker(sourceType: .photoLibrary)
                })
            }
            if self.settingsDataSource.getValue(.avatarAvailable) {
                alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                    self?.showRemovingPhotoAlert()
                })
            }
            if alert.actions.isEmpty {
                self.showGoToSettingsAlert()
            } else {
                alert.addAction(self.cancelAction)
                self.present(alert, animated: true)
            }
        }
    }
    
    func editUserName() {
        guard isUserDetailsEditing else { return }
        let alert = UIAlertController(title: "Имя пользователя", message: "поможет в общении", preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.delegate = self
            textField.text = self?.settingsDataSource.getUserName()
        }
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self = self, let newUserName = self.newUserName else { return }
            self.settingsDataSource.setUserName(newUserName)
            self.updateData()
            self.tableView.reloadData()
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
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTap))
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
    
    func checkCameraAndPhotoLibraryPermitions(completion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { _ in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        if case .camera = sourceType {
            imagePicker.cameraDevice = .front
        }
        present(imagePicker, animated: true)
    }
    
    func showRemovingPhotoAlert() {
        let alert = UIAlertController(title: "Удалить аватар?", message: nil, preferredStyle: .alert)
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.saveAvatar(Data())
        })
        present(alert, animated: true)
    }
    
    func getCroppedImage(sourceImage: UIImage?) -> UIImage? {
        guard let image = sourceImage else { return nil }
        let newSize = CGSize(width: 100, height: 100)
        let newImage = image.resizedImageWithinRect(rectSize: newSize)
        return newImage.getSquaredImage(sourceImage: newImage)
    }
    
    func saveAvatar(_ data: Data) {
        settingsDataSource.setValue(data != Data(), for: .avatarAvailable)
        settingsDataSource.setAvatar(data: data)
        self.updateData()
        self.tableView.reloadData()
    }
    
    func showGoToSettingsAlert() {
        let message = "Ранее, Вы запретили использовать камеру или Ваши фото. Для изменения нужно перейти в Настройки"
        let alert = UIAlertController(title: "Внимание!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Перейти", style: .default) { action in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url, options: [:])
        })
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension SettingsController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage, let data = getCroppedImage(sourceImage: image)?.pngData() {
            saveAvatar(data)
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
