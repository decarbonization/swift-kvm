//
//  SystemCall.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 11/7/17.
//  Copyright © 2017 Kevin MacWhinnie. All rights reserved.
//

import Foundation

/**
 Prototype of a function that maybe be called by
 a virtual machine interpreting a program.
 
 - parameter registers: Reference to the register address space of the virtual
  machine. The system call may read and modify this memory as needed.
 - parameter stack: Reference to the stack address space of the virtual
 machine. The system call may read and modify this memory as needed.
 */
typealias SystemCall = (_ registers: inout AddressSpace, _ stack: inout AddressSpace) -> Void

/**
 Type encapsulating a mapping of system calls to numbers
 that may be accessed through the `sys` instruction.
 */
typealias SystemCallTable = [UInt32: SystemCall]
