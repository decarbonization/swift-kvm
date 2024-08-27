//
//  AutoPointer.swift
//  kvm
//
//  Created by Kevin MacWhinnie on 11/7/17.
//  Copyright © 2017 Kevin MacWhinnie. All rights reserved.
//

import Foundation

/**
 The `AutoPointer` type provides a partially safe API for interacting with raw memory.
 The raw memory is created and destroyed along with the auto pointer.
 */
final class AutoPointer<Contained> {
    // MARK: - Initializers
    
    /**
     Initialize the auto pointer with a count and an initial value
     to store in each index of the auto pointer's storage.
     
     - parameter count: Number of values that will be contained in the auto pointer.
     - parameter initialValue: Initial value for all valid indices in the auto pointer.
     */
    init(count: Int, initialValue: Contained) {
        self.count = count
        self.storage = UnsafeMutablePointer.allocate(capacity: count)
        storage.initialize(repeating: initialValue, count: count)
    }
    
    /**
     Initialize the auto pointer with the storage of another auto pointer.
     
     - parameter other: The other auto pointer to copy the storage of.
     */
    init(copying other: AutoPointer<Contained>) {
        self.count = other.count
        self.storage = UnsafeMutablePointer.allocate(capacity: count)
        storage.update(from: other.storage, count: other.count)
    }
    
    deinit {
        storage.deinitialize(count: count)
        storage.deallocate()
    }
    
    // MARK: - Properties
    
    /**
     Number of values contained in the auto pointer.
     */
    let count: Int
    
    /**
     Indices that are valid for subscripting the auto pointer.
     */
    var indices: CountableRange<Int> {
        return (0 ..< count)
    }
    
    // MARK: - Storage
    
    /**
     Backing memory for the auto pointer. Created and destroyed
     alongside the lifecycle of the auto pointer instance
     */
    private let storage: UnsafeMutablePointer<Contained>
    
    /**
     Calls a closure with a pointer to the auto pointer's contiguous storage.
     
     - parameter body: Closure with an `UnsafeBufferPointer` parameter that
     points to the contiguous storage for the auto pointer.
     - returns: The return value, if any, of the `body` closure parameter.
     */
    func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Contained>) throws -> R) rethrows -> R {
        let buffer = UnsafeBufferPointer<Contained>(start: storage, count: count)
        return try body(buffer)
    }
    
    // MARK: - Accessing Values
    
    /**
     Verifies that a given index is within the valid range
     of the auto pointer, raising a fatal error if it is not.
     
     - parameter index: The index to verify is in range.
     */
    private func assertInRange(_ index: Int) {
        let validIndices = self.indices
        precondition(validIndices.contains(index),
                     "Index \(index) is not in range \(validIndices)")
    }
    
    /**
     Accesses the value in the auto pointer's storage at a specified index.
     
     - parameter index: Position of the element stored in the auto pointer.
     */
    subscript(_ index: Int) -> Contained {
        get {
            assertInRange(index)
            return storage[index]
        }
        set {
            assertInRange(index)
            storage[index] = newValue
        }
    }
}
