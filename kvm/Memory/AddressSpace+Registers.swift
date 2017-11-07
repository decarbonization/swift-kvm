//
//  AddressSpace+Registers.swift
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
    
    /// The tenth general purpose register.
    case gpr10
    
    /// The default number of registers.
    static let count: UInt16 = 12
    
    /// Attempt to initialize a register from a mnemonic string
    init?(mnemonic: String) {
        switch mnemonic {
        case "cond":
            self = .cond
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
        case "gpr10":
            self = .gpr10
        default:
            return nil
        }
    }
}

// MARK: - Extensions

extension AddressSpace {
    /**
     Access the word at the address specified by a register.
     
     - parameter register: Register that specifies an address.
     - returns: The word stored at `register`'s address.
     */
    subscript(register: Register) -> Word {
        get {
            return self[register.rawValue]
        }
        set {
            self[register.rawValue] = newValue
        }
    }
    
    /**
     Describes the address space by interpreting it as containing registers.
     */
    var registerDescription: String {
        var lines = [String]()
        for address in 0..<size {
            guard let register = Register(rawValue: address) else {
                break
            }
            lines.append("\(register): \(self[register])")
        }
        return lines.joined(separator: "\n")
    }
}
