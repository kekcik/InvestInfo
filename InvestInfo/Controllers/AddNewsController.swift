//
//  AddNewsController.swift
//  InvestInfo
//
//  Created by Владимир Микищенко on 29.09.2022.
//

import UIKit

protocol AddNewsInputProtocol {
    func editImage()
    func setNews(title: String?)
    func setNews(text: String?)
}

final class AddNewsController: UITableViewController {
    private enum CellName: String, Equatable { case noOne, image, title, text, button }
    private struct AddNewsCellName: CommonCellNameProtocol { var name: CellName = .noOne }
    private struct NewsTemplate {
        var imageData: Data? = nil
        var title: String? = nil
        var text: String? = nil
        var isSendAvailable: Bool {
            !(title?.isEmpty ?? true) && !(text?.isEmpty ?? true)
        }
    }
    private var newsTemplate = NewsTemplate() {
        didSet {
            guard newsTemplate.isSendAvailable else { return }
            reload()
        }
    }
    private lazy var addImageService: AddImageServiceProtocol = AddImageService()
    private lazy var vms: [CommonCellVM] = updateDataModels()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SpaceCell", bundle: nil), forCellReuseIdentifier: "SpaceCell")
        tableView.register(AddNewsImageCell.self, forCellReuseIdentifier: String(describing: AddNewsImageCell.self))
        tableView.register(AddNewsTitleCell.self, forCellReuseIdentifier: String(describing: AddNewsTitleCell.self))
        tableView.register(AddNewsTextCell.self, forCellReuseIdentifier: String(describing: AddNewsTextCell.self))
        tableView.register(ButtonCell.self, forCellReuseIdentifier: String(describing: ButtonCell.self))
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        (vms[indexPath.row] as? HeightableCellVM)?.height ?? UITableView.automaticDimension
    }
}

// MARK: - AddNewsInputProtocol
extension AddNewsController: AddNewsInputProtocol {
    func editImage() {
        addImageService.showAddImage(isAvailable: newsTemplate.imageData != nil, from: self) { [weak self] in
            self?.saveImage(data: nil)
        }
    }
    
    func setNews(title: String?) {
        newsTemplate.title = title
    }
    
    func setNews(text: String?) {
        newsTemplate.text = text
    }
}

// MARK: - ButtonCellVCProtocol
extension AddNewsController: ButtonCellVCProtocol {
    func primaryButtonTap() {
        guard newsTemplate.isSendAvailable else { return }
        print(#function)
        //TODO: Готовы отправить новость на модерацию
        showDidSendAlert()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AddNewsController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage, let data = image.getCroppedImage().pngData() {
            saveImage(data: data)
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - Helper
private extension AddNewsController {
    func updateDataModels() -> [CommonCellVM] {
        [
            SpaceCellVM(height: 20),
            AddNewsImageCellVM(cellName: AddNewsCellName(name: .image), imageData: newsTemplate.imageData),
            SpaceCellVM(height: 10),
            AddNewsTitleCellVM(cellName: AddNewsCellName(name: .title)),
            SpaceCellVM(height: 10),
            AddNewsTextCellVM(cellName: AddNewsCellName(name: .text)),
            SpaceCellVM(height: 10),
            ButtonCellVM(cellName: AddNewsCellName(name: .button), text: "Отправить", isEnable: newsTemplate.isSendAvailable)
        ]
    }
    
    func saveImage(data: Data?) {
        newsTemplate.imageData = data
        reload()
    }
    
    func reload() {
        vms = updateDataModels()
        tableView.reloadData()
    }
    
    func showDidSendAlert() {
        let alert = UIAlertController(title: "Поздравляем!", message: "новость успешно отправлена на модерацию", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default) { [weak self] _ in self?.dismiss(animated: true) })
        present(alert, animated: true)
    }
}
