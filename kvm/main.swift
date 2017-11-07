//
//  main.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 10/8/16.
//  Copyright © 2016 Kevin MacWhinnie. All rights reserved.
//

import Foundation

let listing = """
_main:
   li 2i, $gpr1
   li 8i, $gpr2
   call @_add
   jmp @exit
_add:
   addi $gpr1, $gpr2, $gpr3
   ret
exit:
   halt
"""
let testProgram = try! Program(listing: listing)
print(testProgram)
var vm = VirtualMachine(program: testProgram)
vm.run()
print(vm.registers.registerDescription)
