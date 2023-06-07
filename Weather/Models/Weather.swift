//
//  Weather.swift
//  Weather
//
//  Created by Ted Zhang on 6/6/23.
//

import UIKit

struct WeatherInfo {
    let weather: Welcome?
    let icon: UIImage?
}

// MARK: - Welcome
struct Welcome: Codable {
    let coord: Coord
    let weather: [Weather]
    let main: Main
    let name: String
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp: Double
    let pressure, humidity: Int
    let tempMin, tempMax: Double

    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}
// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, description, icon: String
}
