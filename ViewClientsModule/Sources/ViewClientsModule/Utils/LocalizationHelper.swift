//
//  LocalizationHelper.swift
//  ViewClientsModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

public extension Notification.Name {
    static let ViewClientsLocalizationDidChange = Notification.Name("ViewClientsModule.LocalizationDidChange")
}

public final class ViewClientsLocalizationHelper: @unchecked Sendable {
    public static let shared = ViewClientsLocalizationHelper()
    
    public private(set) var currentLanguage: String?
    
    private var languageBundle: Bundle = Bundle.module
    
    private init() {
        updateFromSystemPreferences()
        NotificationCenter.default.addObserver(self, selector: #selector(systemPreferencesChanged), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
    }
    
    @objc private func systemPreferencesChanged() {
        if currentLanguage == nil {
            updateFromSystemPreferences()
            NotificationCenter.default.post(name: .ViewClientsLocalizationDidChange, object: currentLanguage)
        }
    }
    
    private func updateFromSystemPreferences() {
        let preferred = Locale.preferredLanguages
        var found = false
        for code in preferred {
            let components = code.split(separator: "-")
            if let fullPath = Bundle.module.path(forResource: code, ofType: "lproj"), let bundle = Bundle(path: fullPath) {
                languageBundle = bundle
                currentLanguage = String(code)
                found = true
                break
            }
            if let prefix = components.first, let path = Bundle.module.path(forResource: String(prefix), ofType: "lproj"), let bundle = Bundle(path: path) {
                languageBundle = bundle
                currentLanguage = String(prefix)
                found = true
                break
            }
        }
        
        if !found {
            languageBundle = Bundle.module
            currentLanguage = nil
        }
    }
    
    public func setLanguage(_ languageCode: String?) {
        if let code = languageCode {
            if let path = Bundle.module.path(forResource: code, ofType: "lproj"), let bundle = Bundle(path: path) {
                languageBundle = bundle
                currentLanguage = code
            } else if let prefix = code.split(separator: "-").first,
                      let path = Bundle.module.path(forResource: String(prefix), ofType: "lproj"),
                      let bundle = Bundle(path: path) {
                languageBundle = bundle
                currentLanguage = String(prefix)
            } else {
                languageBundle = Bundle.module
                currentLanguage = nil
            }
        } else {
            updateFromSystemPreferences()
        }
        
        NotificationCenter.default.post(name: .ViewClientsLocalizationDidChange, object: currentLanguage)
    }
    
    public func localizedString(for key: String, arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, bundle: languageBundle, comment: "")
        guard arguments.count > 0 else { return format }
        return String(format: format, arguments: arguments)
    }
}

// MARK: - Convenience Extensions
public extension String {
    static func localized(_ key: String, arguments: CVarArg...) -> String {
        return ViewClientsLocalizationHelper.shared.localizedString(for: key, arguments: arguments)
    }
}

