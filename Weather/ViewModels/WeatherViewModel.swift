//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Ted Zhang on 6/6/23.
//

import Foundation

class WeatherViewModel : NSObject {
    
    static let weatherAPIRequestAddress: (String) -> String = { city in
        let cityName = String(describing: city.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ??  "")
        return "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=6294b19e257d1929763ae2fbb00050ca"
    }
    
    static let weatherIconAPIRequestAddress: (String) -> String  = { code in
        let iconCode = String(describing: code.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ??  "")
        return "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
    }
    
    private var weatherApiService : WeatherAPIService!
    private var weatherIconApiService : WeatherIconApiService!
    
    private(set) var weatherData : WeatherInfo? {
        didSet {
            bindWeatherViewModelToController()
        }
    }
    
    var bindWeatherViewModelToController : (() -> ()) = {}
    
    public init(service: WeatherAPIService, iconService: WeatherIconApiService,  _ bindMethod: @escaping (() -> ()) = {})  {
        super.init()
        weatherApiService = service
        weatherIconApiService = iconService
        bindWeatherViewModelToController = bindMethod
        callFuncToGetWeatherData()
    }
    
    func callFuncToGetWeatherData() {
        weatherApiService.apiToGetWeatherData { [weak self](weatherData) in
            if let iconName = weatherData?.weather.first?.icon {
                self?.weatherIconApiService  = WeatherIconAPIServiceFactory.build(WeatherViewModel.weatherIconAPIRequestAddress(iconName))
            }
            
            self?.weatherIconApiService.apiToGetWeatherIcon { [weak self](image) in
                self?.weatherData = WeatherInfo(weather: weatherData, icon: image)
                
            }
        }
    }
    
    func getWeatherForCity(cityName: String) {
        weatherApiService = WeatherAPIServiceFactory.build(WeatherViewModel.weatherAPIRequestAddress(cityName))
        callFuncToGetWeatherData()
    }
    
    func getWeatherIcon(iconCode: String) {
        
    }
}

class WeatherViewModelFactory: GenericFactory {
    static func build(_ config: (api: WeatherAPIService, iconApi: WeatherIconApiService, bindClosure: () -> () )) -> WeatherViewModel {
        WeatherViewModel(service: config.api, iconService: config.iconApi, config.bindClosure)
    }
}
