//
//  WeatherAppConfigurations.swift
//  WeatherAppReal
//
//  Created by "Khalid Olowe-Makorie, Vodafone" on 30/01/2025.
//

import Foundation

final class WeatherAppConfigurations {
    
    enum Key: String {
        case weatherAPIKey = "ForecastAPIKey"
    }
    
    static func getValueFor(_ key: Key) -> String? {
        guard let dictionary = Bundle.main.object(forInfoDictionaryKey: "CustomConfigurations") as? [String: String] else { return nil }
        return dictionary[key.rawValue]
    }
}
