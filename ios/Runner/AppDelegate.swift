import UIKit
import Flutter
import flutter_local_notifications
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let DEEPLINK_CHANNEL = "app/deeplink"
    private let KAKAO_SHARE_CHANNEL = "app/kakao_share"
    private var deeplinkChannel: FlutterMethodChannel?
    private var kakaoShareChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()

        // Method Channel 초기화
        let controller = window?.rootViewController as! FlutterViewController
        deeplinkChannel = FlutterMethodChannel(name: DEEPLINK_CHANNEL, binaryMessenger: controller.binaryMessenger)
        kakaoShareChannel = FlutterMethodChannel(name: KAKAO_SHARE_CHANNEL, binaryMessenger: controller.binaryMessenger)

        // Local notifications 설정
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        GeneratedPluginRegistrant.register(with: self)

        // 앱이 종료 상태에서 URL로 실행된 경우 처리
        if let url = launchOptions?[.url] as? URL {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                _ = self.application(UIApplication.shared, open: url, options: [:])
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 유니버설 링크 처리 (HTTPS)
    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            forwardToFlutter(url: url, channel: deeplinkChannel)
            return true
        }
        return false
    }

    // 호스트 기반 라우팅 구현
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        print("Received URL: \(url.absoluteString)")
        print("Host: \(url.host ?? "nil")")

        // 카카오 스킴인지 확인
        if url.scheme?.hasPrefix("kakao") == true {
            return handleKakaoURL(url, options: options)
        }

        // 기타 커스텀 스킴 처리 (miti://)
        forwardToFlutter(url: url, channel: deeplinkChannel)
        return true
    }

    // 카카오 URL 호스트 기반 라우팅
    private func handleKakaoURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        guard let host = url.host else {
            print("Kakao URL without host, using default handling")
            return super.application(UIApplication.shared, open: url, options: options)
        }

        switch host.lowercased() {
        case "oauth":
            // 카카오 로그인 - SDK에 직접 전달 (가로채지 않음)
            print("Kakao OAuth detected - forwarding to SDK")
            return super.application(UIApplication.shared, open: url, options: options)

        case "kakaolink":
            // 카카오 공유 - Flutter로 전달
            print("Kakao Share detected - forwarding to Flutter")
            forwardToFlutter(url: url, channel: kakaoShareChannel, isKakaoShare: true)
            return true

        default:
            // 알 수 없는 카카오 호스트 - 기본 처리
            print("Unknown Kakao host: \(host) - using default handling")
            return super.application(UIApplication.shared, open: url, options: options)
        }
    }

    // Flutter로 URL 전달
    private func forwardToFlutter(url: URL, channel: FlutterMethodChannel?, isKakaoShare: Bool = false) {
        let urlData: [String: Any] = [
            "url": url.absoluteString,
            "scheme": url.scheme ?? "",
            "host": url.host ?? "",
            "path": url.path,
            "query": url.query ?? "",
            "queryParameters": extractQueryParameters(from: url)
        ]

        if isKakaoShare {
            channel?.invokeMethod("handleKakaoShare", arguments: urlData)
        } else {
            channel?.invokeMethod("handleDeepLink", arguments: url.absoluteString)
        }
    }

    // 쿼리 파라미터 추출 헬퍼
    private func extractQueryParameters(from url: URL) -> [String: String] {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return [:]
        }

        var parameters: [String: String] = [:]
        for item in queryItems {
            parameters[item.name] = item.value ?? ""
        }
        return parameters
    }
}
