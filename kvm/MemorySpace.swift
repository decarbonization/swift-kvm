//
//  MemorySpace.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

// MARK: - Words

/// The `Word` type represents a unit of data in the virtual machine.
///
/// The underlying representation is a `UInt32`, however callers may
/// choose to interpret the word as a signed integer, float, or bool.
/// Reading a different type from what was written is undefined behavior.
struct Word: RawRepresentable, CustomStringConvertible {
    // MARK: - RawRepresentable
    
    typealias RawValue = UInt32
    
    /// The raw, uninterpreted value of the word.
    var rawValue: UInt32
    
    /// Initialize the word with a given raw value. This is the designated initializer.
    ///
    /// - parameter rawValue: The raw value the word will represent.
    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    // MARK: - Initializers
    
    /// A word containing the value `0`.
    static let zero = Word(rawValue: 0)
    
    /// Initialize the word with a given float.
    ///
    /// - parameter float: The float value the word will represent.
    init(_ float: Float32) {
        self.init(rawValue: unsafeBitCast(float, to: UInt32.self))
    }
    
    /// Initialize the word with a given float.
    ///
    /// - parameter int: The integer value the word will represent.
    init(_ int: Int32) {
        self.init(rawValue: unsafeBitCast(int, to: UInt32.self))
    }
    
    /// Initialize the word with a given bool.
    ///
    /// - parameter bool: The bool value the word will represent.
    init(_ bool: Bool) {
        self.init(rawValue: bool ? 1 : 0)
    }
    
    // MARK: - Interpretations
    
    /// Returns the float interpretation of the word.
    var float: Float32 {
        return unsafeBitCast(rawValue, to: Float32.self)
    }
    
    /// Returns the int interpretation of the word.
    var int: Int32 {
        return unsafeBitCast(rawValue, to: Int32.self)
    }
    
    /// Returns the boolean interpretation of the word.
    var bool: Bool {
        return (rawValue != 0)
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        return "0x\(String(rawValue, radix: 16))"
    }
}

// MARK: - Registers

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
    private let storage: UnsafeMutablePointer<Word>
    
    /// The number of registers in the bank.
    private let count: Int
    
    /// Initialize the register bank with a given count and default value.
    ///
    /// - parameter count: The number of registers to allocate.
    /// - parameter defaultValue: The default value to place in the registers. Optional.
    init(count: UInt16, defaultValue: Word = .zero) {
        self.count = Int(count)
        self.storage = UnsafeMutablePointer.allocate(capacity: self.count)
        storage.initialize(to: defaultValue, count: self.count)
    }
    
    deinit {
        storage.deinitialize()
        storage.deallocate(capacity: self.count)
    }
    
    /// Access the value of a register with a specified index.
    subscript(index: UInt16) -> Word {
        get {
            return storage[Int(index)]
        }
        set {
            storage[Int(index)] = newValue
        }
    }
    
    /// Access the value of a register by mnemonic name.
    subscript(register: Register) -> Word {
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
            lines += "\(name) = \(storage[i])\n"
        }
        return lines.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Address Space

/**
 *  Encapsulates the memory space of a virtual machine. This includes registers and stack space.
 */
struct MemorySpace: CustomStringConvertible {
    /// The registers of the memory space.
    let registers: RegisterBank
    
    /// Initialize an empty memory space.
    init() {
        self.registers = RegisterBank(count: 12)
    }
    
    var description: String {
        return "registers:\n\(registers)"
    }
}
