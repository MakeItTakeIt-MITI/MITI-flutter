import UIKit
import Flutter
import flutter_local_notifications
import Firebase // Add Line.
@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure() // Add Line.
    // This is required to make any communication available in the action isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 유니버설 링크 처리 (HTTPS)
  override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    // 유니버설 링크로 앱이 실행된 경우
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
      // Flutter로 딥링크 정보 전달
      let controller = window?.rootViewController as! FlutterViewController
      let flutterChannel = FlutterMethodChannel(name: "app/deeplink", binaryMessenger: controller.binaryMessenger)
      flutterChannel.invokeMethod("handleDeepLink", arguments: url.absoluteString)
      return true
    }
    return false
  }

  // 🆕 Custom Scheme 처리 (miti://, kakao:// 등)
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Custom Scheme으로 앱이 실행된 경우
    let controller = window?.rootViewController as! FlutterViewController
    let flutterChannel = FlutterMethodChannel(name: "app/deeplink", binaryMessenger: controller.binaryMessenger)
    flutterChannel.invokeMethod("handleDeepLink", arguments: url.absoluteString)
    return true
  }
}
