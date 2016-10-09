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
    "    loadi 2i, $0\n" +
    "    loadi 3i, $1\n" +
    "    lti $0, $1, $2\n" +
    "    cond @load42, $2\n" +
    "    jmp @exit\n" +
    "load42:\n" +
    "    loadi 42i, $11\n" +
    "exit:\n" +
    "    halt"
)
let testProgram = try! parse(listing: listing)
let vm = VirtualMachine(program: testProgram)
vm.run()
