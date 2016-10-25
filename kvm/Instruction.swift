//
//  Instruction.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

/**
 *  Enum that describes all possible operation codes that may be packed into an instruction.
 *
 *  The listing names match the intended mnemonics for the virtual machine.
 */
enum OpCode: UInt16 {
    case noop = 0
    case halt
    case jmp
    case cond
    case li
    case addi
    case subi
    case muli
    case divi
    case icri
    case dcri
    case eqi
    case neqi
    case lti
    case ltei
    case gti
    case gtei
    case shli
    case shri
    case andb
    case orb
    case xorb
    case or
    case and
    case push
    case pop
    case call
    case ret
    
    /// Convenience initializer that raises a fatal error if
    /// the op code cannot be initialized from a given value.
    init(_ value: UInt16) {
        self.init(rawValue: value)!
    }
    
    /// Attempts to create an op code from a mnemonic string.
    init?(mnemonic: String) {
        switch mnemonic {
        case "noop":
            self = .noop
        case "halt":
            self = .halt
        case "jmp":
            self = .jmp
        case "cond":
            self = .cond
        case "li":
            self = .li
        case "addi":
            self = .addi
        case "subi":
            self = .subi
        case "muli":
            self = .muli
        case "divi":
            self = .divi
        case "icri":
            self = .icri
        case "dcri":
            self = .dcri
        case "eqi":
            self = .eqi
        case "neqi":
            self = .neqi
        case "lti":
            self = .lti
        case "ltei":
            self = .ltei
        case "gti":
            self = .gti
        case "gtei":
            self = .gtei
        case "shli":
            self = .shli
        case "shri":
            self = .shri
        case "andb":
            self = .andb
        case "orb":
            self = .orb
        case "xorb":
            self = .xorb
        case "or":
            self = .or
        case "and":
            self = .and
        case "push":
            self = .push
        case "pop":
            self = .pop
        case "call":
            self = .call
        case "ret":
            self = .ret
        default:
            return nil
        }
    }
    
    /// Indicates whether or not the op code has a long argument.
    var usesLongArg: Bool {
        switch self {
        case .jmp,
             .cond,
             .li,
             .call:
            return true
        default:
            return false
        }
    }
}

/**
 *  In memory representation of instructions for the virtual machine.
 *  Each instruction is packed into an unsigned 64 bits integer.
 *
 *  0xAAAABBBBCCCCDDDD
 *    |   |   |   |
 *    |   |   |   +----- arg2
 *    |   |   +--------- arg1
 *    |   +------------- arg0
 *    +----------------- opCode
 */
struct Instruction: RawRepresentable, CustomStringConvertible, Hashable {
    typealias RawValue = UInt64
    
    let rawValue: UInt64
    
    // MARK: - Initializers
    
    /// Initialize the instruction with a raw value. This is the designated initializer.
    ///
    /// - parameter rawValue: The raw representation of the instruction.
    init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    /// Initialize the instruction with an op code and all arguments.
    ///
    /// - parameter opCode: The operation code of the instruction.
    /// - parameter arg0: The first argument.
    /// - parameter arg1: The first argument.
    /// - parameter arg2: The first argument.
    init(opCode: OpCode,
         arg0: UInt16,
         arg1: UInt16,
         arg2: UInt16) {
        let packedWord = (
            (UInt64(arg2)) |
            (UInt64(arg1) << 16) |
            (UInt64(arg0) << 32) |
            (UInt64(opCode.rawValue) << 48)
        )
        self.init(rawValue: packedWord)
    }
    
    /// Initialize the instruction with an op code, long argument, and extra argument.
    ///
    /// - parameter opCode: The operation code of the instruction.
    /// - parameter longArg: The long argument stored in `arg0` and `arg1`.
    /// - parameter arg2: The extra argument.
    init(opCode: OpCode,
         longArg: UInt32,
         arg2: UInt16) {
        self.init(opCode: opCode,
                  arg0: UInt16((longArg >> 16) & 0x0000FFFF),
                  arg1: UInt16((longArg) & 0x0000FFFF),
                  arg2: arg2)
    }
    
    /// Initialize the instruction with an op code, and set all args to `0`.
    ///
    /// - parameter opCode: The operation code of the instruction.
    init(opCode: OpCode) {
        self.init(opCode: opCode, arg0: 0, arg1: 0, arg2: 0)
    }
    
    /// Attempt to initialize the instruction with the contents of a data object.
    ///
    /// - parameter data: The data to read the instruction from.
    init?(data: Data) {
        guard data.count == MemoryLayout<RawValue>.size else {
            return nil
        }
        
        var value: UInt64 = 0
        let buffer = UnsafeMutableBufferPointer(start: &value, count: 1)
        guard data.copyBytes(to: buffer) == data.count else {
            return nil
        }
        self.init(rawValue: value)
    }
    
    // MARK: - Properties
    
    /// The operation code of the instruction.
    var opCode: OpCode {
        return OpCode(UInt16((rawValue >> 48) & 0x000000000000FFFF))
    }
    
    /// The first argument of the instruction.
    var arg0: UInt16 {
        return UInt16((rawValue >> 32) & 0x000000000000FFFF)
    }
    
    /// The second argument of the instruction.
    var arg1: UInt16 {
        return UInt16((rawValue >> 16) & 0x000000000000FFFF)
    }
    
    /// The third argument of the instruction.
    var arg2: UInt16 {
        return UInt16(rawValue & 0x000000000000FFFF)
    }
    
    /// The long argument of the instruction, a combination of `arg0` and `arg1`.
    var longArg: UInt32 {
        return (UInt32(arg1) | (UInt32(arg0) << 16))
    }
    
    /// Returns a serializable data representation of the instruction.
    var dataRepresentation: Data {
        var value = rawValue
        return Data(bytes: &value, count: MemoryLayout<RawValue>.size)
    }
    
    // MARK: - Identity
    
    var hashValue: Int {
        return Int(rawValue)
    }
    
    var description: String {
        if (opCode.usesLongArg) {
            return ("\(opCode) " +
                    "0x\(String(longArg, radix: 16)), " +
                    "0x\(String(arg2, radix: 16))")
        } else {
            return ("\(opCode) " +
                    "0x\(String(arg0, radix: 16)), " +
                    "0x\(String(arg1, radix: 16)), " +
                    "0x\(String(arg2, radix: 16))")
        }
    }
}
