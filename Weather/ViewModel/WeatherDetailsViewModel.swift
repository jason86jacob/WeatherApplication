//
//  WeatherDetailsViewModel.swift
//  Weather
//
//  Created by Jason Jacob on 8/9/23.
// This class represents the viewModel that provides all weather data to the controller and
// interacts with other helper classes.

import Foundation
import Combine

class WeatherDetailsViewModel {
    // MARK: Initializing helper class objects
    let locationManager = LocationManager()
    let webserviceManager = WebserviceManager()
    private var cancellables: Set<AnyCancellable> = []
    // Published property for weather icon
    @Published var iconImageData: Data?
    // Published property for displaying user friendly error messages
    @Published var errorMessage: String = ""
    // This will hold the last fetched weather data
    var currentWeatherData: [String: String] = [:]
}

// MARK: Extension which will have all API calls to WebserViceManager
extension WeatherDetailsViewModel {
    // MARK: Function which will accept the user inputs and call the weather API
    func fetchWeatherDetails(cityName: String? = nil,
                             stateCode: String? = nil,
                             countryCode: String? = nil,
                             completionHandler: @escaping (() -> Void)) {
        // Create query string based on available inputs
        var queryString = Constants.API.queryString
        if let cityName = cityName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !cityName.isEmpty {
            queryString += "\(cityName)"
        }
        if let stateCode = stateCode?.trimmingCharacters(in: .whitespacesAndNewlines),
           !stateCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryString += ",\(stateCode)"
        }
        if let countryCode = countryCode?.trimmingCharacters(in: .whitespacesAndNewlines),
           !countryCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryString += ",\(countryCode)"
        }
        // Validate bussiness logic to check if user has inputted
        // City Name OR (city name + state code + country code) together
        if weatherInputValidationStatusPassed(cityName: cityName ?? "",
                                              stateCode: stateCode ?? "",
                                              countryCode: countryCode ?? "") {
            let finalUrlString = Constants.API.weatherAPIwithImperialMetrics + queryString
            // Pass the final url string to processWeatherDataforURL which
            // can be reused for both types of weather api calls(search based
            // and location based)
            self.processWeatherDataforURL(finalUrlString, completionHandler: completionHandler)
        } else {
            // Input validation failed so alert the user
            self.errorMessage = Constants.ErrorMessages.invalidInputCombination
        }
    }

    // MARK: Function which will take user location cordinates and call the weather API
    func fetchWeatherUsingCurrentLocation(completionHandler: @escaping (() -> Void)) {
        // Setup location Manager
        locationManager.setupManager()
        // Coordinates will be available only if the user permissions are there
        locationManager.$coordinates.sink { [weak self] coordinates in
            if coordinates?.status ?? false,
               let latitude = coordinates?.latitude,
               let longitude = coordinates?.longitude {
                // Once coordniates are published with proper value,
                // create the final url for weather API
                let finalUrlString = Constants.API.weatherAPIwithImperialMetrics +
                Constants.API.latitudeQuery + "\(latitude)" + Constants.API.ampersand +
                Constants.API.longitudeQuery + "\(longitude)"
                // Pass the final url string to processWeatherDataforURL which
                // can be reused for both types of weather api calls(search based
                // and location based)
                self?.processWeatherDataforURL(finalUrlString, completionHandler: completionHandler)
            } else {
                // Check the location permissions and see if status is turned off,
                // if yes then pass on the control to let view controller know about
                // it so that it can try to fetch weather api using last saved city name
                if !(self?.locationManager.locationPermissionStatus() ?? true) {
                    self?.constructDetailsForDisplay()
                    completionHandler()
                }
            }
        }.store(in: &cancellables)
    }

    /* MARK: Reusable API caller which will parse the response for view controller to use. */
    private func processWeatherDataforURL(_ url: String, completionHandler: @escaping (() -> Void)) {
        // Use the WebserviceManager method and invoke the service.
        self.webserviceManager.callWebservice(urlString: url) {[weak self] result in
            switch result {
            case .failure(let error):
                // In case of failure from WebserviceManager
                self?.errorMessage = Constants.ErrorMessages.networkIssue
                print("error is \(error.rawValue)") // use error.rawValue for remote logging like splunk
            case .success(let data):
                do {
                    // Parse the response data using WeatherModel Model object
                    let parsedWeatherData = try JSONDecoder().decode(WeatherModel.self, from: data)
                    // Icons are dynamic and we need to again call a webservice to get the required icon image
                    let iconURL = String(format: Constants.API.weatherIconUrlFormat, parsedWeatherData.weather[0].icon)
                    DispatchQueue.global().async {
                        // Check if the image is available in our ImageCacheManager singleton object
                        // and the key is the icon name that comes down from the first weather api
                        if let imageIconData = self?.retrieveFromImageCacheForKey(parsedWeatherData.weather[0].icon) {
                            // We update the published "iconImageData" object so that viewcontroller
                            // knows to make use of it through data binding. Just showcasing a mix of
                            // both completionHandler and data binding approaches
                            self?.iconImageData = imageIconData
                            // If image icon available in Cache, we are good and no need to call the api
                            self?.constructDetailsForDisplay(parsedWeatherData)
                            completionHandler()
                        } else {
                            // In case we dont have the image in Cache, call the icon image api
                            self?.webserviceManager.callWebservice(urlString: iconURL) {[weak self] result in
                                switch result {
                                case .failure(let error):
                                    // Image icon Download failed for some reason
                                    print("error is \(error.rawValue)")
                                    // use error.rawValue for remote logging like splunk
                                case .success(let data):
                                    // We have the image downloaded, now we will add it to the ImageCache
                                    self?.addIconToImageCache(data, forKey: parsedWeatherData.weather[0].icon)
                                    // We update the published "iconImageData" object so that viewcontroller
                                    // knows to make use of it through data binding.
                                    let icon = parsedWeatherData.weather[0].icon
                                    self?.iconImageData = self?.retrieveFromImageCacheForKey(icon)
                                    self?.constructDetailsForDisplay(parsedWeatherData)
                                    completionHandler()
                                }
                            }
                        }
                    }
                } catch {
                    // If there was any issue while decoding the response data let the user know through an alert.
                    // Normally this is happening when we give invalid inputs
                    self?.errorMessage = Constants.ErrorMessages.invalidInput
                    self?.currentWeatherData[Constants.Common.status] = Constants.Common.failedStatus
                    completionHandler()
                }
            }
        }
    }
}

// MARK: KeyChainManager wrapper methods
extension WeatherDetailsViewModel {
    // MARK: save the city name for which weather api was successful
    func saveLastSuccessfullySearchedCity(_ city: String) {
        // Setup the required values to save data in keychain
        let service = Constants.KeyChain.keyChainService
        let key = Constants.KeyChain.lastCityKey
        let value = city

        let keychainManager = KeyChainManager()

        // Fetch the city name in key chain
        if let existingLocation = fetchLastSuccessfullySearchedCity() {
            // Check if city name to save is not same as the which is already in keychain
            if existingLocation != city {
                // if different cities, then update the existing cityname in keychain
                if keychainManager.updateSecret(secretService: service, secretKey: key, newSecret: value) {
                    print("Key updated in keychain") // Use for remote logging like splunk
                } else {
                    print("Failed to update key to keychain") // Use for remote logging like splunk
                }
            } else {
                // both cities are same , so no action needed
                print("same as last location") // Use for remote logging like splunk
            }
            // There is nothing saved in keychain yet, so add the first entry
        } else if keychainManager.saveSecret(secretService: service, secretKey: key, secretValue: value) {
            print("Key saved to keychain") // Use for remote logging like splunk
        } else {
            print("Failed to save key to keychain") // Use for remote logging like splunk
        }
    }

    // MARK: Method to fetch existing cityname from keychain
    func fetchLastSuccessfullySearchedCity() -> String? {
        let service = Constants.KeyChain.keyChainService
        let key = Constants.KeyChain.lastCityKey

        let keychainManager = KeyChainManager()

        if let lastLocation = keychainManager.fetchSecret(secretService: service, secretKey: key) {
            return lastLocation
        }
        return nil
    }
}

// MARK: Bussiness Validation methods
extension WeatherDetailsViewModel {
    // Business loggic to check if city Name OR cityName + state code + country code
    // combination was provided by user on search
    func weatherInputValidationStatusPassed(cityName: String, stateCode: String, countryCode: String) -> Bool {
        let cityName = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        let stateCode = stateCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let countryCode = countryCode.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!cityName.isEmpty && stateCode.isEmpty && countryCode.isEmpty) ||
            (!cityName.isEmpty && !stateCode.isEmpty && !countryCode.isEmpty) {
            return true
        }
        return false
    }
}

// MARK: Helper methods for view controller
extension WeatherDetailsViewModel {
    func getCityName() -> String {
        currentWeatherData[Constants.WeatherData.cityName] ?? Constants.Common.notAvailable
    }
    func getTemperature() -> String {
        currentWeatherData[Constants.WeatherData.temperature] ?? Constants.Common.notAvailable
    }
    func getDescription() -> String {
        currentWeatherData[Constants.WeatherData.description] ?? Constants.Common.notAvailable
    }
    func getHighTemperature() -> String {
        currentWeatherData[Constants.WeatherData.highTemperature] ?? Constants.Common.notAvailable
    }
    func getLowTemperature() -> String {
        currentWeatherData[Constants.WeatherData.lowTemperature] ?? Constants.Common.notAvailable
    }
    func getFeelsLiketemperature() -> String {
        currentWeatherData[Constants.WeatherData.feelsLike] ?? Constants.Common.notAvailable
    }
    func getPressureMeasure() -> String {
        currentWeatherData[Constants.WeatherData.pressure] ?? Constants.Common.notAvailable
    }
    func getWindSpeed() -> String {
        currentWeatherData[Constants.WeatherData.wind] ?? Constants.Common.notAvailable
    }
    func weatherDataStatus() -> Bool {
        guard let status: String = currentWeatherData[Constants.Common.status],
              !status.isEmpty else {
            return true
        }
        return status != Constants.Common.failedStatus
    }
}

// MARK: Preparing the data elements for view controller consumption from response object
extension WeatherDetailsViewModel {
    // MARK: Construct the data dictionary that holds latest details
    func constructDetailsForDisplay(_ weatherData: WeatherModel? = nil) {
        currentWeatherData = [:]
        guard let weatherData = weatherData else {
            // No weather model data from response, mainly intented for use cases when
            // location permissions are disabled, so that we can make an attempt to fetch
            // weather details for last saved city.
            currentWeatherData[Constants.Common.status] = Constants.Common.failedStatus
            return
        }
        currentWeatherData[Constants.WeatherData.cityName] = weatherData.cityname
        currentWeatherData[Constants.WeatherData.temperature] =
        "\(weatherData.mainStats.temp)" + Constants.API.degreeSymbol + Constants.Common.farenheitUnit
        currentWeatherData[Constants.WeatherData.description] = weatherData.weather[0].description
        currentWeatherData[Constants.WeatherData.highTemperature] =
        Constants.WeatherData.highTemperatureLabelText + "\(weatherData.mainStats.tempMax)" +
        Constants.API.degreeSymbol + Constants.Common.farenheitUnit
        currentWeatherData[Constants.WeatherData.lowTemperature] =
        Constants.WeatherData.lowTemperatureLabelText + "\(weatherData.mainStats.tempMin)" +
        Constants.API.degreeSymbol + Constants.Common.farenheitUnit
        currentWeatherData[Constants.WeatherData.feelsLike] =
        "\(weatherData.mainStats.feelsLike)" + Constants.API.degreeSymbol +
        Constants.Common.farenheitUnit
    currentWeatherData[Constants.WeatherData.pressure] =
        "\(weatherData.mainStats.pressure)" + Constants.Common.pressureUnit
    currentWeatherData[Constants.WeatherData.wind] =
        "\(weatherData.windConditions.speed)" + Constants.Common.windSpeedUnit
    }
}

// MARK: Image cache wrapper methods
extension WeatherDetailsViewModel {
    // MARK: ImageCacheManager wrapper method for fetching icon from cache
    private func retrieveFromImageCacheForKey(_ key: String) -> Data? {
        ImageCacheManager.shared.retrieveImageDataFromCacheForKey(key)
    }
    // MARK: ImageCacheManager wrapper method for adding icon to cache
    private func addIconToImageCache(_ imageData: Data, forKey key: String) {
        ImageCacheManager.shared.addImageDataToCache(imageData: imageData, usingKey: key)
    }
}
