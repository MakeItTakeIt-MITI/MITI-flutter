import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}


// func webView(
//   _ webView: WKWebView,
//   decidePolicyFor navigationAction: WKNavigationAction,
//   decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
// ) {
//   if let url = navigationAction.request.url,
//   url.scheme != "http" && url.scheme != "https" {
//     UIApplication.shared.open(url, options: [:], completionHandler:{ (success) in
//       if !(success){
//         /*앱이 설치되어 있지 않을 때*/
//       }
//     })
//     decisionHandler(.cancel)
//   } else {
//     decisionHandler(.allow)
//   }
// }
