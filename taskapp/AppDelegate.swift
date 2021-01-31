//
//  AppDelegate.swift
//  taskapp
//
//  Created by kazuki on 2021/01/21.
//

import UIKit
import UserNotifications    // 追加

@main
class AppDelegate: UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate{



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           // Override point for customization after application launch.
           // ユーザに通知の許可を求める
           let center = UNUserNotificationCenter.current()
           center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
               // Enable or disable features based on authorization
           }
           center.delegate = self     // 追加

           return true
       }

       // アプリがフォアグラウンドの時に通知を受け取ると呼ばれるメソッド --- ここから ---
       func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           completionHandler([.banner, .list, .sound])
       } // --- ここまで追加 ---
}

