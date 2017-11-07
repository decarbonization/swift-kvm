//
//  Program+Serialization.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/9/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

extension Program {
    /**
     Initialize the instruction stream with a previously serialized
     binary blob representation of a program listing.
     
     - parameter data: Binary blob containing a programing listing.
     */
    init?(data: Data) {
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
        self.init(instructions)
    }
    
    /**
     Serializes the instruction stream's program listing into a binary blob.
     
     - returns: A binary blob representation of the stream's program listing.
     */
    var dataRepresentation: Data {
        var buffer = Data()
        for instruction in listing {
            buffer.append(instruction.dataRepresentation)
        }
        return buffer
    }
}
