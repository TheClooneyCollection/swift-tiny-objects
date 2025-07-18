//
//  ValidStateController.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 17/7/2025.
//

public actor ValidStateController<
    Value: Equatable & Sendable,
    Error: Swift.Error,
> {
    /// Returns `Value` when a value is valid.
    /// Returns `nil` when a value is no longer valid.
    public typealias Validate = (Value) -> Value?

    public typealias Work = @Sendable () async throws(Error) -> Value

    public struct Storage: Sendable {
        public let load: @Sendable () -> Value?
        public let save: @Sendable (Value) -> Void

        public init(
            load: @escaping @Sendable () -> Value?,
            save: @escaping @Sendable (Value) -> Void
        ) {
            self.load = load
            self.save = save
        }
    }

    public enum State: Equatable & Sendable {
        case initial
        case workInProgress
        case valid(Value)
        case invalid

//        public enum Invalid {
//            case invalidated
//            case timedOut
//            case cancelled
//            case failed(Error)
//        }
    }

    public private(set) var state: State

    private let work: Work
    private let storage: Storage
    private let validate: Validate

    public init(
        work: @escaping Work,
        storage: Storage,
        validate: @escaping Validate
    ) async {
        self.work = work
        self.storage = storage
        self.validate = validate

        state = .initial

        loadState()
    }

    private func loadState() {
        // TODO: should try fetching a new one
        guard let storedValue = storage.load() else {
            state = .invalid

            return
        }
        guard let validValue = validate(storedValue) else {
            state = .invalid
            return
        }

        state = .valid(validValue)
    }

    public func update(value _: Value) {
        // TODO: Check whether value is valid before updating
    }

    public func requestRefresh() {}

    public func forceRefresh() {}

    // ???
    public func cancelRefresh() {}
}
