//
//  WeatherIconAPIService.swift
//  Weather
//
//  Created by Ted Zhang on 6/6/23.
//

import Foundation
import UIKit

class WeatherIconApiService : NSObject {
    
    public init(url: String)  {
        self.sourcesURL =  URL(string: url)!
    }
    
    private(set) var sourcesURL: URL

    func apiToGetWeatherIcon(completion : @escaping (UIImage?) -> ()){
        URLSession.shared.dataTask(with: sourcesURL) { (data, urlResponse, error) in
            guard let data = data else { completion(nil); return }
            completion(UIImage(data: data))
        }.resume()
    }
}

struct WeatherIconAPIServiceFactory: GenericFactory  {
   static func build(_ config: String) -> WeatherIconApiService {
       WeatherIconApiService(url: config)
    }
}
