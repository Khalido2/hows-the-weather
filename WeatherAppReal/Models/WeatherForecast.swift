//
//  WeatherForecastModel.swift
//  WeatherAppReal
//
//  Created by "Khalid Olowe-Makorie, Vodafone" on 14/01/2025.
//

import Foundation

struct WeatherAPIResponse: Codable, Hashable {
    var forecast: WeatherForecast
}

struct WeatherForecast: Codable, Hashable {
    var forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Hashable {
    var hour: [ForecastHour]
}

struct WeatherCondition: Codable, Hashable {
    var text: String
    var code: Int
}

struct ForecastHour: Codable, Hashable {
   // var time: Date //date stored as MM-dd-yyyy HH:mm https://nemecek.be/blog/95/how-to-decode-dates-with-codable
    var temp_c: Double
    var condition: WeatherCondition
    var wind_mph: Double
    var humidity: Int
    var feelslike_c: Double
    var cloud: Int
    var will_it_rain: Int
    var chance_of_rain: Int //integer percentage
    var will_it_snow: Int
    var chance_of_snow: Int //integer percentage
}
