//
//  WeatherData.swift
//  WeatherAppReal
//
//  Created by "Khalid Olowe-Makorie, Vodafone" on 14/01/2025.
//

import Foundation
import SwiftUICore

struct WeatherHourItem: Identifiable {
    let id = UUID()
    
    let location: String
    let temp: String
    let color: Color
    let time: String
    
    var dayType: DayType = DayType.day
    var isRaining: Bool = false
    var cloudCondition: Int = 0
    
    var conditionText: String
}

enum DayType: String {
    case day, night
}

struct Coordinate: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
}

struct DayData {
    var days: [WeatherHourItem]
    
    var currentDateTime: String = Date.now.formatted()
    
    var location: String
    
    static let SunPositions = [Coordinate(x: -180, y: 0),
                      Coordinate(x: -110, y: -70),
                      Coordinate(x: 0, y: -170),
                      Coordinate(x: 110, y: -70),
                      Coordinate(x: 180, y: 0)]
    
    init(location:String, forecastData: [ForecastHour], dateTime: Date){
        days = DayData.createDayData(for: location, forecastData: forecastData)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd HH:mm"
        currentDateTime = dateFormatter.string(from: dateTime)
        
        self.location = location
    }
    
    init(daysData: [WeatherHourItem]){
        days = daysData
        location = "Location"

    }
    
    //make variable to sunset time
    static func getDayColour(for time: Int) -> Color {
   
        if time > 22 || time < 7 {
            return .black
        } else if time > 19 || time < 9 {
            return .purple
        }else{
            return .blue
        }
    }
    
    static func createDayData(for location: String, forecastData: [ForecastHour]) ->  [WeatherHourItem] {
        
        var parsedData:[WeatherHourItem]  = []
        
        for (hour, hourData) in forecastData.enumerated() {
            let isRaining = hourData.will_it_rain == 1
            
           // print("at \(hour) Cloud \(hourData.cloud) and condition \(hourData.condition.text) rain \(hourData.will_it_rain)")
            
            let temperature = "\(Int(hourData.temp_c))"
            
            let dayType: DayType = (hour < 5 || hour > 18) ? DayType.night : DayType.day
            
            parsedData.append(WeatherHourItem(location: location, temp: temperature, color: DayData.getDayColour(for: hour), time: "\(hour)", dayType: dayType, isRaining: isRaining, cloudCondition: hourData.cloud, conditionText: hourData.condition.text))
        }
        
        return parsedData
    }
}
