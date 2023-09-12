//
//  LocalNotificationsManager.swift
//  Lantern
//

import Foundation
import UserNotifications

class UserNotificationsManager:NSObject,UNUserNotificationCenterDelegate {
    static let shared = UserNotificationsManager()

    private static let lastDataCapNotificationDefaultsKey = "Lantern.NotifyDataCapDate"
    let dataUsageUpdatedNotification = Notification.Name("Lantern.dataUsageUpdated")
    let center: UNUserNotificationCenter
    let userDefaults: UserDefaults
    // Check if user has alerady notification permssion or not
    var notificationsEnabled: Bool {
        get {
            var isAuthorized = false
            // This will ensure synchronous access to notification permission
            let semaphore = DispatchSemaphore(value: 0)
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                    isAuthorized = true
                }
                semaphore.signal()
            }
            // Waiting for the completion handler of getNotificationSettings to complete
            _ = semaphore.wait(timeout: .distantFuture)
            return isAuthorized
        }
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

    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
         center.getNotificationSettings { settings in
             switch settings.authorizationStatus {
             case .notDetermined:
                 self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                     DispatchQueue.main.async {
                         completion(granted)
                     }
                 }
             case .denied:
                 DispatchQueue.main.async {
                     completion(false)
                 }
             case .authorized, .provisional:
                 DispatchQueue.main.async {
                     completion(true)
                 }
             default:
                 DispatchQueue.main.async {
                     completion(false)
                 }
             }
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

    // Todo:- Implement generic way to support multiple lang
    // Same as Android
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
