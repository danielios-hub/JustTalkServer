//
//  GlobalTestHelpers.swift
//  
//
//  Created by Daniel Gallego Peralta on 7/12/21.
//

import Vapor
import Fluent
@testable import App

func getPhoneURI() -> String {
    return "api/phones/validate"
}

func getLoginURI() -> String {
    return "api/login"
}

func anyInvalidPhone() -> String {
    return "12sd33f"
}

func anyvalidPhone() -> String {
    return "606646712"
}

func anyValidVerificationCode() -> String {
    return "1111"
}

func makeUsers(on db: Database) throws -> (User, User) {
    let userOne = try User.create(on: db)
    let userTwo = try User.create(number: "606645453", password: "1111", on: db)
    return (userOne, userTwo)
}

func makeChat(with chatName: String = "Some chat name", participants: [User], on db: Database) throws -> Chat {
    let participants = participants
    return try Chat.create(name: chatName, users: participants, on: db)
}
