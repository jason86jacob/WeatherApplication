//
//  WeatherModel.swift
//  Weather
//
//  Created by Jason Jacob on 8/9/23.
// Model class for Weather API response

import Foundation

struct WeatherModel: Codable {

    let coordinates: Coordinate
    let weather: [Weather]
    let mainStats: MainStats
    let visibility, timezone, cityid: Int
    let windConditions: WindCondition
    let cloudPercentage: CloudsPercentage
    let sys: Sys
    let cityname: String

    enum CodingKeys: String, CodingKey {
        case coordinates = "coord"
        case mainStats = "main"
        case weather, visibility, timezone, sys
        case windConditions = "wind"
        case cloudPercentage = "clouds"
        case cityname = "name"
        case cityid = "id"
    }

}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}

struct Weather: Codable {
    let id: Int
    let main, description, icon: String

}

struct MainStats: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

struct WindCondition: Codable {
    let speed: Double
    let deg: Int
}

struct Sys: Codable {
    let country: String
    let sunrise, sunset: Int
}

struct CloudsPercentage: Codable {
    let all: Int
}
