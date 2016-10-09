//
//  main.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

let testProgram = [
    /* 1: */ Instruction(opCode: .loadi, longArg: 2, arg2: 0),
    /* 2: */ Instruction(opCode: .loadi, longArg: 3, arg2: 1),
    /* 3: */ Instruction(opCode: .lti, arg0: 0, arg1: 1, arg2: 2),
    /* 4: */ Instruction(opCode: .cond, longArg: 6, arg2: 2),
    /* 5: */ Instruction(opCode: .halt),
    /* 6: */ Instruction(opCode: .loadi, longArg: 42, arg2: 11),
    /* 7: */ Instruction(opCode: .halt),
]
let vm = VirtualMachine(program: testProgram)
vm.run()
