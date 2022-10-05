import UIKit
import AVFoundation
import Photos

typealias AddImageServiceVC = UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate

protocol AddImageServiceProtocol {
    func showAddImage(isAvailable: Bool, from vc: AddImageServiceVC, removeCompletion: @escaping () -> Void)
}

final class AddImageService {
    private weak var viewController: AddImageServiceVC?
    private lazy var imagePicker: UIImagePickerController = UIImagePickerController()
    private let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
}

extension AddImageService: AddImageServiceProtocol {
    func showAddImage(isAvailable: Bool, from vc: AddImageServiceVC, removeCompletion: @escaping () -> Void) {
        viewController = vc
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
            if isAvailable {
                alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                    self?.showRemovingPhotoAlert(removeCompletion: removeCompletion)
                })
            }
            if alert.actions.isEmpty {
                self.showGoToSettingsAlert()
            } else {
                alert.addAction(self.cancelAction)
                vc.present(alert, animated: true)
            }
        }
    }
}

// MARK: - Helper
private extension AddImageService {
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
        imagePicker.delegate = viewController
        imagePicker.sourceType = sourceType
        if case .camera = sourceType {
            imagePicker.cameraDevice = .front
        }
        viewController?.present(imagePicker, animated: true)
    }
    
    func showRemovingPhotoAlert(removeCompletion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Удалить изображение?", message: nil, preferredStyle: .alert)
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
            removeCompletion()
        })
        viewController?.present(alert, animated: true)
    }
    
    func showGoToSettingsAlert() {
        let message = "Ранее, Вы запретили использовать камеру или Ваши фото. Для изменения нужно перейти в Настройки"
        let alert = UIAlertController(title: "Внимание!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Перейти", style: .default) { action in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url, options: [:])
        })
        alert.addAction(cancelAction)
        viewController?.present(alert, animated: true)
    }
}
