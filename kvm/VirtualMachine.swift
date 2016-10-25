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
    let stack: MemoryBank
    let registers: RegisterBank = RegisterBank()
    var counter: UInt32 = 0
    var isRunning: Bool = false
    
    init(program: [Instruction],
         stackSize: UInt16 = 1024) {
        self.program = program
        self.stack = MemoryBank(capacity: stackSize)
    }
    
    // MARK: - Operations
    
    func fetch() -> Instruction {
        let instruction = program[Int(counter)]
        counter += 1
        return instruction
    }
    
    func evaluate(instruction i: Instruction) {
        debugPrint(i)
        
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
        case .icri:
            registers[i.arg2] = Word(registers[i.arg0].int + 1)
        case .dcri:
            registers[i.arg2] = Word(registers[i.arg0].int - 1)
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
        case .shli:
            registers[i.arg2] = Word(registers[i.arg0].int << registers[i.arg1].int)
        case .shri:
            registers[i.arg2] = Word(registers[i.arg0].int >> registers[i.arg1].int)
        case .andb:
            registers[i.arg2] = Word(rawValue: registers[i.arg0].rawValue & registers[i.arg1].rawValue)
        case .orb:
            registers[i.arg2] = Word(rawValue: registers[i.arg0].rawValue | registers[i.arg1].rawValue)
        case .xorb:
            registers[i.arg2] = Word(rawValue: registers[i.arg0].rawValue ^ registers[i.arg1].rawValue)
        case .or:
            registers[i.arg2] = Word(registers[i.arg0].bool || registers[i.arg1].bool)
        case .and:
            registers[i.arg2] = Word(registers[i.arg0].bool && registers[i.arg1].bool)
        case .push:
            stack[registers[.sp].address] = registers[i.arg0]
            registers[.sp] = registers[.sp].next
        case .pop:
            registers[.sp] = registers[.sp].previous
            registers[i.arg0] = stack[registers[.sp].address]
        case .call:
            stack[registers[.sp].address] = Word(rawValue: counter)
            registers[.sp] = registers[.sp].next
            counter = i.longArg
        case .ret:
            registers[.sp] = registers[.sp].previous
            counter = stack[registers[.sp].address].rawValue
        }
    }
    
    func run() {
        counter = 0
        isRunning = true
        
        while isRunning {
            let next = fetch()
            evaluate(instruction: next)
        }
        debugPrint(registers)
    }
}
