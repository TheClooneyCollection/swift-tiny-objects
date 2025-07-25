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
    public var state: State {
        stateSubject.value
    }

    public let statePublisher: AnyPublisher<State, Never>
    private let stateSubject = CurrentValueSubject<State, Never>(.initial)

    private let dependencies: Dependencies

    public init(
        dependencies: Dependencies
    ) {
        self.dependencies = dependencies

        statePublisher = stateSubject.eraseToAnyPublisher()
    }

    public func start() async {
        await loadState()
    }

    private func update(state: State) {
        stateSubject.value = state
    }

    /// Try to load a valid value from storage
    /// If there is no value at all or the value is not valid, it will request a refresh.
    private func loadState() async {
        guard
            let storedValue = dependencies.storage.load()
        else {
            update(state: .invalid(.cacheMiss))

            await requestRefresh()
            return
        }

        guard
            let _ = dependencies.validate(storedValue)
        else {
            update(state: .invalid(.invalidated(storedValue)))

            await requestRefresh()
            return
        }

        update(state: .valid(storedValue))
    }

    /// Update the state based on whether the value is valid
    /// If the state is not valid, it will request a refresh.
    public func update(value: Value) async {
        guard let validValue = dependencies.validate(value) else {
            update(state: .invalid(.invalidated(value)))

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
            let value = try await dependencies.work()

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
