//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 7/12/21.
//

import Foundation

public class PhoneValidator {
    
    public static func isValidNumber(_ number: String) -> Bool {
        return true
        // FIXME: - NSPredicate format not available on linux
//        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
//        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
//        return phoneTest.evaluate(with: number)
    }
    
}
