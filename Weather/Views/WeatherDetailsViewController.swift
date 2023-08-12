//
//  WeatherDetailsViewController.swift
//  Weather
//
//  Created by Jason Jacob on 8/9/23.
// This view controller will provide input fields for the user to enter a city, state code, country code
// and fetch the weather details based on search parameters. In case location permissions are provided,
// weather for the current location is fetched.
//

import UIKit
import CoreLocation
import Combine

class WeatherDetailsViewController: UIViewController {

    // MARK: IBOutlet UI components
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var cityName: UITextField!
    @IBOutlet weak var stateCode: UITextField!
    @IBOutlet weak var countryCode: UITextField!
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var curentLocationLabel: UILabel!
    @IBOutlet weak var searchedCityName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var lowtemperature: UILabel!
    @IBOutlet weak var hightemperature: UILabel!
    @IBOutlet weak var feelsLiketempValue: UILabel!
    @IBOutlet weak var pressureValue: UILabel!
    @IBOutlet weak var windValue: UILabel!

    var viewModel: WeatherDetailsViewModel!
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = WeatherDetailsViewModel()
        bindProperties()
        displayWeatherDetails()
    }

    // MARK: Data Binders
    func bindProperties() {
        // Binding for weather iconImage once its available to use
        viewModel.$iconImageData.sink { [weak self] icon in
            if let strongSelf = self,
               let iconData = icon {
                DispatchQueue.main.async {
                    strongSelf.iconImage.image = UIImage(data: iconData)
                }
            }
        }.store(in: &cancellables)

        // Binding for any user presentable Error messages using UIAlertController
        viewModel.$errorMessage.sink { [weak self] errorMessage in
            if let strongSelf = self,
               !errorMessage.isEmpty {
                    strongSelf.displayAlertwithErrorMessage(errorMessage)
            }
        }.store(in: &cancellables)
    }

    // MARK: Fetch Weather details based on current location or search criteria
    func displayWeatherDetails() {
        // Attempt to fetch weather details using current location if user has given permission
        viewModel.fetchWeatherUsingCurrentLocation { [weak self]  in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.viewModel.weatherDataStatus() {
                // If weather details cannot be shown for current location,
                // then check for the last searched city. If exists then fetch
                // weather details for the same.
                self?.curentLocationLabel.isHidden = true
                if let searchCity = strongSelf.viewModel.fetchLastSuccessfullySearchedCity() {
                    strongSelf.fetchWeatherDetails(cityName: searchCity)
                }
            } else {
                DispatchQueue.main.async {
                    // show the current location label since we used location
                    // coordinates for getting the weather details.
                    strongSelf.curentLocationLabel.isHidden = false
                }
                strongSelf.populateDatailView()
            }
        }
    }

    // MARK: Search button action
    @IBAction func searchButtonAction(_ sender: Any) {
        // Hide the details View since we are going to fetch new weather data
        curentLocationLabel.isHidden = true
        if !detailsStackView.isHidden {
            hideDetailsView()
        }
        fetchWeatherDetails(cityName: cityName.text, stateCode: stateCode.text, countryCode: countryCode.text)
    }

    // MARK: Call the web service fetch api of viewModelObject
    func fetchWeatherDetails(cityName: String? = nil, stateCode: String? = nil, countryCode: String? =  nil) {
    viewModel.fetchWeatherDetails(cityName: cityName, stateCode: stateCode, countryCode: countryCode) { [weak self] in
            if self?.viewModel.weatherDataStatus() ?? false {
                self?.populateDatailView()
            }
        }
    }

    // MARK: Display the weather details for each ui field
    func populateDatailView() {
        DispatchQueue.main.async {[weak self] in
            self?.searchedCityName.text  = self?.viewModel.getCityName()
            self?.temperature.text  = self?.viewModel.getTemperature()
            self?.weatherDescription.text  = self?.viewModel.getDescription()
            self?.lowtemperature.text  = self?.viewModel.getLowTemperature()
            self?.hightemperature.text  = self?.viewModel.getHighTemperature()
            self?.feelsLiketempValue.text  = self?.viewModel.getFeelsLiketemperature()
            self?.pressureValue.text  = self?.viewModel.getPressureMeasure()
            self?.windValue.text  = self?.viewModel.getWindSpeed()
            self?.showDetailsView()
            guard let cityName = self?.searchedCityName.text,
                  !cityName.isEmpty,
                  cityName != "NA" else {
                return
            }
            self?.viewModel.saveLastSuccessfullySearchedCity(cityName)
        }
    }
}
// MARK: extension for displaying Alert
extension WeatherDetailsViewController {
    func displayAlertwithErrorMessage(_ errorMessage: String) {
        DispatchQueue.main.async {
        let alert = UIAlertController(title: Constants.Alert.alertTitle,
                                      message: errorMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: Constants.Alert.okLabel,
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: extension for view animations
extension WeatherDetailsViewController {

    // MARK: hides the details View with animation
    func hideDetailsView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.detailsStackView.alpha = 0.0
        }) { (_) in
            self.detailsStackView.isHidden = true
        }
    }

    // MARK: shows the details View with animation
    func showDetailsView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.detailsStackView.alpha = 1.0
        }) { (_) in
            self.detailsStackView.isHidden = false
        }
    }

}

// MARK: TextField delegates
extension WeatherDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
