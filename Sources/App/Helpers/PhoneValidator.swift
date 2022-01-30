//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 7/12/21.
//

import Foundation

public class PhoneValidator {
    
    private static var minimumLength: Int { 6 }
    
    public static func isValidNumber(_ number: String) -> Bool {
        let notValidCharacters = NSCharacterSet(charactersIn: "+0123456789").inverted
        return number.rangeOfCharacter(from: notValidCharacters) == nil &&
        number.count > minimumLength &&
        number.numberOfOccurrences(of: "+") <= 1
    }
    
}

private extension String {
    func numberOfOccurrences(of value: String) -> Int {
        return max(self.components(separatedBy: value).count - 1, 0)
    }
}
