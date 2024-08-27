//
//  Program.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 11/7/17.
//  Copyright © 2017 Kevin MacWhinnie. All rights reserved.
//

import Foundation

/**
 The `Program` type encapsulates a listing of instructions,
 and manages the program counter for a virtual machine.
 */
struct Program: CustomStringConvertible {
    // MARK: - Initializers
    
    /**
     Initialize the stream with a given array of instructions to run.
     
     - parameter listing: Array containing instructions to interpret.
     */
    init(_ listing: [Instruction]) {
        self.listing = listing
    }
    
    // MARK: - Properties
    
    /**
     Array containing instructions a virtual machine will interpret.
     */
    var listing: [Instruction]
    
    // MARK: - Accessing Instructions
    
    /**
     Accesses the instruction at the specified position in the program's listing.
     
     - parameter index: Position of the instruction to retrieve.
     - returns: The instruction at `index` in the program's listing.
     */
    subscript(_ index: UInt32) -> Instruction {
        get {
            listing[Int(index)]
        }
        set {
            listing[Int(index)] = newValue
        }
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        listing.enumerated()
            .lazy
            .map { (line, instruction) in
                "\(line + 1) \(instruction)"
            }
            .joined(separator: "\n")
    }
}
