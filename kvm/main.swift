//
//  main.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

let listing = (
    "_main:\n" +
    "   li 2i, $gpr1\n" +
    "   li 8i, $gpr2\n" +
    "   call @_add\n" +
    "   jmp @exit\n" +
    "_add:\n" +
    "   addi $gpr1, $gpr2, $gpr3\n" +
    "   ret\n" +
    "exit:\n" +
    "   halt"
)
let testProgram = try! parse(listing: listing)
let vm = VirtualMachine(program: testProgram)
vm.run()
