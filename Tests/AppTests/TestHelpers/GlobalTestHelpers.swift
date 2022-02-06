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

func makeCommonSetup(on app: Application) throws -> ((User, Token), User) {
    let (user, anotherUser) = try makeUsers(on: app.db)
    let token = try Token.create(user: user, on: app.db)
    return ((user, token), anotherUser)
}

func makeUsers(on db: Database) throws -> (User, User) {
    let userOne = try User.create(on: db)
    let userTwo = try makeUser(number: "606645453", on: db)
    return (userOne, userTwo)
}

func makeUserToken(on db: Database) throws -> (User, Token) {
    let user = try makeUser(number: "606645453", on: db)
    let token = try Token.create(user: user, on: db)
    return (user, token)
}

func makeUser(number: String, password: String = "1111", on db: Database) throws -> User {
    return try User.create(number: number, password: password, on: db)
}

func makeChat(with chatName: String = "Some chat name", participants: [User], on db: Database) throws -> Chat {
    let participants = participants
    return try Chat.create(name: chatName, users: participants, on: db)
}
