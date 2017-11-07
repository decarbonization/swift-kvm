//
//  VirtualMachine.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

struct VirtualMachine {
    // MARK: - Initializers
    
    /**
     Initialize the virtual machine with all required properties.
     
     - parameter program: Program that the virtual machine will interpret.
     - parameter systemCalls: System calls available to the virtual machine's program.
     - parameter stackSize: SIze of the stack that will be provided to `program`.
     */
    init(program: Program,
         systemCalls: SystemCallTable,
         stackSize: UInt16 = 1024) {
        self.program = program
        self.systemCalls = systemCalls
        self.registers = AddressSpace(size: Register.count)
        self.stack = AddressSpace(size: stackSize)
    }
    
    // MARK: - Properties
    
    
    /**
     Program loaded into the virtual machine.
     */
    let program: Program
    
    /**
     System calls available to the virtual machine's program
     */
    let systemCalls: SystemCallTable
    
    /**
     Stack address space provided to the pgoram loaded into the virtual machine.
     */
    var stack: AddressSpace
    
    /**
     Register address space provided to the program loaded into the virtual machine.
     */
    var registers: AddressSpace
    
    /**
     Current position in the program.
     
     This position will be changed in response to an instruction,
     or by the program being interpreted linearly.
     */
    var counter: UInt32 = 0
    
    /**
     Controls whether or not the virtual machine is running.
     
     A virtual machine is started by calling the `run()` method,
     and may be stopped by the program loaded into it.
     */
    var isRunning: Bool = false
    
    // MARK: - Running
    
    /**
     Fetches the instruction at the position specified by the
     counter, advancing the position by one for the next fetch.
     
     - returns: The next instruction to interpret.
     */
    mutating func fetch() -> Instruction {
        let instruction = program[counter]
        counter += 1
        return instruction
    }
    
    /**
     Executes a given instruction from the loaded program
     using the registers and stack of the virtual machine.
     
     This method may trigger any number of side effects, including
     changing the program counter, or triggering syscalls.
     
     - parameter i: Instruction for the virutal machine to interpret.
     */
    mutating func execute(instruction i: Instruction) {
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
        case .sys:
            systemCalls[i.longArg]!(&registers, &stack)
        }
    }
    
    /**
     Execute the program loaded into the virtual machine.
     
     This method will block the calling thread until the virtual
     machine has completed execution of the program.
     
     To determine what work has been performed by the program loaded
     into the virtual machine, the registers and stack may be read.
     */
    mutating func run() {
        counter = 0
        isRunning = true
        
        while isRunning {
            let next = fetch()
            execute(instruction: next)
        }
    }
}
