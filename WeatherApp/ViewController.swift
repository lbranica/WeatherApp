//
//  ViewController.swift
//  WeatherApp
//
//  Created by Łukasz Branica on 06/05/2020.
//  Copyright © 2020 Łukasz Branica. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var cityField: UITextField!

    private var weatherService: WeatherService!
    private let refreshControl = UIRefreshControl()
    private var currentWeather: CurrentWeather?

    private let weatherCellID = "WeatherCell"
    private let currentWeatherCellID = "CurrentWeatherCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        weatherService = WeatherService(apiKey: "e4a61dc4cec8661af3982f8b36b15ef3")

        setupTableView()
        setupRefreshControl()
        setupCityField()
    }

    @IBAction func showTapped(_ sender: UIButton) {
        guard let city = cityField.text, !city.isEmpty else {
            showError(title: "An error occured", message: "Field city cannot be empty!")
            return
        }
        weatherService.currentWeather(for: city) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let currentWeather):
                    self.currentWeather = currentWeather
                    self.updateView()
                case .failure(let error):
                    self.showError(title: "An error occured", message: error.localizedDescription)
                }
            }
        }
    }



    private func showError(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: completion)
    }

    @objc private func reloadWeatherData(_ sender: Any) {
        guard let city = cityField.text, !city.isEmpty else {
            showError(title: "An error occured", message: "Field city cannot be empty!") {
                self.refreshControl.endRefreshing()
            }
            return
        }
        weatherService.currentWeather(for: city) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                switch result {
                    case .success(let currentWeather):
                        self.currentWeather = currentWeather
                        self.updateView()
                    case .failure(let error):
                        self.showError(title: "An error occured", message: error.localizedDescription)
                }
            }
        }
    }

    @objc func cityFieldDidChange(_ textField: UITextField) {
        if let city = textField.text, !city.isEmpty {
            refreshControl.attributedTitle = NSAttributedString(string: "Fetching weather data for \(city)...")
            if #available(iOS 10.0, *) {
                tableView.refreshControl = refreshControl
            } else {
                tableView.addSubview(refreshControl)
            }
        } else {
            if #available(iOS 10.0, *) {
                tableView.refreshControl = nil
            } else {
                refreshControl.removeFromSuperview()
            }
        }
    }

    private func updateView() {
        tableView.reloadData()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: weatherCellID)
        let nib = UINib(nibName: "CurrentWeatherCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: currentWeatherCellID)
    }

    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(reloadWeatherData(_:)), for: .valueChanged)
    }

    private func setupCityField() {
        cityField.addTarget(self, action: #selector(cityFieldDidChange(_:)), for: .editingChanged)
    }
}

extension ViewController: UITableViewDelegate {

}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Current weather" : "3 hours forecast"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let weather = currentWeather else {
            return 0
        }
        if section == 0 {
            return weather.weather.count + 1
        } else {
            return 0//todo handle 3 hours forecast
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentWeather = currentWeather else {
            return UITableViewCell()
        }
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: currentWeatherCellID, for: indexPath) as? CurrentWeatherCell {
                    cell.setup(for: currentWeather)
                    return cell
                } else {
                    return UITableViewCell()
                }
            } else {
                let weatherIndex = indexPath.row - 1
                if weatherIndex >= 0 && weatherIndex < currentWeather.weather.count {
                    let cell = tableView.dequeueReusableCell(withIdentifier: weatherCellID, for: indexPath)
                    let weather = currentWeather.weather[weatherIndex]
                    cell.textLabel?.text = weather.description
                    print(weather.description)
                    return cell
                }
            }
            return UITableViewCell()
        } else {
            return UITableViewCell()
        }
    }

}
