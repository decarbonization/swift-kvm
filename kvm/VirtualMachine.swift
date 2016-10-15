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
    var counter: UInt32 = 0
    var isRunning: Bool = false
    
    init(program: [Instruction]) {
        self.program = program
    }
    
    // MARK: - Operations
    
    func fetch() -> Instruction {
        let instruction = program[Int(counter)]
        counter += 1
        return instruction
    }
    
    func evaluate(instruction i: Instruction) {
        debugPrint(i)
        
        let registers = memory.registers
        switch i.opCode {
        case .noop:
            break
        case .halt:
            isRunning = false
        case .jmp:
            counter = i.longArg
        case .cond:
            if registers[i.arg2].bool {
                counter = i.longArg
            }
        case .li:
            registers[i.arg2] = Word(rawValue: i.longArg)
        case .addi:
            registers[i.arg2] = Word(registers[i.arg0].int + registers[i.arg1].int)
        case .subi:
            registers[i.arg2] = Word(registers[i.arg0].int - registers[i.arg1].int)
        case .muli:
            registers[i.arg2] = Word(registers[i.arg0].int * registers[i.arg1].int)
        case .divi:
            registers[i.arg2] = Word(registers[i.arg0].int / registers[i.arg1].int)
        case .eqi:
            let result = (registers[i.arg0].int == registers[i.arg1].int)
            registers[i.arg2] = Word(result)
        case .neqi:
            let result = (registers[i.arg0].int != registers[i.arg1].int)
            registers[i.arg2] = Word(result)
        case .lti:
            let result = (registers[i.arg0].int < registers[i.arg1].int)
            registers[i.arg2] = Word(result)
        case .ltei:
            let result = (registers[i.arg0].int <= registers[i.arg1].int)
            registers[i.arg2] = Word(result)
        case .gti:
            let result = (registers[i.arg0].int > registers[i.arg1].int)
            registers[i.arg2] = Word(result)
        case .gtei:
            let result = (registers[i.arg0].int >= registers[i.arg1].int)
            registers[i.arg2] = Word(result)
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
