//
//  ValidStateController.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 17/7/2025.
//

import Combine

public class ValidStateController<
    Value,
    Failure: Error,
> {
    /// Returns `Value` when a value is valid.
    /// Returns `nil` when a value is no longer valid.
    public typealias Validate = (Value) -> Value?

    // Should we assume the value is always valid?
    // bc if it is not...
    // 1. we have to do checks after the `work` is done
    // 2. should we retry? and what is the retry policy (.immediate, .static,
    // .custom)
    public typealias Work = () async throws(Failure) -> Value

    public struct Storage {
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

    public enum State: CustomStringConvertible {
        case initial
        case workInProgress
        case valid(Value)
        case invalid(InvalidReason)

        public var description: String {
            switch self {
            case .initial: "initial"
            case .workInProgress: "workInProgress"
            case let .valid(value): "valid(\(value))"
            case let .invalid(reason): "invalid(\(reason))"
            }
        }

        public enum InvalidReason: Sendable, CustomStringConvertible {
            case cancelled
            case notCached
            case invalidated
            case failed(Failure)

            public var description: String {
                switch self {
                case .cancelled: "cancelled"
                case .notCached: "notCached"
                case .invalidated: "invalidated"
                case let .failed(error): "failed(\(error))"
                }
            }
        }
    }

    public var state: State {
        stateSubject.value
    }

    public let statePublisher: AnyPublisher<State, Never>
    private let stateSubject = CurrentValueSubject<State, Never>(.initial)

    // Dependencies
    private let work: Work
    private let storage: Storage
    private let validate: Validate

    public init(
        work: @escaping Work,
        storage: Storage,
        validate: @escaping Validate
    ) {
        self.work = work
        self.storage = storage
        self.validate = validate

        statePublisher = stateSubject.eraseToAnyPublisher()
    }

    public func start() async {
        await loadState()
    }

    private func update(state: State) {
        stateSubject.value = state
    }

    /// Try to load a valid state from storage
    /// If no valid state is to be found, it will request a refresh.
    private func loadState() async {
        guard let storedValue = storage.load() else {
            update(state: .invalid(.notCached))

            await requestRefresh()
            return
        }

        await update(value: storedValue)
    }

    /// Update the state based on whether the value is valid
    /// If the state is not valid, it will request a refresh.
    public func update(value: Value) async {
        guard let validValue = validate(value) else {
            update(state: .invalid(.invalidated))

            await requestRefresh()
            return
        }

        update(state: .valid(validValue))
    }

    /// Request a refresh of state if not work in progress
    public func requestRefresh() async {
        if case .workInProgress = state {
            return
        }

        await refresh()
    }

    /// Force a refresh without checking the work in prgress state
    public func forceRefresh() async {
        await refresh()
    }

    private func refresh() async {
        do {
            let value = try await work()

            // TODO: If the value is not valid...
            // Do we keep retrying??? also what is the retry strategy???

            await update(value: value)
        } catch {
            update(state: .invalid(.failed(error)))
        }
    }

    // ???
    public func cancelRefresh() {}
}

extension ValidStateController.State: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.valid(lhsValue), .valid(rhsValue)):
            lhsValue == rhsValue
        case (.initial, .initial),
             (.workInProgress, .workInProgress),
             (.invalid, .invalid):
            true
        default:
            false
        }
    }
}
