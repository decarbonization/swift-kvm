//
//  ListingParser.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

// MARK: - Internal

/// Type that contains the calculated jump offsets for labels in a listing.
private typealias JumpTable = [String: UInt32]

/// The string comment lines start with.
private let commentPrefix = "#"

/// The string label args start with.
private let labelArgPrefix = "@"

/// The string label lines end with.
private let labelSuffix = ":"

/// The string register args start with.
private let registerArgPrefix = "$"

/// The string int args start with.
private let intArgSuffix = "i"

/// The string float args start with.
private let floatArgSuffix = "f"

/// The string that separates args to an instruction.
private let argSeparator = ","


/// Trim the leading and trailing whitespace from a string.
///
/// - parameter string: The string to trim.
/// - returns: A copy of `string` with whitespace trimmed.
private func trimWhitespace(from string: String) -> String {
    return string.trimmingCharacters(in: .whitespacesAndNewlines)
}

/// Trim the given prefix from a string, if the prefix is present in the string.
///
/// - parameter prefix: The prefix to trim.
/// - parameter string: The string to trim the prefix from.
/// - returns: A trimmed copy of `string`.
private func trim(prefix: String, from string: String) -> String {
    if string.hasPrefix(prefix),
        let prefixRange = string.range(of: prefix) {
        return string.substring(from: prefixRange.upperBound)
    } else {
        return string
    }
}

/// Trim the given suffix from a string, if the suffix is present in the string.
///
/// - parameter suffix: The suffix to trim.
/// - parameter string: The string to trim the suffix from.
/// - returns: A trimmed copy of `string`.
private func trim(suffix: String, from string: String) -> String {
    if string.hasSuffix(suffix),
       let suffixRange = string.range(of: suffix, options: [.backwards]) {
        return string.substring(to: suffixRange.lowerBound)
    } else {
        return string
    }
}

/// Returns whether or not a given line string is a comment.
private func isComment(_ string: String) -> Bool {
    return string.hasPrefix(commentPrefix)
}

/// Returns whether or not a given string contains a number.
private func isNumber(_ string: String) -> Bool {
    guard !string.isEmpty else {
        return false
    }
    return ("0"..<"9").contains(string[string.startIndex])
}

// MARK: -

/// Returns the op code contained in a string.
///
/// - parameter lineNumber: The line the op code originated from.
/// - parameter string: A string containing an op code mnemonic.
/// - returns: The op code contained in `string`.
/// - throws: `ListingParseError` if the string is malformed.
private func opCode(on lineNumber: Int, from string: String) throws -> OpCode {
    guard let opCode = OpCode(mnemonic: trimWhitespace(from: string)) else {
        throw ListingParseError.unknownMnemonic(line: lineNumber,
                                                mnemonic: string)
    }
    return opCode
}

/// Returns the int32 contained in a string.
///
/// - parameter lineNumber: the line the int32 originated from.
/// - parameter string: A string containing an int32.
/// - throws: `ListingParseError` if the string is malformed.
private func parseInt32(on lineNumber: Int, from string: String) throws -> UInt32 {
    let intString = trim(suffix: intArgSuffix, from: string)
    if let int32 = Int32(intString) {
        return unsafeBitCast(int32, to: UInt32.self)
    } else {
        throw ListingParseError.badInt(line: lineNumber, rawValue: string)
    }
}

/// Returns the float32 contained in a string.
///
/// - parameter lineNumber: the line the float32 originated from.
/// - parameter string: A string containing an float32.
/// - throws: `ListingParseError` if the string is malformed.
private func parseFloat32(on lineNumber: Int, from string: String) throws -> UInt32 {
    let floatString = trim(suffix: floatArgSuffix, from: string)
    if let float32 = Float32(floatString) {
        return unsafeBitCast(float32, to: UInt32.self)
    } else {
        throw ListingParseError.badFloat(line: lineNumber, rawValue: string)
    }
}

/// Parse an argument from an instruction line.
///
/// - parameter lineNumber: The line the arg originated from.
/// - parameter string: A string containing an argument.
/// - parameter jumpTable: The table containing pre-calculated jumps for labels.
/// - returns: An integer containing the argument's value.
/// - throws: `ListingParseError` if the argument was malformed.
private func parseArg(on lineNumber: Int,
                      from string: String,
                      with jumpTable: JumpTable) throws -> UInt32 {
    if string.hasPrefix(labelArgPrefix) {
        let label = trim(prefix: labelArgPrefix, from: string)
        guard let jumpOffset = jumpTable[label] else {
            throw ListingParseError.badJumpLabel(line: lineNumber, label: string)
        }
        return jumpOffset
    } else if string.hasPrefix(registerArgPrefix), let prefixRange = string.range(of: registerArgPrefix) {
        let register = string.substring(from: prefixRange.upperBound)
        if let registerNumber = UInt32(register) {
            return registerNumber
        } else if let registerName = Register(mnemonic: register) {
            return UInt32(registerName.rawValue)
        } else {
            throw ListingParseError.badRegister(line: lineNumber, rawValue: register)
        }
    } else if isNumber(string) && string.hasSuffix(intArgSuffix) {
        return try parseInt32(on: lineNumber, from: string)
    } else if isNumber(string) && string.hasSuffix(floatArgSuffix) {
        return try parseFloat32(on: lineNumber, from: string)
    } else {
        throw ListingParseError.badArg(line: lineNumber, contents: string)
    }
}

/// Parse an instruction line.
///
/// - parameter lineNumber: The line the instruction originated from.
/// - parameter string: The string containing the line.
/// - parameter jumpTable: The table containing the pre-calculated jumps for labels.
/// - returns: An instruction created from `string`.
/// - throws: `ListingParseError` if the line was malformed.
private func parseInstruction(on lineNumber: Int,
                              from string: String,
                              with jumpTable: JumpTable) throws -> Instruction {
    if let pivot = string.rangeOfCharacter(from: .whitespaces) {
        let code = try opCode(on: lineNumber, from: string.substring(to: pivot.lowerBound))
        let rawArgs = string.substring(from: pivot.upperBound)
                            .components(separatedBy: argSeparator)
                            .map(trimWhitespace(from:))
        let args = try rawArgs.map{ arg in try parseArg(on: lineNumber, from: arg, with: jumpTable) }
        if code.usesLongArg {
            guard args.count <= 2 else {
                throw ListingParseError.tooManyArgs(line: lineNumber)
            }
            let longArg = (args.count > 0) ? args[0] : 0
            let arg2 = UInt16((args.count > 1) ? args[1] : 0)
            return Instruction(opCode: code, longArg: longArg, arg2: arg2)
        } else {
            guard args.count <= 3 else {
                throw ListingParseError.tooManyArgs(line: lineNumber)
            }
            let arg0 = UInt16((args.count > 0) ? args[0] : 0)
            let arg1 = UInt16((args.count > 1) ? args[1] : 0)
            let arg2 = UInt16((args.count > 2) ? args[2] : 0)
            return Instruction(opCode: code, arg0: arg0, arg1: arg1, arg2: arg2)
        }
    } else {
        return Instruction(opCode: try opCode(on: lineNumber, from: string))
    }
}

/// Consume the jump label for a given line.
///
/// - parameter lineNumber: The line the jump label originated from.
/// - parameter string: The string possibly containing the jump label.
/// - returns: true if a jump was found; false otherwise.
private func consumeJumps(on lineNumber: Int,
                          from string: String,
                          with jumpTable: inout JumpTable) -> Bool {
    if string.hasSuffix(labelSuffix) {
        let label = trim(suffix: labelSuffix, from: string)
        jumpTable[label] = UInt32(lineNumber - jumpTable.count)
        return true
    } else {
        return false
    }
}

// MARK: -

/// Returns all of the lines from a given listing.
///
/// - parameter listing: The listing to generate lines for.
/// - returns: A lazy sequence containing lines, with whitespace trimmed.
func allLines(from listing: String) -> LazySequence<[String]> {
    return listing.components(separatedBy: .newlines)
                  .map(trimWhitespace(from:))
                  .lazy
}

// MARK: - API

/// Enum that describes the errors that can occur when parsing a bytecode listing.
enum ListingParseError: Error {
    /// Indicates an unknown mnemonic was encountered.
    case unknownMnemonic(line: Int, mnemonic: String)
    
    /// Indicates too many arguments were included for an instruction.
    case tooManyArgs(line: Int)
    
    /// Indicates a malformed argument was found.
    case badArg(line: Int, contents: String)
    
    /// Indicates a malformed int was found.
    case badInt(line: Int, rawValue: String)
    
    /// Indicates a malformed float was found.
    case badFloat(line: Int, rawValue: String)
    
    /// Indicates a malformed register was found.
    case badRegister(line: Int, rawValue: String)
    
    /// Indicates a bad jump label was found.
    case badJumpLabel(line: Int, label: String)
}

/// Parse the contents of a string containing a bytecode listing.
///
/// - parameter listing: A string containing a bytecode listing.
/// - returns: An array of instructions parsed from the listing.
/// - throws: `ListingParseError` if the listing is malformed.
func parse(listing: String) throws -> [Instruction] {
    let lines = allLines(from: listing)
    var jumpTable = JumpTable()
    return Array(
        try lines.filter{ line in !isComment(line) }
                 .enumerated()
                 .filter { (lineNumber, contents) in
                     return !consumeJumps(on: lineNumber,
                                          from: contents,
                                          with: &jumpTable)
                 }
                 .map { (lineNumber, contents) in
                     return try parseInstruction(on: lineNumber,
                                                 from: contents, 
                                                 with: jumpTable)
                 }
    )
}
