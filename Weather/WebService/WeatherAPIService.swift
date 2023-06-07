//
//  QeatherAPIService.swift
//  Weather
//
//  Created by Ted Zhang on 6/6/23.
//

import Foundation

class WeatherAPIService :  NSObject {
    
    public init(url: String)  {
        self.sourcesURL =  URL(string: url)!
    }
    
    private(set) var sourcesURL: URL

    func apiToGetWeatherData(completion : @escaping (Welcome?) -> ()){
        URLSession.shared.dataTask(with: sourcesURL) { (data, urlResponse, error) in
            if let data = data {
            let weatherData = try? JSONDecoder().decode(Welcome.self, from: data)
                completion(weatherData)
            }
        }.resume()
    }
}

struct WeatherAPIServiceFactory: GenericFactory  {
   static func build(_ config: String) -> WeatherAPIService {
       WeatherAPIService(url: config)
    }
}
