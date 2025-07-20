//
//  ValidStateController.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 17/7/2025.
//

public actor ValidStateController<
    Value: Sendable,
    Error: Swift.Error,
> {
    /// Returns `Value` when a value is valid.
    /// Returns `nil` when a value is no longer valid.
    public typealias Validate = @Sendable (Value) -> Value?

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

    public enum State: Sendable {
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
        guard let storedValue = storage.load() else {
            state = .invalid

            requestRefresh()
            return
        }

        update(value: storedValue)
    }

    /// Update the state based on whether the value is valid
    /// If the state is not valid, it will request a refresh.
    public func update(value: Value) {
        guard let validValue = validate(value) else {
            state = .invalid

            requestRefresh()
            return
        }

        state = .valid(validValue)
    }

    public func requestRefresh() {}

    public func forceRefresh() {}

    // ???
    public func cancelRefresh() {}
}

extension ValidStateController.State: Equatable where Value: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.valid(lhsValue), .valid(rhsValue)):

            return lhsValue == rhsValue
        case (.initial, .initial),
            (.workInProgress, .workInProgress),
            (.invalid, .invalid):

            return true
        default:
            return false
        }
    }
}
