//
//  WebserviceManager.swift
//  Weather
//
//  Created by Jason Jacob on 8/9/23.
// WebserviceManager is a reusable component which can take
// any url as a string and provide back with the response data to the caller.

import Foundation

// MARK: Custom Error enum to classify the errors on web service call
enum APIError: String, Error {
    case urlConstructionError = "Failed to construct url"
    case errorOnDownload = "Error on downloading data"
    case responseDataError = "Data Error on download"
}

class WebserviceManager {
    // MARK: Calling webservice using URLSession
    func callWebservice(urlString: String, completionHandler: @escaping ((Result<Data, APIError>) -> Void)) {
        // Attempt to construct a url from input string
        guard let urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlString) else {
            // pass custom error back to caller
            completionHandler(.failure(.urlConstructionError))
            return
        }
        // Call webservice
        URLSession.shared.dataTask(with: url) { data, _, error in
            // Ensure no error to proceed
            guard error == nil else {
                // pass custom error back to caller
                completionHandler(.failure(.errorOnDownload))
                return
            }
            //  Ensure viable data is coming back from server
            guard let responseData = data else {
                // pass custom error back to caller
                completionHandler(.failure(.responseDataError))
                return
            }
            // pass the successful data back to caller
            completionHandler(.success(responseData))
        }.resume()
    }
}
