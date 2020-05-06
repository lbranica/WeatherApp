//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Łukasz Branica on 06/05/2020.
//  Copyright © 2020 Łukasz Branica. All rights reserved.
//

import Foundation

final class WeatherService {

    enum ApiError: Error {
        case cityNotFound
        case wrongResponse
        case unknownError
        case networkError
        case parsingError
        case serverError
        case wrongURL
    }

    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func currentWeather(for city: String, completion: @escaping (Result<CurrentWeather, ApiError>) -> Void) {
        if let currentWeatherURL = queryUrlFor(city: city, apiUrl: "https://api.openweathermap.org/data/2.5/weather") {
            URLSession.shared.dataTask(with: currentWeatherURL) { [weak self] data, response, error in
                self?.handleResponse(data: data, response: response, error: error, completion: completion)
            }.resume()
        } else {
            completion(.failure(.wrongURL))
        }
    }

    func hourlyForecast(for city: String, completion: @escaping (Result<HourlyForecast, ApiError>) -> Void) {
        if let currentWeatherURL = queryUrlFor(city: city, apiUrl: "https://api.openweathermap.org/data/2.5/forecast") {
            URLSession.shared.dataTask(with: currentWeatherURL) { [weak self] data, response, error in
                self?.handleResponse(data: data, response: response, error: error) { (result: Result<HourlyForecast, ApiError>) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let forecast):
                        completion(.success(forecast))
                    }
                }
            }.resume()
        } else {
            completion(.failure(.wrongURL))
        }
    }

    private func handleResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, completion: (Result<T, ApiError>) -> Void) {
        guard let apiResponse = response as? HTTPURLResponse else {
            completion(.failure(.wrongResponse))
            return
        }
        guard error == nil else {
            completion(.failure(.networkError))
            return
        }

        switch apiResponse.statusCode {
            case 0 ..< 200:
                completion(.failure(.serverError))
            case 200 ..< 300:
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let decodedResponse = try decoder.decode(T.self, from: data)
                        completion(.success(decodedResponse))
                    } catch {
                        completion(.failure(.parsingError))
                    }
                }
            case 300 ..< 400:
                completion(.failure(.serverError))
            case 400 ..< 500:
                completion(.failure(.cityNotFound))
            case 500 ... Int.max:
                completion(.failure(.serverError))
            default:
                completion(.failure(.serverError))
        }

    }

    private func queryUrlFor(city: String, apiUrl: String) -> URL? {
        let queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        var urlComponents = URLComponents(string: apiUrl)
        urlComponents?.queryItems = queryItems
        return urlComponents?.url
    }
}

extension WeatherService.ApiError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .cityNotFound:
            return "City not found"
        case .wrongResponse:
            return "Wrong server response"
        case .unknownError:
            return "Unknown error"
        case .networkError:
            return "Network error"
        case .parsingError:
            return "Parsing error"
        case .serverError:
            return "Server error"
        case .wrongURL:
            return "Error with request URL"
        }
    }
}
