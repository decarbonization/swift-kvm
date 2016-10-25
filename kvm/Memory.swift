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
    
    /// Initialize the word with a given address.
    ///
    /// - parameter address: The address the word will represent.
    init(_ address: UInt16) {
        self.init(rawValue: UInt32(address))
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
    
    /// Returns the address interpretation of the word.
    var address: UInt16 {
        return UInt16(rawValue)
    }
    
    /// Returns the boolean interpretation of the word.
    var bool: Bool {
        return (rawValue != 0)
    }
    
    var next: Word {
        return Word(rawValue: self.rawValue + 1)
    }
    
    var previous: Word {
        return Word(rawValue: self.rawValue - 1)
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        return "0x\(String(rawValue, radix: 16))"
    }
}

// MARK: - Memory

/// The `MemoryBank` class represents a continuous series of words
/// making up a simple address space in the virtual machine.
open class MemoryBank {
    /// The backing store for the memory.
    private let storage: UnsafeMutablePointer<Word>
    
    /// The maximum number of words that may be stored in the memory.
    let capacity: UInt16
    
    /// Initialize the memory with a given capacity and default value.
    ///
    /// - parameter capacity: The number of words to reserve space for.
    /// - parameter initialValue: The initial value to place in the memory. Optional.
    init(capacity: UInt16, initialValue: Word = .zero) {
        self.capacity = capacity
        self.storage = UnsafeMutablePointer.allocate(capacity: Int(capacity))
        storage.initialize(to: initialValue, count: Int(capacity))
    }
    
    deinit {
        storage.deinitialize()
        storage.deallocate(capacity: Int(capacity))
    }
    
    /// Checks that a given address is valid in the context of the memory.
    ///
    /// - parameter address: The address to check.
    /// - returns: The native representation of `address`.
    /// - throws: `Fault` if `address` is not valid.
    private func checked(address: UInt16) -> Int {
        precondition(address < capacity, "\(address) out of range 0..<\(capacity)")
        return Int(address)
    }
    
    /// Access the value of a word with a specified address.
    subscript(address: UInt16) -> Word {
        get {
            let address = checked(address: address)
            return storage[address]
        }
        set {
            let address = checked(address: address)
            storage[address] = newValue
        }
    }
    
    /// Returns the value of a memory word, clearing the word.
    ///
    /// - parameter address: The address of the cell to read and clear.
    /// - returns: The old value of the cell.
    func consume(address: UInt16) -> Word {
        let address = checked(address: address)
        let value = storage[address]
        storage[address] = .zero
        return value
    }
}

// MARK: - Registers

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

/// A fixed length sequence of `Word` values that
/// represents registers within a virtual machine.
final class RegisterBank: MemoryBank, CustomStringConvertible {
    /// Initialize the register bank with an optional initial register value.
    ///
    /// - parameter initialValue: The initial value to store in the registers. Optional.
    init(initialValue: Word = .zero) {
        super.init(capacity: Register.count, initialValue: initialValue)
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
    
    /// Returns the value of a register, clearing the register.
    ///
    /// - parameter register: The mnemonic of the register to read and clear.
    /// - returns: The old value of the register.
    func consume(register: Register) -> Word {
        return consume(address: register.rawValue)
    }
    
    var description: String {
        var lines = ""
        for i in 0..<capacity {
            let mnemonic = Register(rawValue: i)
            let name = (mnemonic != nil) ? "\(mnemonic!)" : "r\(i)"
            lines += "\(name) = \(self[i])\n"
        }
        return lines.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
