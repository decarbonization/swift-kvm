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
    case loadi
    case addi
    case subi
    case muli
    case divi
    case eqi
    case neqi
    case lti
    case ltei
    case gti
    case gtei
    
    init(_ value: UInt16) {
        self.init(rawValue: value)!
    }
    
    var usesLongArg: Bool {
        switch self {
        case .jmp,
             .cond,
             .loadi:
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
    
    init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
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
    
    init(opCode: OpCode,
         longArg: UInt32,
         arg2: UInt16) {
        self.init(opCode: opCode,
                  arg0: UInt16((longArg >> 16) & 0x0000FFFF),
                  arg1: UInt16((longArg) & 0x0000FFFF),
                  arg2: arg2)
    }
    
    init(opCode: OpCode) {
        self.init(opCode: opCode, arg0: 0, arg1: 0, arg2: 0)
    }
    
    var opCode: OpCode {
        return OpCode(UInt16((rawValue >> 48) & 0x000000000000FFFF))
    }
    
    var arg0: UInt16 {
        return UInt16((rawValue >> 32) & 0x000000000000FFFF)
    }
    
    var arg1: UInt16 {
        return UInt16((rawValue >> 16) & 0x000000000000FFFF)
    }
    
    var arg2: UInt16 {
        return UInt16(rawValue & 0x000000000000FFFF)
    }
    
    var longArg: UInt32 {
        return (UInt32(arg1) | (UInt32(arg0) << 16))
    }
    
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
