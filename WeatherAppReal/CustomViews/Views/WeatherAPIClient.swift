//
//  WeatherAPIClient.swift
//  WeatherAppReal
//
//  Created by "Khalid Olowe-Makorie, Vodafone" on 14/01/2025.
//

import SwiftUI

class WeatherAPIClient {
    let KEY =  WeatherAppConfigurations.getValueFor(.weatherAPIKey) ?? "NO KEY"
    let baseURL = "https://api.weatherapi.com/v1"

    let forecastPath = "/forecast.json"
    let currentWeatherPath = "/current.json"
    let futurePath = "/future.json"
    
    let decoder = JSONDecoder()
    
    let dateFormatter = DateFormatter()
    
    static let shared = WeatherAPIClient()
    
    init() {
       /* guard let KEY = WeatherAppConfigurations.getValueFor(.weatherAPIKey) else {
            throw WeatherError.badURL
        }*/
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func getForecast(for location: String) async throws -> WeatherAPIResponse {
        let endpoint = baseURL + forecastPath + "?key=\(KEY)&q=\(location)&aqi=no&alerts=no"
        
        guard let url = URL(string: endpoint) else {
            throw WeatherError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw WeatherError.invalidCity //almost guarunteed to be caused by invalid city name
        }
        
        do {
            let decodedForecast = try decoder.decode(WeatherAPIResponse.self, from: data)
            return decodedForecast
        } catch {
            throw WeatherError.invalidData
        }
    }
    
}
