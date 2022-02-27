//
//  Constants.swift
//  
//
//  Created by Daniel Gallego Peralta on 12/2/22.
//

import Foundation

public enum Constants {
    static let imagesPath: String = "Images/"
    static private let baseDomain = "danieldgp.es:8080/"
    
    public enum Scheme: String {
        case http = "http://"
        case socket = "ws://"
    }
    
    public static func baseURL(withScheme scheme: Scheme) -> URL {
        return URL(string: "\(scheme.rawValue)\(baseDomain)")!
    }
    
    public static func imageAbsoluteURL(with imageName: String) -> String {
        return baseURL(withScheme: .http).absoluteString + imagesPath + imageName
    }
    
    public static func imageRelativeURL(with imageName: String) -> String {
        return imagesPath + imageName
    }
    
    public static func imagesFolderURL(with workingDirectory: String) -> String {
        return workingDirectory + Constants.imagesPath
    }
    
    public static func imageURL(with workingDirectory: String, imageName: String) -> String {
        return imagesFolderURL(with: workingDirectory) + imageName
    }
}
