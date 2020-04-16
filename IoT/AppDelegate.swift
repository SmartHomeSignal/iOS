//
//  AppDelegate.swift
//  IoT
//
//  Created by Дамир Зарипов on 12.04.2020.
//  Copyright © 2020 itisIOSLab. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var tokenID: String = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: {_, _ in })

        application.registerForRemoteNotifications()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    // MARK: - Instance Methods
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let dataDict: [String: String] = ["token": fcmToken]
        print("fcmtoken \(fcmToken)")
        let url_send_token: URLConvertible = "http://45.15.253.128:8090/api/tokens/\(fcmToken)"
        AF.request(url_send_token, method: .post).responseString { response in
            guard let statusCode = response.response?.statusCode else {
                return
            }
            
            switch statusCode {
            case 200...204:
                print("Запрос отправлен успешно")
            default:
                print("StatudCode: \(statusCode)")
            }
        }
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    // MARK: - Instance Methods

    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
            -> Void
    ) {
        completionHandler([.alert, .sound])
    }
}
