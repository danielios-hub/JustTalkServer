//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 13/1/22.
//

import Foundation

public struct SocketRequest: Codable {
    let token: String
}

public struct SocketMessage: Codable {
    let chatMessages: [Message]
}

public struct SocketConnected: Codable {
    let successfull: Bool
}
