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
        public let retryPolicy: RetryPolicy

        public init(
            work: @escaping Work,
            storage: Storage,
            validate: @escaping Validate,
            retryPolicy: RetryPolicy,
        ) {
            self.work = work
            self.storage = storage
            self.validate = validate
            self.retryPolicy = retryPolicy
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

    enum RetryPolicy {
        /// `noRetry` **allows** the initial `work` call if there’s no valid cached value,
        /// but prevents any subsequent retry attempts.
        case noRetry
        case immediate
    }

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
