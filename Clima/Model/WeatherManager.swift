//
//  WeatherManager.swift
//  Clima
//
//  Created by Angela Yu on 03/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: AFError)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=79a16f0676fb71de785e8f980f330126&units=metric"

    var delegate: WeatherManagerDelegate?

    func fetchWeather(cityName: String) {
        let urlString: String
        if cityName.contains(" ") {
            let cityNameWithSpace = (cityName as NSString).replacingOccurrences(of: " ", with: "+")
            urlString = "\(weatherURL)&q=\(cityNameWithSpace)"
        } else {
            urlString = "\(weatherURL)&q=\(cityName)"
        }
        performRequest(with: urlString)
    }

    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }

    func performRequest(with urlString: String) {
        AF.request(urlString).responseDecodable(of: WeatherData.self) { response in
            switch response.result {
            case .success:
                let decodedData = response.value
                let id = decodedData!.weather[0].id
                let temp = decodedData!.main.temp
                let name = decodedData!.name
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                self.delegate?.didUpdateWeather(self, weather: weather)
            case let .failure(error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
}
