import UIKit
import UserNotifications

protocol PushNotificationsServiceProtocol {
    func updatePushNotifications(isEnable: Bool)
    func update(deviceToken: Data)
}

final class PushNotificationsService {
    static let shared: PushNotificationsServiceProtocol = PushNotificationsService()
    private init() {}
    private var settings: UNNotificationSettings?
    private var token: String?
    private var isEnable: Bool = SettingsDataSouce.shared.getValue(.pushNotifications)
}

extension PushNotificationsService: PushNotificationsServiceProtocol {
    func updatePushNotifications(isEnable: Bool) {
        self.isEnable = isEnable
        updateStatus()
    }
    
    func update(deviceToken: Data) {
        token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token ?? "noToken")")
        subscribeUpdatePushNotificationsStatus()
    }
}

// MARK: - Helper
private extension PushNotificationsService {
    func subscribeUpdatePushNotificationsStatus() {
        /// Сначала удаляем все подписки, потом подписываемся заново
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(
            self, selector: #selector(updateStatus),
            name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
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
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Внимание!",
                message: "Получение пуш уведомлений отключено.\nИзменить можно в настройках телефона",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
            alert.addAction(UIAlertAction(title: "Перейти", style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:])
            })
            
            let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
            
            guard var topController = keyWindow?.rootViewController else { return }
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true)
        }
    }
}
