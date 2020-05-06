//
//  CurrentWeatherCell.swift
//  WeatherApp
//
//  Created by Łukasz Branica on 06/05/2020.
//  Copyright © 2020 Łukasz Branica. All rights reserved.
//

import UIKit

final class CurrentWeatherCell: UITableViewCell {
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var tempLabelValue: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var pressureLabelValue: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var humidityLabelValue: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        tempLabel.text = nil
        pressureLabel.text = nil
        humidityLabel.text = nil
    }

    func setup(for weather: CurrentWeather) {
        tempLabel.text = "Temp"
        tempLabelValue.text = String(weather.main.temp)
        pressureLabel.text = "Pressure"
        pressureLabelValue.text = String(weather.main.pressure)
        humidityLabel.text = "Humidity"
        humidityLabelValue.text = "\(weather.main.humidity)%"
    }
}
