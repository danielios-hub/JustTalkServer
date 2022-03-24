//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 13/1/22.
//

import Vapor

extension WebSocket {
    func send(_ message: SocketMessage) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard
          let data = try? encoder.encode(message),
          let str = String(data: data, encoding: .utf8)
        else { return }
        
        send(str)
  }
    
    func send(_ message: SocketConnected) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
          guard
            let data = try? encoder.encode(message),
            let str = String(data: data, encoding: .utf8)
          else { return }
          
          send(str)
    }
}
