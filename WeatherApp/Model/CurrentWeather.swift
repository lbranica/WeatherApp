//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by Łukasz Branica on 06/05/2020.
//  Copyright © 2020 Łukasz Branica. All rights reserved.
//

import Foundation

struct CurrentWeather: Codable {
    let weather: [Weather]
    let main: WeatherMain
    let wind: Wind
    let clouds: Clouds
}
