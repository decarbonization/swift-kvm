//
//  AddressSpace.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 11/7/17.
//  Copyright © 2017 Kevin MacWhinnie. All rights reserved.
//

import Foundation

/**
 The `AddressSpace` type encapsulates a continuous series
 of words making up the main memory of the virtual machine.
 */
struct AddressSpace: CustomStringConvertible {
    // MARK: - Initializers
    
    /**
     Initialize the address space with a specified size.
     
     - parameter size: Number of words that may be stored in the address space.
     */
    init(size: UInt16) {
        self.storage = AutoPointer(count: Int(size), initialValue: .zero)
    }
    
    // MARK: - Storage
    
    /**
     Auto pointer containing the words of the address space.
     */
    private var storage: AutoPointer<Word>
    
    /**
     Triggers copy on write behavior if there are multiple references
     to the address space instance. Does nothing otherwise.
     */
    private mutating func copyIfNeeded() {
        guard !isKnownUniquelyReferenced(&storage) else {
            return
        }
        self.storage = AutoPointer(copying: storage)
    }
    
    // MARK: - Properties
    
    /**
     Number of words available in the address space.
     */
    var size: UInt16 {
        return UInt16(storage.count)
    }
    
    // MARK: - Accessing Words
    
    /**
     Accesses the word stored at a specified address.
     
     - parameter address: Address for the word to read.
     - returns: The value stored at `address`.
     */
    subscript(_ address: UInt16) -> Word {
        get {
            return storage[Int(address)]
        }
        set {
            self.copyIfNeeded()
            storage[Int(address)] = newValue
        }
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        var lines = [String]()
        for address in 0..<size {
            let word = self[address]
            guard word != .zero else {
                continue
            }
            lines.append("0x\(String(address, radix: 16)): \(word)")
        }
        return lines.joined(separator: "\n")
    }
}
