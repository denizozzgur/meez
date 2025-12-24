import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // if #available(iOS 10.0, *) {
    //   UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    // }
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup WhatsApp Sticker MethodChannel - safely
    if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "com.meez.app/whatsapp_stickers",
                                           binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "sendStickerPackToWhatsApp" {
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                    return
                }
                
                let error = self?.sendToWhatsApp(payload: args)
                if let error = error {
                    result(FlutterError(code: "WHATSAPP_ERROR", message: error, details: nil))
                } else {
                    result(nil) // Success
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  /// Sends sticker pack data to WhatsApp via pasteboard and URL scheme
  private func sendToWhatsApp(payload: [String: Any]) -> String? {
      // 1. Check if WhatsApp is installed
      guard let whatsAppURL = URL(string: "whatsapp://stickerPack"),
            UIApplication.shared.canOpenURL(whatsAppURL) else {
          return "WhatsApp is not installed"
      }
      
      // 2. Convert payload to JSON data
      guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
          return "Failed to serialize sticker data"
      }
      
      // 3. Copy to pasteboard with WhatsApp's expected type
      let pasteboard = UIPasteboard.general
      let pasteboardItem: [String: Any] = [
          "net.whatsapp.third-party.sticker-pack": jsonData
      ]
      pasteboard.setItems([pasteboardItem], options: [
          .localOnly: true,
          .expirationDate: Date(timeIntervalSinceNow: 60)
      ])
      
      // 4. Open WhatsApp
      DispatchQueue.main.async {
          UIApplication.shared.open(whatsAppURL, options: [:], completionHandler: nil)
      }
      
      return nil // Success
  }
}

