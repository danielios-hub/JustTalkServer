//
//  PhoneValidatorTests.swift
//  
//
//  Created by Daniel Gallego Peralta on 23/12/21.
//

import XCTest
import App

class PhoneValidatorTests: XCTestCase {

    func test_isValidNumber_shouldReturnTrueWithValidNumbers() {
        let validNumbers = ["606646733", "+34606646733"]
        for number in validNumbers {
            XCTAssert(PhoneValidator.isValidNumber(number))
        }
    }
    
    func test_isValidNumber_shouldReturnFalseWithInvalidNumbers() {
        let validNumbers = ["++1994423565", "606646733ab"]
        for number in validNumbers {
            XCTAssertFalse(PhoneValidator.isValidNumber(number), "number \(number) should be invalid")
        }
    }

}
