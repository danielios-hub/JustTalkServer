//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 7/12/21.
//

import Foundation

class PhoneValidator {
    
    static func isValidNumber(_ number: String) -> Bool {
        return Int(number) != nil ? true : false
    }
    
}
