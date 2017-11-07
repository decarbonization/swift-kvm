//
//  Word.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 11/7/17.
//  Copyright © 2017 Kevin MacWhinnie. All rights reserved.
//

import Foundation

/**
 The `Word` type represents a unit of data in the virtual machine.
 
 The underlying representation is a `UInt32`, however callers may
 choose to interpret the word as a signed integer, float, or bool.
 Reading a different type from what was written is undefined behavior.
 */
struct Word: RawRepresentable, CustomStringConvertible {
    // MARK: - Initializers
    
    /**
     An empty word contianing zero.
     */
    static let zero: Word = Word(rawValue: 0)
    
    /**
     Initialize the word with a signed integer value.
     
     - parameter int: Integer value whose bit representation
     will be packed into the word.
     */
    init(_ int: Int32) {
        self.init(rawValue: UInt32(bitPattern: int))
    }
    
    /**
     Initialize the word with a bool value.
     
     - parameter bool: Bool value which will be represented as
     either `0` or `1` by the word.
     */
    init(_ bool: Bool) {
        self.init(rawValue: bool ? 1 : 0)
    }
    
    /**
     Initialize the word with a memory address.
     
     - parameter address: A memory address that will be converted
     into the native representation of the `Word` type.
     */
    init(_ address: UInt16) {
        self.init(rawValue: UInt32(address))
    }
    
    // MARK: - Interpretations
    
    /**
     Interpret the word as a signed integer.
     */
    var int: Int32 {
        return Int32(bitPattern: rawValue)
    }
    
    /**
     Interpret the word as a bool. Any non-zero word value is `true`.
     */
    var bool: Bool {
        return (rawValue != 0)
    }
    
    /**
     Interpret the word as a memory address.
     */
    var address: UInt16 {
        return UInt16(rawValue)
    }
    
    /**
     Advances to the next word and returns it.
     */
    var next: Word {
        return Word(rawValue: self.rawValue + 1)
    }
    
    /**
     Regresses to the previous word and returns it.
     */
    var previous: Word {
        return Word(rawValue: self.rawValue - 1)
    }
    
    // MARK: - RawRepresentable
    
    typealias RawValue = UInt32
    
    var rawValue: UInt32
    
    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        return "0x\(String(rawValue, radix: 16))"
    }
}
