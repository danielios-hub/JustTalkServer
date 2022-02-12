//
//  Constants.swift
//  
//
//  Created by Daniel Gallego Peralta on 12/2/22.
//

import Foundation

public enum Constants {
    static let imagesPath: String = "Images/"
    
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
