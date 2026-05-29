import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String,
       !key.isEmpty,
       !key.contains("$(") {
      GMSServices.provideAPIKey(key)
      #if DEBUG
      print("[GoogleMaps] API key configured (length=\(key.count))")
      #endif
    } else {
      #if DEBUG
      print(
        "[GoogleMaps] Missing or unresolved GOOGLE_MAPS_API_KEY — "
        + "run: dart run tool/sync_env.dart, then full rebuild"
      )
      #endif
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
