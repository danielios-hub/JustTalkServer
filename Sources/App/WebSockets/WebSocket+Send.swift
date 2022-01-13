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
    guard
      let data = try? encoder.encode(message),
      let str = String(data: data, encoding: .utf8)
    else { return }
    
    send(str)
  }
}
