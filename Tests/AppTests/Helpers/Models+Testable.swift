//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

@testable import App
import Fluent

extension Phone {
    static func create(number: String = "123456", on db: Database) throws -> Phone {
        let phone =  Phone(number: number)
        try phone.save(on: db).wait()
        return phone
    }
}
