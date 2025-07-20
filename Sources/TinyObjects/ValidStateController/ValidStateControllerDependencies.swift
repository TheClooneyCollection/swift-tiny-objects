//
//  ValidStateControllerDependencies.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 20/7/2025.
//

public extension ValidStateController {
    struct Dependencies {
        public let work: Work
        public let storage: Storage
        public let validate: Validate

        public init(
            work: @escaping Work,
            storage: Storage,
            validate: @escaping Validate
        ) {
            self.work = work
            self.storage = storage
            self.validate = validate
        }
    }
}

public extension ValidStateController {
    // Should we assume the value is always valid?
    // bc if it is not...
    // 1. we have to do checks after the `work` is done
    // 2. should we retry? and what is the retry policy (.immediate, .static,
    // .custom)
    typealias Work = () async throws(Failure) -> Value

    struct Storage {
        public let load: () -> Value?
        public let save: (Value) -> Void

        public init(
            load: @escaping () -> Value?,
            save: @escaping (Value) -> Void
        ) {
            self.load = load
            self.save = save
        }
    }

    /// Returns `Value` when a value is valid.
    /// Returns `nil` when a value is no longer valid.
    typealias Validate = (Value) -> Value?
}
