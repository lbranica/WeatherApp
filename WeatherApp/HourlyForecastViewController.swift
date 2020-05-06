//
//  HourlyForecastViewController.swift
//  WeatherApp
//
//  Created by Łukasz Branica on 06/05/2020.
//  Copyright © 2020 Łukasz Branica. All rights reserved.
//

import UIKit

class HourlyForecastViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    var city: String?
    
    private let weatherService = WeatherService(apiKey: "e4a61dc4cec8661af3982f8b36b15ef3")
    private let currentWeatherCellID = "CurrentWeatherCell"

    private var hourlyForecast: HourlyForecast?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupRefreshControl()
        if let city = city {
            weatherService.hourlyForecast(for: city) { [weak self] result in
                guard let self = self else {
                    return
                }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let forecast):
                        self.hourlyForecast = forecast
                        self.updateView()
                    case .failure(let error):
                        self.showError(title: "An error occured", message: error.localizedDescription)
                    }
                }
            }
        }
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    private func setupTableView() {
        tableView.dataSource = self
        let nib = UINib(nibName: "CurrentWeatherCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: currentWeatherCellID)
    }

    private func showError(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: completion)
    }

    private func updateView() {
        tableView.reloadData()
    }
    private func setupRefreshControl() {
        
    }
}

extension HourlyForecastViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let forecast = hourlyForecast else {
            return 0
        }
        return forecast.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let weather = hourlyForecast else {
            return UITableViewCell()
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: currentWeatherCellID, for: indexPath) as? CurrentWeatherCell {
            cell.setup(for: weather.list[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }

}
