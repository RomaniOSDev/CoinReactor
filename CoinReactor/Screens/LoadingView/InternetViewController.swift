//
//  InternetViewController.swift
//  BubblyBass
//
//  Created by Роман Главацкий on 26.10.2025.
//


import UIKit
import WebKit
import OneSignalFramework

class WebviewVC: UIViewController, WKNavigationDelegate  {
    
    private let oneSignalService = OneSignalService.shared
    private static let hasRequestedPermissionKey = "WebviewVC_hasRequestedPermission"
    
    private var hasRequestedPermission: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.hasRequestedPermissionKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.hasRequestedPermissionKey)
        }
    }
        
    private let allowedSchemes = ["https", "about", "srcdoc", "blob", "data", "javascript", "file"]

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        saveCookies()
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        let scheme = url.scheme?.lowercased() ?? ""
        let host = url.host?.lowercased() ?? ""
        
        // --- 1. Обработка ссылок с target="_blank" (открываются в новом окне) ---
        if navigationAction.targetFrame == nil {
            // Это ссылка с target="_blank" или открытие в новом окне
            if allowedSchemes.contains(scheme) {
                // Открываем в Safari/внешнем браузере
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        
        // --- 2. Перехват Telegram ссылок ---
        if host == "t.me" || host.contains("telegram") || scheme == "tg" {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        
        // --- 3. Обработка intent:// ссылок (Android Play Store) ---
        if scheme == "intent" {
            // Пытаемся извлечь обычный URL из intent ссылки
            let urlString = url.absoluteString
            if let httpRange = urlString.range(of: "http"),
               let httpURL = URL(string: String(urlString[httpRange.lowerBound...])) {
                UIApplication.shared.open(httpURL, options: [:], completionHandler: nil)
            }
            decisionHandler(.cancel)
            return
        }
        
        // --- 4. Обычные разрешённые схемы (открываются в WebView) ---
        if allowedSchemes.contains(scheme) {
            decisionHandler(.allow)
            return
        }
        
        // --- 5. Всё остальное наружу ---
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        decisionHandler(.cancel)
    }
    
    func obtainCookies() {
        let standartStorage: UserDefaults = UserDefaults.standard
        let data: Data? = standartStorage.object(forKey: "cvcvcv") as? Data
        if let cookie = data {
            let datas: NSArray? = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: cookie)
            if let cookies = datas {
                for c in cookies {
                    if let cookieObject = c as? HTTPCookie {
                        HTTPCookieStorage.shared.setCookie(cookieObject)
                    }
                }
            }
        }
    }

    lazy var firemanWebviewForTerms: WKWebView = {
        let privacyConfiguration = WKWebViewConfiguration()
        privacyConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        privacyConfiguration.allowsPictureInPictureMediaPlayback = true
        privacyConfiguration.allowsAirPlayForMediaPlayback = true
        privacyConfiguration.allowsInlineMediaPlayback = true
        let privacyPreferences = WKWebpagePreferences()
        privacyPreferences.preferredContentMode = .mobile
        privacyConfiguration.defaultWebpagePreferences = privacyPreferences
        let webView = WKWebView(frame: .zero, configuration: privacyConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
        obtainCookies()
        firemanWebviewForTerms.navigationDelegate = self
        
    }

    init(url: URL) {
        self.termsURL = url
        print("termsURL: \(termsURL)")
        super.init(nibName: nil, bundle: nil)
    }
    let termsURL: URL
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request notification permission when WebView appears (only once)
        if !hasRequestedPermission {
            hasRequestedPermission = true
            // Small delay to let WebView load first
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self, self.isViewLoaded && self.view.window != nil else { return }
                self.requestNotificationPermission()
            }
        }
    }
    
    private func requestNotificationPermission() {
        let explanation = "Enable notifications to receive important updates and special offers!"
        
        let alert = UIAlertController(
            title: "Notifications",
            message: explanation,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Not Now",
            style: .cancel,
            handler: nil
        ))
        
        alert.addAction(UIAlertAction(
            title: "Allow",
            style: .default,
            handler: { [weak self] _ in
                guard let self = self else { return }
                OneSignal.Notifications.requestPermission({ accepted in
                    #if DEBUG
                    print("🔔 Push permission granted: \(accepted)")
                    #endif
                    if accepted {
                        self.oneSignalService.initializeIfNeeded()
                    }
                }, fallbackToSettings: true)
            }
        ))
        
        present(alert, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
        }
    
    
    private func addUI() {
        view.addSubview(firemanWebviewForTerms)
        firemanWebviewForTerms.load(URLRequest(url: termsURL))
        firemanWebviewForTerms.allowsBackForwardNavigationGestures = true
        
        firemanWebviewForTerms.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firemanWebviewForTerms.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            firemanWebviewForTerms.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            firemanWebviewForTerms.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            firemanWebviewForTerms.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func saveCookies() {
        let cookieJar: HTTPCookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieJar.cookies {
            let data: Data? = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
            if let data = data {
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "cvcvcv")
            }
        }
    }
      
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Checking web view url")
        if let url = webView.url {
            print("URL for webview: \(url)")
            print("lol kek")
            if SaveService.lastUrl == nil {
                SaveService.lastUrl = url
                print("Last url save: \(String(describing: SaveService.lastUrl))")
            }
        }
    }
}

struct SaveService {
    
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: "LastUrl") }
        set { UserDefaults.standard.set(newValue, forKey: "LastUrl") }
    }
}


