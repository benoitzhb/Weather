//
//  ViewController.swift
//  Weather
//
//  Created by Ted Zhang on 6/6/23.
//

import MapKit
import UIKit

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate{
    
    @IBOutlet public var searchTextInput: UITextField!
    @IBOutlet public var stackContainer: UIStackView!
    @IBOutlet public var cityNameLabel: UILabel!
    @IBOutlet public var tempLabel: UILabel!
    @IBOutlet public var cooridinateLabel: UILabel!
    @IBOutlet public var weatherIcon: UIImageView!

    private var weatherViewModel : WeatherViewModel!

    @UserDefault(key: "last search city", defaultValue: "Austin")
    private var cityName: String
    private var cityIconName: String = "01d"
    
    private var searchTextFieldConstraint: NSLayoutConstraint!
    
    let locationManager = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextInput.delegate = self
        setupConstraints()
        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        // For use when the app is open
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func callToViewModelForUIUpdate(){
        let bindWeatherViewModelToController = {
            DispatchQueue.main.async {
                self.updateDataSource()
            }
        }
        
        self.weatherViewModel =  WeatherViewModelFactory.build(
            (
                api: WeatherAPIServiceFactory.build(WeatherViewModel.weatherAPIRequestAddress(cityName)),
                iconApi: WeatherIconAPIServiceFactory.build(WeatherViewModel.weatherIconAPIRequestAddress(cityIconName)),
                bindClosure: bindWeatherViewModelToController
            )
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setOrientationAllignment()
        callToViewModelForUIUpdate()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.setOrientationAllignment()
    }
    
    func setOrientationAllignment() {
        switch UIDevice.current.orientation {
        case .portrait:
            searchTextFieldConstraint.constant = 0
        case .landscapeLeft:
            searchTextFieldConstraint.constant = view.safeAreaInsets.top
        case .landscapeRight:
            searchTextFieldConstraint.constant = view.safeAreaInsets.top
        default:
            break
        }
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    func setupConstraints() {
        searchTextInput.translatesAutoresizingMaskIntoConstraints = false
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        cityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        cooridinateLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        
        searchTextFieldConstraint = searchTextInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.safeAreaInsets.top)
        searchTextFieldConstraint.isActive = true
        
        view.addConstraints([
            searchTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            stackContainer.topAnchor.constraint(equalTo: searchTextInput.bottomAnchor, constant: 10),
            stackContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    func updateDataSource(){
        guard let weatherInfo = weatherViewModel.weatherData else { return }
        assignData(weatherInfo: weatherInfo)
    }
    
    func assignData(weatherInfo: WeatherInfo) {
        cityNameLabel.text = "City name: \(weatherInfo.weather?.name ??  "")"
        tempLabel.text = "Temp: \(weatherInfo.weather?.main.temp ?? 0)"
        cooridinateLabel.text = "Coordinate: \(weatherInfo.weather?.coord.lat ?? 0), \(weatherInfo.weather?.coord.lon ?? 0)"
        weatherIcon.image = weatherInfo.icon
    }
    
    func searchForCity() {
        weatherViewModel.getWeatherForCity(cityName: cityName)
    }
}

extension ViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        true
    }
    
    func  textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if reason == .committed {
            guard let city = textField.text else { return }
            cityName = city
            searchForCity()
        }
    }
}

// detect device located city
extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $1) }
    }
}

extension ViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let loc = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            loc.fetchCityAndCountry { [weak self](city, error) in
                guard let city = city, error == nil else { return }
                self?.cityName = city
                self?.searchForCity()
            }
        }
    }
}

