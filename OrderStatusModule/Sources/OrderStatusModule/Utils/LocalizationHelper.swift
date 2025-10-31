//
//  LocalizationHelper.swift
//  OrderStatusModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import Foundation

public class OrderStatusLocalizationHelper: @unchecked Sendable {
    public static let shared = OrderStatusLocalizationHelper()
    
    private let bundle: Bundle
    
    private init() {
        // Resolve best matching localization bundle based on device preferences
        let preferredLanguages = Locale.preferredLanguages
        var resolvedBundle: Bundle? = nil
        for code in preferredLanguages {
            if let path = Bundle.module.path(forResource: code, ofType: "lproj"),
               let langBundle = Bundle(path: path) {
                resolvedBundle = langBundle
                break
            }
            if let prefix = code.split(separator: "-").first,
               let path = Bundle.module.path(forResource: String(prefix), ofType: "lproj"),
               let langBundle = Bundle(path: path) {
                resolvedBundle = langBundle
                break
            }
        }
        self.bundle = resolvedBundle ?? Bundle.module
    }
    
    public func localizedString(for key: String) -> String {
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
    
    public func localizedString(for key: String, arguments: [CVarArg]) -> String {
        let format = NSLocalizedString(key, bundle: bundle, comment: "")
        return String(format: format, arguments: arguments)
    }
    
    public func localizedString(for key: String, arguments: CVarArg...) -> String {
        if arguments.isEmpty {
            return localizedString(for: key)
        } else {
            return localizedString(for: key, arguments: arguments)
        }
    }
}

extension String {
    public static func localized(_ key: String) -> String {
        return OrderStatusLocalizationHelper.shared.localizedString(for: key)
    }
    
    public static func localized(_ key: String, _ arguments: CVarArg...) -> String {
        return OrderStatusLocalizationHelper.shared.localizedString(for: key, arguments: arguments)
    }
}
