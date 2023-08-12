//
//  Constants.swift
//  Weather
//
//  Created by Jason Jacob on 8/11/23.
//

import Foundation

struct Constants {
    struct API {
        static let apiKey = "b4bb2cc048322305f876aff2ffcf0e60"
        static let weatherAPIwithImperialMetrics = "https://api.openweathermap.org/data/2.5/weather?&units=imperial&appid=\(Constants.API.apiKey)&"
        static let weatherIconUrlFormat = "https://openweathermap.org/img/wn/%@@2x.png"
        static let ampersand = "&"
        static let queryString = "q="
        static let latitudeQuery = "lat="
        static let longitudeQuery = "lon="
        static let degreeSymbol = "\u{00B0}"
    }
    
    struct WeatherData {
        static let cityName = "cityName"
        static let temperature = "temperature"
        static let description = "description"
        static let highTemperature = "high_temp"
        static let lowTemperature = "low_temp"
        static let feelsLike = "feelsLike"
        static let pressure = "pressure"
        static let wind = "wind"
        static let highTemperatureLabelText = " H: "
        static let lowTemperatureLabelText = "L: "
    }
    
    struct Common {
        static let farenheitUnit = " F"
        static let pressureUnit = " hPa"
        static let windSpeedUnit = " miles/hr "
        static let notAvailable = "NA"
        static let status = "status"
        static let failedStatus = "failed"
        
    }
    
    struct Alert {
        static let alertTitle = "Alert"
        static let ok = "OK"
        
    }
    
    struct ErrorMessages {
        static let invalidInputCombination = "Please provide a valid combination of inputs!\n It is either just city name OR city name, state code and country code together!"
        static let networkIssue = "There seems to be some network issue. Please try after some time."
        static let invalidInput = "It seems you have entered a invalid inputs. Please check and retry again!"
    }
    
    struct KeyChain {
        static let keyChainService = "com.Jason.Weather"
        static let lastCityKey = "lastCity"
    }
}
