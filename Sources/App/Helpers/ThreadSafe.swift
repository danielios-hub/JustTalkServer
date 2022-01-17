//
//  ThreadSafe.swift
//  
//
//  Created by Daniel Gallego Peralta on 17/1/22.
//

import Foundation

@propertyWrapper
struct ThreadSafe<Value> {
    
    var value: Value
    let lock = NSLock()
    
    init(wrappedValue value: Value) {
        self.value = value
    }
    
    var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        
        set {
            lock.lock()
            defer { lock.unlock() }
            value = newValue
        }
    }
}
