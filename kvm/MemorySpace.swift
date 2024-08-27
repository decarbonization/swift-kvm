//
//  MemorySpace.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

/**
 *  A fixed length sequence of unsigned 32 bit integers that
 *  tracks values read and written within a virtual machine.
 */
class RegisterBank: CustomStringConvertible {
    /// The backing store for the register bank.
    private let storage: UnsafeMutablePointer<UInt32>
    
    /// The number of registers in the bank.
    private let count: Int
    
    /// Initialize the register bank with a given count and default value.
    ///
    /// - parameter count: The number of registers to allocate.
    /// - parameter defaultValue: The default value to place in the registers. Optional.
    init(count: UInt16, defaultValue: UInt32 = 0) {
        self.count = Int(count)
        self.storage = UnsafeMutablePointer.allocate(capacity: self.count)
        storage.initialize(to: defaultValue, count: self.count)
    }
    
    deinit {
        storage.deinitialize()
        storage.deallocate(capacity: self.count)
    }
    
    /// Access the value of a register with a specified index.
    subscript(index: UInt16) -> UInt32 {
        get {
            return storage[Int(index)]
        }
        set {
            storage[Int(index)] = newValue
        }
    }
    
    var description: String {
        var lines = ""
        for index in 0..<count {
            lines += "r\(index) = 0x\(String(storage[index], radix: 16))\n"
        }
        return lines.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/**
 *  A wrapper around the `RegisterBank` class that allows accessing
 *  values stored in the register with different type interpretations
 *  without performing any conversions.
 *
 *  This class must be used with types 32 bits in size. A fatal error
 *  will be raised at runtime if this precondition is violated.
 */
struct RegisterWindow<Value> {
    /// The register bank we're providing a typed window into.
    let registerBank: RegisterBank
    
    /// Access the value of a register with a specified index.
    subscript(index: UInt16) -> Value {
        get {
            return unsafeBitCast(registerBank[index], to: Value.self)
        }
        set {
            registerBank[index] = unsafeBitCast(newValue, to: UInt32.self)
        }
    }
}

/**
 *  Encapsulates the memory space of a virtual machine. This includes registers and stack space.
 */
struct MemorySpace: CustomStringConvertible {
    /// The registers of the memory space.
    let registerBank: RegisterBank
    
    /// An Int32 typed window into the register bank.
    var ints: RegisterWindow<Int32>
    
    /// Initialize an empty memory space.
    init() {
        self.registerBank = RegisterBank(count: 12)
        self.ints = RegisterWindow(registerBank: registerBank)
    }
    
    var description: String {
        return "registers:\n\(registerBank)"
    }
}
