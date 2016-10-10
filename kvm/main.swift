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
    "    li 2i, $gpr1\n" +
    "    li 3i, $gpr2\n" +
    "    lti $gpr1, $gpr2, $cond\n" +
    "    cond @load42, $cond\n" +
    "    jmp @exit\n" +
    "load42:\n" +
    "    li 42i, $gpr3\n" +
    "exit:\n" +
    "    halt"
)
let testProgram = try! parse(listing: listing)
let vm = VirtualMachine(program: testProgram)
vm.run()
