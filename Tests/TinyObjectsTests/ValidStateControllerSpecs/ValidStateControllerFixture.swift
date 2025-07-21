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
