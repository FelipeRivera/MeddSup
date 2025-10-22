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
        guard let bundlePath = Bundle.module.path(forResource: "en", ofType: "lproj"),
              let bundle = Bundle(path: bundlePath) else {
            self.bundle = Bundle.module
            return
        }
        self.bundle = bundle
    }
    
    public func localizedString(for key: String, arguments: CVarArg...) -> String {
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        
        if arguments.isEmpty {
            return localizedString
        } else {
            return String(format: localizedString, arguments: arguments)
        }
    }
}

extension String {
    public static func localized(_ key: String, arguments: CVarArg...) -> String {
        return OrderStatusLocalizationHelper.shared.localizedString(for: key, arguments: arguments)
    }
}
