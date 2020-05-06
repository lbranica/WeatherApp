//
//  HourlyForecast.swift
//  WeatherApp
//
//  Created by Łukasz Branica on 06/05/2020.
//  Copyright © 2020 Łukasz Branica. All rights reserved.
//

import Foundation

struct HourlyForecast: Codable {
    let cod: String
    let message: Double
    let cnt: Int
    let list: [CurrentWeather]
}
