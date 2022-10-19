import UIKit
import UserNotifications

protocol PushNotificationsServiceProtocol {
    func updatePushNotifications()
    func update(deviceToken: Data)
}

final class PushNotificationsService {
    static let shared: PushNotificationsServiceProtocol = PushNotificationsService()
    private init() {}
    private var settings: UNNotificationSettings?
    private var token: String?
    private var isEnable: Bool { SettingsStorageService.shared.getValue(.pushNotifications) }
    private var isShowSettingsAlertOnlyOnes = true
}

extension PushNotificationsService: PushNotificationsServiceProtocol {
    func updatePushNotifications() {
        updateStatus()
    }
    
    func update(deviceToken: Data) {
        token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token ?? "noToken")")
    }
}

// MARK: - Helper
private extension PushNotificationsService {
    @objc func updateStatus() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            [weak self] granted, error in
            print("PushNotifications permission granted: \(granted)")
            guard let self = self else { return }
            guard self.isEnable else {
                self.unregisterPushNotification()
                return
            }
            granted ? self.getNotificationsSettings() : self.showGoToSettingsAlert()
        }
    }
    
    func getNotificationsSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            self.settings = settings
            DispatchQueue.main.async {
                guard settings.authorizationStatus == .authorized else { return }
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func unregisterPushNotification() {
        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    func showGoToSettingsAlert() {
        guard isShowSettingsAlertOnlyOnes else {
            showWarning()
            return
        }
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Внимание!",
                message: "Получение пуш уведомлений отключено.\nИзменить можно в настройках телефона",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
            alert.addAction(UIAlertAction(title: "Перейти", style: .default) { [weak self] _ in
                guard let self = self, let url = URL(string: UIApplication.openSettingsURLString) else { return }
                self.subscribeUpdatePushNotificationsStatus()
                self.isShowSettingsAlertOnlyOnes = false
                UIApplication.shared.open(url, options: [:])
            })
            self?.getCurrentController()?.present(alert, animated: true)
        }
    }
    
    func subscribeUpdatePushNotificationsStatus() {
        /// Сначала удаляем все подписки, потом подписываемся заново
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(
            self, selector: #selector(updateStatus),
            name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func showWarning() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Внимание!",
                message: "В настройках телефона, для нашего приложения, выключены пуш уведомления",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .cancel))
            self?.getCurrentController()?.present(alert, animated: true)
        }
    }
    
    func getCurrentController() -> UIViewController? {
        guard var topController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController
        else { return nil }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}
