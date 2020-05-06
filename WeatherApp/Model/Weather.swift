//
//  Weather.swift
//  WeatherApp
//
//  Created by Łukasz Branica on 06/05/2020.
//  Copyright © 2020 Łukasz Branica. All rights reserved.
//

import Foundation

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
