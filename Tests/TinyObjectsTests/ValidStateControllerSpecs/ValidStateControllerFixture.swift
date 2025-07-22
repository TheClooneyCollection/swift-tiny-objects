//
//  ValidStateControllerFixture.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 20/7/2025.
//

import Combine

import TinyObjects

final class ValidStateControllerFixture<Value, Failure: Error> {
    typealias Controller = ValidStateController<Value, Failure>

    private(set) var states: [Controller.State] = []
    private(set) var controller: Controller

    private var cancellables = Set<AnyCancellable>()

    init(
        dependencies: Controller.Dependencies,
    ) {
        states = []

        controller = Controller(
            dependencies: dependencies,
        )

        controller.statePublisher
            .sink { self.states.append($0) }
            .store(in: &cancellables)
    }
}

extension ValidStateControllerFixture where Value: Equatable {
    enum Validate {
        static func equalTo(_ value: Value) -> Controller.Validate {
            { input in
                if input == value {
                    value
                } else {
                    nil
                }
            }
        }

        static func otherThan(_ value: Value) -> Controller.Validate {
            { input in
                if input != value {
                    value
                } else {
                    nil
                }
            }
        }
    }
}

extension ValidStateControllerFixture {
    enum Work {
        // TODO: timesOut(timeouts: [Timeout], eventually: Value / Timeout) {}

        static func never() -> Controller.Work {
            {
                // an AsyncStream that never yields, so this loop never exits
                for await _ in AsyncStream<Value>.never {
                    /* unreachable */
                }
                fatalError("unreachable")
            }
        }
    }
}

private extension AsyncStream {
    /// An `AsyncStream` that never emits and never finishes.
    static var never: AsyncStream<Element> {
        AsyncStream { _ in
            // we never call `continuation.yield(_:)` or `continuation.finish()`
        }
    }
}
