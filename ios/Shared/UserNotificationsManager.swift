//
//  LocalNotificationsManager.swift
//  Lantern
//

import Foundation
import UserNotifications

// TODO: add interface for mockability
class UserNotificationsManager {
    static let permissionDefaultsKey = "Lantern.NotificationPermission"
    static let lastDataCapNotificationDefaultsKey = "Lantern.NotifyDataCapDate"

    let center: UNUserNotificationCenter
    let userDefaults: UserDefaults

    var notificationsEnabled: Bool {
        // this is an internal-only flag; may not accurately reflect system Settings
        get { return userDefaults.bool(forKey: UserNotificationsManager.permissionDefaultsKey) }
        set { userDefaults.set(newValue, forKey: UserNotificationsManager.permissionDefaultsKey) }
    }

    private var notifiedDataCapThisMonth: Bool {
        guard let value = userDefaults.value(forKey: UserNotificationsManager.lastDataCapNotificationDefaultsKey),
            let lastDate = (value as? Date) else { return false }
        return Calendar.current.isDate(lastDate, equalTo: Date(), toGranularity: .month)
    }

    // MARK: Init

    init(center: UNUserNotificationCenter = .current(),
         userDefaults: UserDefaults = Constants.appGroupDefaults) {
        self.center = center
        self.userDefaults = userDefaults
    }

    func setNotificationCenterDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        // used by app-side to allow notifications while app is active (see AppDelegate.swift)
        center.delegate = delegate
    }

    // MARK: Permissions

    func getSystemNotificationAuthorization(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { completion($0.authorizationStatus) }
    }

    func requestNotificationsPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.provisional, .alert]) { [weak self] allowed, error in
            self?.notificationsEnabled = allowed // + attempt to reflect system settings
            completion(allowed)
        }
    }

    // MARK: Posting

    func scheduleDataCapLocalNotification(withDataLimit limit: Int) {
        guard notificationsEnabled, !notifiedDataCapThisMonth else { return }

        let content = localizedNotificationContent(withDataLimit: limit)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "Lantern.DataCap",
                                            content: content,
                                            trigger: trigger)

        center.add(request) { [weak self] error in
            if error == nil {
                let key = UserNotificationsManager.lastDataCapNotificationDefaultsKey
                self?.userDefaults.set(Date(), forKey: key)
            }
        }
    }

    func localizedNotificationContent(withDataLimit limit: Int) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        let localeString = userDefaults.string(forKey: Constants.localeSharedDefaultsKey) ?? "en-US"
        // ^default to English, only other supported language right now

        // localizing "raw" to avoid adding Text.swift + strings files to netEx
        if localeString == "zh_CN" {
            content.title = "你已经超过每月\(limit)MB高速流量限制"
            content.body = "您能继续使用蓝灯，但会被限速。您的高速流量月初会重置。"
        } else {
            content.title = "You have hit your \(limit)MB monthly data cap."
            content.body = "You can continue to use Lantern, but speeds will be reduced. Your data cap will be reset at the beginning of the month."
        }
        return content
    }
}
