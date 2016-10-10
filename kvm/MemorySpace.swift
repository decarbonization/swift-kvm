//
//  MemorySpace.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

/// Enum that provides mnemonic names for registers.
enum Register: UInt16 {
    /// The condition register. Must be non-`0` for `cond` to perform a jump.
    case cond
    
    /// The return address register.
    case ret
    
    /// The stack pointer register.
    case sp
    
    /// The first general purpose register. Contains the return
    /// value and first argument of functions by convention.
    case gpr1
    
    /// The second general purpose register.
    case gpr2
    
    /// The third general purpose register.
    case gpr3
    
    /// The fourth general purpose register.
    case gpr4
    
    /// The fifth general purpose register.
    case gpr5
    
    /// The sixth general purpose register.
    case gpr6
    
    /// The seventh general purpose register.
    case gpr7
    
    /// The eighth general purpose register.
    case gpr8
    
    /// The nineth general purpose register.
    case gpr9
    
    /// Attempt to initialize a register from a mnemonic string
    init?(mnemonic: String) {
        switch mnemonic {
        case "cond":
            self = .cond
        case "ret":
            self = .ret
        case "sp":
            self = .sp
        case "gpr1":
            self = .gpr1
        case "gpr2":
            self = .gpr2
        case "gpr3":
            self = .gpr3
        case "gpr4":
            self = .gpr4
        case "gpr5":
            self = .gpr5
        case "gpr6":
            self = .gpr6
        case "gpr7":
            self = .gpr7
        case "gpr8":
            self = .gpr8
        case "gpr9":
            self = .gpr9
        default:
            return nil
        }
    }
}

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
    
    /// Access the value of a register by mnemonic name.
    subscript(register: Register) -> UInt32 {
        get {
            return self[register.rawValue]
        }
        set {
            self[register.rawValue] = newValue
        }
    }
    
    var description: String {
        var lines = ""
        for i in 0..<count {
            let mnemonic = Register(rawValue: UInt16(i))
            let name = (mnemonic != nil) ? "\(mnemonic!)" : "r\(i)"
            lines += "\(name) = 0x\(String(storage[i], radix: 16))\n"
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
