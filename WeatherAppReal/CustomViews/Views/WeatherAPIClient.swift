//
//  WeatherAPIClient.swift
//  WeatherAppReal
//
//  Created by "Khalid Olowe-Makorie, Vodafone" on 14/01/2025.
//

import SwiftUI




//q param is for location i.e. city name
//days is number of days
//optional hour in 24 hour time i.e. 6 or 18

class WeatherAPIClient {
    let KEY = "0e38bcd5edd44e1da86145821251401"
    let baseURL = "https://api.weatherapi.com/v1"

    let forecastPath = "/forecast.json"
    let currentWeatherPath = "/current.json"
    let futurePath = "/future.json"
    
    let decoder = JSONDecoder()
    
    static let shared = WeatherAPIClient()
    
    func getAvgTemp(for location: String, hour: Int) async throws -> ForecastHour {
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
            return decodedForecast.forecast.forecastday[0].hour[hour]
        } catch {
            //print(String(describing: error))
            throw WeatherError.invalidData
        }
    }
    
}
