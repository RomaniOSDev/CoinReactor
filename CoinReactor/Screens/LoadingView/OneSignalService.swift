//
//  OneSignalService.swift
//  BubblyBass
//
//  Created by Роман Главацкий on 26.10.2025.
//

import Foundation
import OneSignalFramework
import Combine
import AppsFlyerLib
import UIKit

@MainActor
final class OneSignalService: NSObject, ObservableObject {
    
    static let shared = OneSignalService()
    private var isInitialized = false
    
    // MARK: - AppsFlyer ID with nil check
    private var appsFlyerId: String {
        let id = AppsFlyerLib.shared().getAppsFlyerUID()
        if !id.isEmpty {
            return id
        }
        // Fallback to anonymous ID if AppsFlyer ID is not available
        return "anonymous_\(UUID().uuidString)"
    }
    
    private override init() {}
    
    // MARK: - Initialize OneSignal when needed
    func initializeIfNeeded() {
        guard !isInitialized else { return }
        
        OneSignal.initialize("2d571ccf-311c-47bc-96d1-af537462e7d4", withLaunchOptions: nil)
        OneSignal.login(appsFlyerId)
        OneSignal.Debug.setLogLevel(.LL_NONE)
        OneSignal.Notifications.clearAll()
        
        setupNotificationHandler()
        
        isInitialized = true
        #if DEBUG
        print("✅ OneSignal initialized")
        #endif
    }

    func requestPermissionAndInitialize() {
        OneSignal.Notifications.requestPermission({ accepted in
            #if DEBUG
            print("🔔 Push permission granted: \(accepted)")
            #endif
            if accepted {
                self.initializeIfNeeded()
            }
        }, fallbackToSettings: true)
    }
    
    // MARK: - Request permission with explanation
    func requestPermissionWithExplanation(explanation: String, completion: ((Bool) -> Void)? = nil) {
        // Show explanation alert first
        showPermissionExplanationAlert(message: explanation) { [weak self] userAccepted in
            guard let self = self else { return }
            if userAccepted {
                OneSignal.Notifications.requestPermission({ accepted in
                    #if DEBUG
                    print("🔔 Push permission granted: \(accepted)")
                    #endif
                    if accepted {
                        self.initializeIfNeeded()
                    }
                    completion?(accepted)
                }, fallbackToSettings: true)
            } else {
                completion?(false)
            }
        }
    }
    
    // MARK: - Request permission
    func requestPermission() {
        OneSignal.Notifications.requestPermission({ accepted in
            #if DEBUG
            print("🔔 Push permission granted: \(accepted)")
            #endif
        }, fallbackToSettings: true)
    }
    
    // MARK: - Show permission explanation alert
    private func showPermissionExplanationAlert(message: String, completion: @escaping (Bool) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            completion(false)
            return
        }
        
        let alert = UIAlertController(
            title: NSLocalizedString("Notifications", comment: "Notification permission title"),
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Not Now", comment: "Decline notification permission"),
            style: .cancel,
            handler: { _ in completion(false) }
        ))
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Allow", comment: "Allow notification permission"),
            style: .default,
            handler: { _ in completion(true) }
        ))
        
        rootVC.present(alert, animated: true)
    }
    
    // MARK: - Get current OneSignal ID
    func getOneSignalID() -> String? {
        return OneSignal.User.onesignalId
    }
    
    // MARK: - Setup notification handling
    private func setupNotificationHandler() {
        OneSignal.Notifications.addForegroundLifecycleListener(self)
        OneSignal.Notifications.addClickListener(self)
    }
}

// MARK: - OneSignal Notification Handlers
extension OneSignalService: OSNotificationLifecycleListener, OSNotificationClickListener {

    // 🔸 Когда пуш приходит в Foreground
    func onWillDisplay(event: OSNotificationWillDisplayEvent) {
        let notification = event.notification
        #if DEBUG
        print("📬 Received notification in foreground: \(notification.notificationId)")
        
        // Дополнительные данные из payload
        if let additionalData = notification.additionalData {
            print("📦 Additional Data: \(additionalData)")
        }
        #endif
    }

    // 🔸 Когда пользователь кликает по пушу
    func onClick(event: OSNotificationClickEvent) {
        #if DEBUG
        print("🔔 Push notification clicked")
        print("📦 Notification data: \(event.notification.additionalData ?? [:])")
        #endif
        
        guard let additionalData = event.notification.additionalData else {
            #if DEBUG
            print("❌ No additional data in push notification")
            #endif
            return
        }
        
        // Try different possible keys for URL
        var urlString: String?
        
        if let url = additionalData["url"] as? String {
            urlString = url
        } else if let url = additionalData["link"] as? String {
            urlString = url
        } else if let url = additionalData["targetUrl"] as? String {
            urlString = url
        } else if let customUrl = additionalData["custom"] as? [String: Any],
                  let url = customUrl["url"] as? String {
            urlString = url
        }
        
        guard let urlStr = urlString,
              let url = URL(string: urlStr) else {
            #if DEBUG
            print("❌ No valid URL found in push additional data. Available keys: \(additionalData.keys)")
            #endif
            return
        }

        // Validate URL before opening
        guard isValidURL(url) else {
            #if DEBUG
            print("❌ Invalid or unsafe URL: \(url)")
            #endif
            return
        }

        #if DEBUG
        print("🌐 Opening WebView with URL: \(url)")
        #endif
        
        // Ensure we're on main thread and app is active
        DispatchQueue.main.async { [weak self] in
            // Small delay to ensure app is fully active
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.openURLInWebView(url)
            }
        }
    }
    
    // MARK: - URL Validation
    private func isValidURL(_ url: URL) -> Bool {
        // Check scheme - only allow https and http
        guard let scheme = url.scheme?.lowercased(),
              ["https", "http"].contains(scheme) else {
            return false
        }
        
        // Check if URL is valid and not empty
        guard !url.absoluteString.isEmpty,
              url.absoluteString.count < 2048 else { // Reasonable URL length limit
            return false
        }
        
        // Additional security: check for suspicious patterns
        let urlString = url.absoluteString.lowercased()
        let suspiciousPatterns = [
            "javascript:",
            "data:text/html",
            "file://",
            "about:blank"
        ]
        
        for pattern in suspiciousPatterns {
            if urlString.contains(pattern) {
                return false
            }
        }
        
        return true
    }

    // MARK: - Открыть WebView
    private func openURLInWebView(_ url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let webVC = WebviewVC(url: url)
            webVC.modalPresentationStyle = .fullScreen

            // Try to find the topmost view controller
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                #if DEBUG
                print("⚠️ Не удалось найти windowScene")
                #endif
                return
            }
            
            // Find key window or first available window
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
            
            guard let rootVC = window?.rootViewController else {
                #if DEBUG
                print("⚠️ Не удалось найти rootViewController")
                #endif
                return
            }
            
            // Find the topmost presented view controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            
            // If topVC is a navigation controller, push to it
            if let nav = topVC as? UINavigationController {
                nav.pushViewController(webVC, animated: true)
            } else {
                // Otherwise present modally
                topVC.present(webVC, animated: true)
            }
            
            #if DEBUG
            print("✅ WebView открыт с URL: \(url)")
            #endif
        }
    }
}
