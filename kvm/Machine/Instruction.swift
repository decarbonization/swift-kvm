//
//  Instruction.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

/**
 Enum that describes all possible operation codes that may be packed into an instruction.
 
 The listing names match the intended mnemonics for the virtual machine.
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
    case sys
    
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
        case "sys":
            self = .sys
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
             .call,
             .sys:
            return true
        default:
            return false
        }
    }
}

/**
 In memory representation of instructions for the virtual machine.
 Each instruction is packed into an unsigned 64 bits integer.
 
 ```
 +--------------------------------+
 | 0xAAAA_BBBB_CCCC_DDDD          |
 |   |    |    |    |             |
 |   |    |    |    +----- arg2   |
 |   |    |    +---------- arg1   |
 |   |    +--------------- arg0   |
 |   +-------------------- opCode |
 +--------------------------------+
 ```
 */
struct Instruction: RawRepresentable, Hashable, CustomStringConvertible {
    // MARK: - Initializers
    
    /**
    Initialize the instruction with an op code and all arguments.
    
    - parameter opCode: Operation code of the instruction.
    - parameter arg0: Zeroth argument.
    - parameter arg1: First argument.
    - parameter arg2: Second argument.
     */
    init(opCode: OpCode,
         arg0: UInt16,
         arg1: UInt16,
         arg2: UInt16) {
        let opCodeBits: UInt64 = (UInt64(opCode.rawValue) << 48)
        let arg0Bits: UInt64 = (UInt64(arg0) << 32)
        let arg1Bits: UInt64 = (UInt64(arg1) << 16)
        let arg2Bits: UInt64 = (UInt64(arg2) << 0)
        self.init(rawValue: (arg2Bits | arg1Bits | arg0Bits | opCodeBits))
    }
    
    /**
     Initialize the instruction with an op code, long argument, and extra argument.
     
     - parameter opCode: Operation code of the instruction.
     - parameter longArg: Long argument stored in `arg0` and `arg1`.
     - parameter arg2: Extra argument.
     */
    init(opCode: OpCode,
         longArg: UInt32,
         arg2: UInt16) {
        self.init(opCode: opCode,
                  arg0: UInt16((longArg >> 16) & 0x0000FFFF),
                  arg1: UInt16((longArg) & 0x0000FFFF),
                  arg2: arg2)
    }
    
    /**
     Initialize the instruction with an op code, and set all args to `0`.
     
     - parameter opCode: Operation code of the instruction.
     */
    init(opCode: OpCode) {
        self.init(opCode: opCode, arg0: 0, arg1: 0, arg2: 0)
    }
    
    /**
    Attempt to initialize the instruction with the contents of a data object.
    
    - parameter data: Data to read the instruction from.
     */
    init?(data: Data) {
        guard data.count == MemoryLayout<RawValue>.size else {
            return nil
        }
        
        var value: UInt64 = 0
        let copiedWholeValue = withUnsafeMutableBytes(of: &value) { buffer in
            data.copyBytes(to: buffer) == data.count
        }
        guard copiedWholeValue else {
            return nil
        }
        self.init(rawValue: value)
    }
    
    // MARK: - Properties
    
    /**
     Operation code of the instruction interpreted by the virtual machine.
     */
    var opCode: OpCode {
        OpCode(UInt16((rawValue >> 48) & 0x000000000000FFFF))
    }
    
    /**
     Zeroth argument of the instruction. Exact meaning depends on `opCode`.
     */
    var arg0: UInt16 {
        UInt16((rawValue >> 32) & 0x000000000000FFFF)
    }
    
    /**
     First argument of the instruction. Exact meaning depends on `opCode`.
     */
    var arg1: UInt16 {
        UInt16((rawValue >> 16) & 0x000000000000FFFF)
    }
    
    /**
     Second argument of the instruction. Exact meaning depends on `opCode`.
     */
    var arg2: UInt16 {
        UInt16(rawValue & 0x000000000000FFFF)
    }
    
    /**
     Long argument interpretation of the instruction. Made by bit ORing the
     values of `arg0` and `arg1` together. Exact meaning depends on `opCode`.
     */
    var longArg: UInt32 {
        (UInt32(arg1) | (UInt32(arg0) << 16))
    }
    
    /**
     Serializable representation of the instruction.
     */
    var dataRepresentation: Data {
        withUnsafePointer(to: rawValue) { value in
            Data(bytes: value, count: MemoryLayout<RawValue>.size)
        }
    }
    
    // MARK: - RawRepresentable
    
    var rawValue: UInt64
    
    init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    // MARK: - Hashable
    
    var hashValue: Int {
        Int(rawValue)
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        if opCode.usesLongArg {
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
