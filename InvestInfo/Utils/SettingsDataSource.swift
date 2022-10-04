import Foundation

protocol SettingsDataProtocol {
    func getAvatarData() -> Data?
    func setAvatar(data: Data)
    func getUserName() -> String
    func setUserName(_ name: String)
    func getValue(_ settings: SettingsDataSouce.Settings) -> Bool
    func setValue(_ value: Bool, for settings: SettingsDataSouce.Settings)
}

final class SettingsDataSouce {
    static let shared: SettingsDataProtocol = SettingsDataSouce()
    private init() {}
    private let userDefaults = UserDefaults.standard
    private enum UserDetails: String, CaseIterable { case name, avatarData }
    enum Settings: String, CaseIterable { case avatarAvailable, pushNotifications, createNews }
    
    private var avatarData: Data? {
        get { userDefaults.value(forKey: UserDetails.avatarData.rawValue) as? Data }
        set { userDefaults.set(newValue, forKey: UserDetails.avatarData.rawValue) }
    }
    private var userName: String {
        get { userDefaults.value(forKey: UserDetails.name.rawValue) as? String ?? "Неизвестный пользователь" }
        set { userDefaults.set(newValue, forKey: UserDetails.name.rawValue) }
    }
    private var isAvatarAvailable: Bool {
        get { userDefaults.value(forKey: Settings.avatarAvailable.rawValue) as? Bool ?? false }
        set { userDefaults.set(newValue, forKey: Settings.avatarAvailable.rawValue) }
    }
    private var isOnPushNotifications: Bool {
        get { userDefaults.value(forKey: Settings.pushNotifications.rawValue) as? Bool ?? false }
        set { userDefaults.set(newValue, forKey: Settings.pushNotifications.rawValue) }
    }
    private var isOnCreateNews: Bool {
        get { userDefaults.value(forKey: Settings.createNews.rawValue) as? Bool ?? false }
        set { userDefaults.set(newValue, forKey: Settings.createNews.rawValue) }
    }
}

// MARK: - SettingsDataProtocol
extension SettingsDataSouce: SettingsDataProtocol {
    func getAvatarData() -> Data? {
        avatarData
    }
    
    func setAvatar(data: Data) {
        avatarData = data
    }
    func getUserName() -> String {
        userName
    }
    
    func setUserName(_ name: String) {
        userName = name
    }
    
    func getValue(_ settings: Settings) -> Bool {
        switch settings {
        case .avatarAvailable:      return isAvatarAvailable
        case .pushNotifications:    return isOnPushNotifications
        case .createNews:           return isOnCreateNews
        }
    }
    
    func setValue(_ value: Bool, for settings: Settings) {
        switch settings {
        case .avatarAvailable:      isAvatarAvailable = value
        case .pushNotifications:    isOnPushNotifications = value
        case .createNews:           isOnCreateNews = value
        }
    }
}
