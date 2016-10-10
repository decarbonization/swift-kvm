//
//  VirtualMachine.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

class VirtualMachine {
    let program: [Instruction]
    var memory: MemorySpace = MemorySpace()
    var counter: Int = 0
    var isRunning: Bool = false
    
    init(program: [Instruction]) {
        self.program = program
    }
    
    // MARK: - Operations
    
    func fetch() -> Instruction {
        let instruction = program[counter]
        counter += 1
        return instruction
    }
    
    func evaluate(instruction: Instruction) {
        debugPrint(instruction)
        
        switch instruction.opCode {
        case .noop:
            break
        case .halt:
            isRunning = false
        case .jmp:
            counter = Int(instruction.longArg)
        case .cond:
            if memory.ints[instruction.arg2] != 0 {
                counter = Int(instruction.longArg)
            }
        case .li:
            memory.ints[instruction.arg2] = Int32(instruction.longArg)
        case .addi:
            memory.ints[instruction.arg2] = memory.ints[instruction.arg0] + memory.ints[instruction.arg1]
        case .subi:
            memory.ints[instruction.arg2] = memory.ints[instruction.arg0] - memory.ints[instruction.arg1]
        case .muli:
            memory.ints[instruction.arg2] = memory.ints[instruction.arg0] * memory.ints[instruction.arg1]
        case .divi:
            memory.ints[instruction.arg2] = memory.ints[instruction.arg0] / memory.ints[instruction.arg1]
        case .eqi:
            let result = (memory.ints[instruction.arg0] == memory.ints[instruction.arg1])
            memory.ints[instruction.arg2] = Int32(result ? 1 : 0)
        case .neqi:
            let result = (memory.ints[instruction.arg0] != memory.ints[instruction.arg1])
            memory.ints[instruction.arg2] = Int32(result ? 1 : 0)
        case .lti:
            let result = (memory.ints[instruction.arg0] < memory.ints[instruction.arg1])
            memory.ints[instruction.arg2] = Int32(result ? 1 : 0)
        case .ltei:
            let result = (memory.ints[instruction.arg0] <= memory.ints[instruction.arg1])
            memory.ints[instruction.arg2] = Int32(result ? 1 : 0)
        case .gti:
            let result = (memory.ints[instruction.arg0] > memory.ints[instruction.arg1])
            memory.ints[instruction.arg2] = Int32(result ? 1 : 0)
        case .gtei:
            let result = (memory.ints[instruction.arg0] >= memory.ints[instruction.arg1])
            memory.ints[instruction.arg2] = Int32(result ? 1 : 0)
        }
    }
    
    func run() {
        counter = 0
        isRunning = true
        
        while isRunning {
            let next = fetch()
            evaluate(instruction: next)
        }
        debugPrint(memory)
    }
}
