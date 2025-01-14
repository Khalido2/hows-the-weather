//
//  ErrorMessage.swift
//  WeatherAppReal
//
//  Created by "Khalid Olowe-Makorie, Vodafone" on 14/01/2025.
//

import Foundation

//incorrect date given resulting in bad data (error 400)
//failed to decode
//bad url
//bad response

enum WeatherError: String, Error{
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidCity = "It appears this city does not exist. Please try again."
    case unableToComplete = "Unable to complete request. Please check your internet connection."
    case badURL = "Bad URL."
    case invalidData = "The data received from the server was invalid. Please try again."
}
