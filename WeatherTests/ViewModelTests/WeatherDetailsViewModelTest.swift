//
//  WeatherDetailsViewModelTest.swift
//  WeatherTests
//
//  Created by Jason Jacob on 8/11/23.
//

import XCTest
import Security

@testable import Weather

final class WeatherDetailsViewModelTest: XCTestCase {
    
    var sut: WeatherDetailsViewModel?
    
    override func setUpWithError() throws {
        sut = WeatherDetailsViewModel()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut?.errorMessage = ""
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.KeyChain.keyChainService,
            kSecAttrAccount as String: Constants.KeyChain.lastCityKey
        ]
        _ = SecItemDelete(query as CFDictionary)
    }
    
    func testFetchWeatherDetailsWithInvalidInputCombination1() {
        sut?.fetchWeatherDetails(cityName: "", completionHandler: {[weak self] in
            XCTAssertEqual(self?.sut?.errorMessage, Constants.ErrorMessages.invalidInputCombination)
        })
    }
    func testFetchWeatherDetailsWithInvalidInputCombination2() {
        sut?.fetchWeatherDetails(cityName: nil, completionHandler: {[weak self] in
            XCTAssertEqual(self?.sut?.errorMessage, Constants.ErrorMessages.invalidInputCombination)
        })
    }
    func testFetchWeatherDetailsWithInvalidInputCombination3() {
        sut?.fetchWeatherDetails(cityName: nil, stateCode: "", countryCode: "IN", completionHandler: {[weak self] in
            XCTAssertEqual(self?.sut?.errorMessage, Constants.ErrorMessages.invalidInputCombination)
        })
    }
    func testFetchWeatherDetailsWithInvalidInputCombination4() {
        sut?.fetchWeatherDetails(cityName: " ", stateCode: "", countryCode: "IN", completionHandler: {[weak self] in
            XCTAssertEqual(self?.sut?.errorMessage, Constants.ErrorMessages.invalidInputCombination)
        })
    }
    func testFetchWeatherDetailsWithInvalidInputCombination5() {
        sut?.fetchWeatherDetails(cityName: "Riverdale", stateCode: "NY", countryCode: "", completionHandler: {[weak self] in
            XCTAssertEqual(self?.sut?.errorMessage, Constants.ErrorMessages.invalidInputCombination)
        })
    }
    func testFetchWeatherDetailsWithInvalidInputCombination6() {
        sut?.fetchWeatherDetails(cityName: "Riverdale", stateCode: "NY", countryCode: nil, completionHandler: {[weak self] in
            XCTAssertEqual(self?.sut?.errorMessage, Constants.ErrorMessages.invalidInputCombination)
        })
    }
    func testFetchWeatherDetailsWithInvalidInputCombination7() {
        sut?.fetchWeatherDetails(cityName: "Riverdale", stateCode: "NY", countryCode: "  ", completionHandler: {[weak self] in
            XCTAssertEqual(self?.sut?.errorMessage, Constants.ErrorMessages.invalidInputCombination)
        })
    }
    func testWeatherInputValidationStatusPassedInvalidCombination1() {
       XCTAssertFalse(sut?.weatherInputValidationStatusPassed(cityName: "", stateCode: "", countryCode: "") ?? true)
    }
    func testWeatherInputValidationStatusPassedInvalidCombination2() {
        XCTAssertFalse(sut?.weatherInputValidationStatusPassed(cityName: "  ", stateCode: "KL", countryCode: "IN") ?? true)
    }
    func testWeatherInputValidationStatusPassedInvalidCombination3() {
        XCTAssertFalse(sut?.weatherInputValidationStatusPassed(cityName: "White Plains", stateCode: "NY", countryCode: "") ?? true)
    }
    func testWeatherInputValidationStatusPassedInvalidCombination4() {
        XCTAssertFalse(sut?.weatherInputValidationStatusPassed(cityName: "White Plains", stateCode: "NY", countryCode: " ") ?? true)
    }
    func testWeatherInputValidationStatusPassedValidCombination() {
        XCTAssertTrue(sut?.weatherInputValidationStatusPassed(cityName: "White Plains", stateCode: "", countryCode: "") ?? false)
    }
    func testWeatherInputValidationStatusPassedValidCombination1() {
        XCTAssertTrue(sut?.weatherInputValidationStatusPassed(cityName: "White Plains", stateCode: "NY", countryCode: "USA") ?? false)
    }
    
    func testFetchWeatherDetailsWithInvalidCity() {
        let failedAPIcallExpectation = XCTestExpectation(description: "API should fail because of invalid city name")
        sut?.fetchWeatherDetails(cityName: "jkbhdk", completionHandler: {[weak self] in
            XCTAssertEqual(self?.sut?.errorMessage, Constants.ErrorMessages.invalidInput)
            XCTAssertEqual(self?.sut?.getCityName(), Constants.Common.notAvailable)
            XCTAssertEqual(self?.sut?.getDescription(), Constants.Common.notAvailable)
            XCTAssertEqual(self?.sut?.getHighTemperature(), Constants.Common.notAvailable)
            XCTAssertEqual(self?.sut?.getLowTemperature(), Constants.Common.notAvailable)
            XCTAssertEqual(self?.sut?.getFeelsLiketemperature(), Constants.Common.notAvailable)
            XCTAssertEqual(self?.sut?.getPressureMeasure(), Constants.Common.notAvailable)
            XCTAssertEqual(self?.sut?.getWindSpeed(), Constants.Common.notAvailable)
            failedAPIcallExpectation.fulfill()
        })
        wait(for: [failedAPIcallExpectation], timeout: 5)
    }
    
    func testFetchWeatherDetailsWithCity() {
        let successAPIcallExpectation = XCTestExpectation(description: "API should pass because of valid city name")
        sut?.fetchWeatherDetails(cityName: "White Plains", completionHandler: {[weak self] in
            XCTAssertEqual(self?.sut?.errorMessage, "")
            XCTAssertEqual(self?.sut?.currentWeatherData[Constants.WeatherData.cityName], "White Plains")
            XCTAssertEqual(self?.sut?.getCityName(), "White Plains")
            XCTAssertNotNil(self?.sut?.getTemperature())
            XCTAssertNotNil(self?.sut?.getDescription())
            XCTAssertNotNil(self?.sut?.getHighTemperature())
            XCTAssertNotNil(self?.sut?.getLowTemperature())
            XCTAssertNotNil(self?.sut?.getFeelsLiketemperature())
            XCTAssertNotNil(self?.sut?.getPressureMeasure())
            XCTAssertNotNil(self?.sut?.getWindSpeed())
            XCTAssertTrue(self?.sut?.weatherDataStatus() ?? false)
            successAPIcallExpectation.fulfill()
        })
        wait(for: [successAPIcallExpectation], timeout: 5)
    }
    
    func testFetchWeatherUsingCurrentLocation() {
        let successAPIcallExpectation = XCTestExpectation(description: "API should pass because location services are enabled")
        sut?.fetchWeatherUsingCurrentLocation(completionHandler: {[weak self] in
            XCTAssertEqual(self?.sut?.errorMessage, "")
            XCTAssertNotNil(self?.sut?.currentWeatherData[Constants.WeatherData.cityName])
            successAPIcallExpectation.fulfill()
        })
        wait(for: [successAPIcallExpectation], timeout: 5)
    }
    
    func testSaveLastSuccessfullySearchedCity() {
        sut?.saveLastSuccessfullySearchedCity("TestCity")
        XCTAssertEqual(sut?.fetchLastSuccessfullySearchedCity(), "TestCity")
    }
    
    func testSaveLastSuccessfullySearchedSameCity() {
        sut?.saveLastSuccessfullySearchedCity("TestCity1")
        sut?.saveLastSuccessfullySearchedCity("TestCity1")
        XCTAssertEqual(sut?.fetchLastSuccessfullySearchedCity(), "TestCity1")
    }
    
    func testUpdateLastSuccessfullySearchedSCity() {
        sut?.saveLastSuccessfullySearchedCity("TestCity1")
        sut?.saveLastSuccessfullySearchedCity("TestCity2")
        XCTAssertEqual(sut?.fetchLastSuccessfullySearchedCity(), "TestCity2")
    }
    
    func testConstructDetailsForDisplayNegative() {
        sut?.constructDetailsForDisplay(nil)
        XCTAssertEqual(sut?.currentWeatherData[Constants.Common.status], Constants.Common.failedStatus)
    }
    
}

