//
//  main.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

let test = [
    Instruction(opCode: .addi, arg0: 1, arg1: 2, arg2: 3),
    Instruction(opCode: .divi, arg0: 4, arg1: 5, arg2: 6),
    Instruction(opCode: .jmp, longArg: 0xffffffff, arg2: 0x1),
]
print(test)
