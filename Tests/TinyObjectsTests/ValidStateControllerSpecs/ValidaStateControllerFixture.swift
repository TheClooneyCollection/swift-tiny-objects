//
//  ValidaStateControllerFixture.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 20/7/2025.
//

import Combine

import TinyObjects

final class ValidaStateControllerFixture<Value, Failure: Error> {
    typealias Controller = ValidStateController<Value, Failure>

    private(set) var states: [Controller.State] = []
    private(set) var controller: Controller!

    private var cancellables = Set<AnyCancellable>()
    private var controllerFactory: (() -> Controller)!

    init(
        work: @escaping Controller.Work,
        storage: Controller.Storage,
        validate: @escaping Controller.Validate,
    ) {
        controllerFactory = {
            self.states = []

            let controller = Controller(
                work: work,
                storage: storage,
                validate: validate,
            )

            controller.statePublisher
                .sink { self.states.append($0) }
                .store(in: &self.cancellables)

            return controller
        }
    }

    func makeController() {
        controller = controllerFactory()
    }
}
