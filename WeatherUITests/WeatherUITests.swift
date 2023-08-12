//
//  WeatherUITests.swift
//  WeatherUITests
//
//  Created by Jason Jacob on 8/9/23.
//

import XCTest

final class WeatherUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSearchButtonTapWithoutEnteringInputs() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let searchButton = XCUIApplication().buttons["searchButton"]
        searchButton.tap()
        let alert = app.alerts["Alert"]
        XCTAssertTrue(alert.exists)
        
        let message = alert.staticTexts["Please provide a valid combination of inputs!\n It is either just city name OR city name, state code and country code together!"]
        XCTAssertTrue(message.exists)
        
        let okButton = alert.buttons["OK"]
        okButton.tap()
        
        XCTAssertFalse(alert.exists)
    }
    
    func testSearchButtonTapWithInvalidCityName() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        let citytextField = app.textFields["cityName"]
        citytextField.tap() // Activate the text field
        citytextField.clearText()
        citytextField.typeText("nkjhd")
        app/*@START_MENU_TOKEN@*/.buttons["return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[1]]@END_MENU_TOKEN@*/.tap()
        
        let searchButton = XCUIApplication().buttons["searchButton"]
        searchButton.tap()
        
        let alert = app.alerts["Alert"]
        XCTAssertTrue(alert.exists)
        
        let message = alert.staticTexts["It seems you have entered a invalid inputs. Please check and retry again!"]
        XCTAssertTrue(message.exists)
        
        let okButton = alert.buttons["OK"]
        okButton.tap()
        
        XCTAssertFalse(alert.exists)
        
        let feelsLikeLabelText = app.staticTexts["Feels like"]
        XCTAssertFalse(feelsLikeLabelText.exists)
    }
    
    func testSearchButtonTapWithValidCityName() throws {
        let app = XCUIApplication()
        app.launch()
        let citytextField = app.textFields["cityName"]
        citytextField.tap()
        citytextField.clearText()
        citytextField.typeText("Chicago")
        app/*@START_MENU_TOKEN@*/.buttons["return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[1]]@END_MENU_TOKEN@*/.tap()
        
        let searchButton = XCUIApplication().buttons["searchButton"]
        searchButton.tap()
        
        let cityName = app.staticTexts["Chicago"]
        XCTAssertTrue(cityName.exists)
        
        let feelsLikeLabelText = app.staticTexts["Feels like"]
        XCTAssertTrue(feelsLikeLabelText.exists)
    }
    
    func testCurrentLocationSearch() throws {
        let app = XCUIApplication()
        app.launch()
        
        let expectation = XCTestExpectation(description: "Load weather details from current Location")
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                let message = app.staticTexts[" Current Location"]
                XCTAssertTrue(message.exists)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5)
    }
    
}
extension XCUIElement {
    func clearText() {
        guard let currentValue = value as? String else { return }
        
        tap()
        
        // Use backspace to clear text
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        typeText(deleteString)
    }
}
