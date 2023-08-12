# WeatherApplication
WeatherApplication makes use APIs provided by "https://openweathermap.org/" and gets weather details based on user location or user inputted cityName, state code and country code. On application launch, user location service authorization is checked and if allowed will make the attempt to fetch weather details of user's current location. If the location services are not enabled or authorized, user has the option to fetch the weather details of a city of his choice. Another feature of this application is that if location services are not available and a city was successfully searched previously, the details of the previous city will be fetched for user's convinience. 

WeatherApplication makes use of MVVM architecture and have a combination of both completionHandler and Combine data binding techniques used. Webservices are handled through a reusable Manager class. Similarly additional reusable manager/helper classes are created for handling location services, Image Caching(NSCache) and saving data in keychain.

The code is well commented for better understanding and well structured. A settings bundle is created for easy testing of location authorization changes and their effect on the application. Size classes are used to handle all combinations. Both unit testcases and UI testcase suite are included, helping with a great code coverage.

