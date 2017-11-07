//
//  ProgramSerialization.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/9/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

/// Creates a data representation from a program.
///
/// - parameter program: The program instructions to serialize to data.
/// - returns: A data object containing `program`.
func data(fromProgram program: [Instruction]) -> Data {
    var buffer = Data()
    for instruction in program {
        buffer.append(instruction.dataRepresentation)
    }
    return buffer
}

/// Creates a program from a data representation.
///
/// - parameter data: The data containing the program instructions to deserialize.
/// - returns: An array of instructions for the program if `data` was well-formed; nil otherwise.
func program(fromData data: Data) -> [Instruction]? {
    let step = MemoryLayout<Instruction.RawValue>.size
    guard (data.count % step) == 0 else {
        return nil
    }
    
    var instructions = [Instruction]()
    for index in 0..<(data.count / step) {
        let start = (step * index)
        let end = (start + step)
        let rawInstruction = data[start..<end]
        guard let instruction = Instruction(data: Data(rawInstruction)) else {
            continue
        }
        instructions.append(instruction)
    }
    return instructions
}
