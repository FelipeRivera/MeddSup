//
//  VisitLogLocalizationHelper.swift
//  VisitLogModule
//
//  Created by GPT-5.1 Codex on 15/11/25.
//

import Foundation

public extension Notification.Name {
    static let VisitLogLocalizationDidChange = Notification.Name("VisitLogModule.LocalizationDidChange")
}

/// Helper responsible for resolving localized strings inside the Visit Log module.
public final class VisitLogLocalizationHelper: @unchecked Sendable {
    public static let shared = VisitLogLocalizationHelper()
    
    public private(set) var currentLanguage: String?
    private var languageBundle: Bundle = Bundle.module
    
    private init() {
        updateFromPreferences()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(localeDidChange),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func localeDidChange() {
        if currentLanguage == nil {
            updateFromPreferences()
            NotificationCenter.default.post(name: .VisitLogLocalizationDidChange, object: currentLanguage)
        }
    }
    
    private func updateFromPreferences() {
        guard let preferredLanguage = Locale.preferredLanguages.first else {
            languageBundle = Bundle.module
            currentLanguage = nil
            return
        }
        
        loadBundle(for: preferredLanguage)
    }
    
    private func loadBundle(for languageCode: String) {
        if let path = Bundle.module.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            languageBundle = bundle
            currentLanguage = languageCode
            return
        }
        
        if let prefix = languageCode.split(separator: "-").first {
            let baseCode = String(prefix)
            if let path = Bundle.module.path(forResource: baseCode, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                languageBundle = bundle
                currentLanguage = baseCode
                return
            }
        }
        
        languageBundle = Bundle.module
        currentLanguage = nil
    }
    
    public func setLanguage(_ languageCode: String?) {
        guard let code = languageCode else {
            updateFromPreferences()
            NotificationCenter.default.post(name: .VisitLogLocalizationDidChange, object: currentLanguage)
            return
        }
        
        loadBundle(for: code)
        NotificationCenter.default.post(name: .VisitLogLocalizationDidChange, object: currentLanguage)
    }
    
    public func localizedString(for key: String, arguments: CVarArg... ) -> String {
        let format = NSLocalizedString(key, bundle: languageBundle, comment: "")
        guard arguments.isEmpty == false else {
            return format
        }
        return String(format: format, arguments: arguments)
    }
}


