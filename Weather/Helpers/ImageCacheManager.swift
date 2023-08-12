//
//  ImageCacheManager.swift
//  Weather
//
//  Created by Jason Jacob on 8/10/23.
// Manager/Helper class for caching Image icons using NSCache internally

import Foundation

class ImageCacheManager {
    // Singleton Object creation
    static let shared = ImageCacheManager()
    // Image Cache will hold image Data as value
    private let imageCache = NSCache<NSString,NSData>()
    
    private init() {
        imageCache.totalCostLimit = 100 * 1024 * 1024 //100 MB
        //        imageCache.countLimit = 100 //optional
    }
    // MARK: Method to add image data to Cache
    func addImageDataToCache(imageData: Data, usingKey key: String) {
        imageCache.setObject(imageData as NSData, forKey: key as NSString)
        
    }
    // MARK: Method to retrieve image data from Cache
    func retrieveImageDataFromCacheForKey(_ key: String) -> Data? {
        if let imageData = imageCache.object(forKey: key as NSString) {
            return imageData as Data
        }
        return nil
    }
}
