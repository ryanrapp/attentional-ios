//
//  UserDefaultsExtensions.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/3/24.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let username = "username"
        static let apiKey = "apiKey"
        static let useGpt4 = "useGpt4"
    }

    var username: String? {
        get { string(forKey: Keys.username) }
        set { set(newValue, forKey: Keys.username) }
    }
    var apikey: String? {
        get { string(forKey: Keys.apiKey) }
        set { set(newValue, forKey: Keys.apiKey) }
    }
    var useGpt4: Bool? {
        get { bool(forKey: Keys.useGpt4) }
        set { set(newValue, forKey: Keys.useGpt4) }
    }
}
