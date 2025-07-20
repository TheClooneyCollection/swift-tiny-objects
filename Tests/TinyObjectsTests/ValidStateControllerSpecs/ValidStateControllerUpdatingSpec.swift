//
//  ValidStateControllerUpdatingSpec.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 20/7/2025.
//

import Combine

import Nimble
import Quick

import TinyObjects

final class ValidaStateControllerFixture<Value, Failure: Error> {
    typealias Controller = ValidStateController<Value, Failure>

    private(set) var states: [Controller.State] = []

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

    func makeController() -> Controller {
        controllerFactory()
    }
}

final class ValidStateControllerUpdatingSpec: AsyncSpec {
    override class func spec() {
        typealias Controller = ValidStateController<Int, Never>

        let work: Controller.Work = { 42 }
        let storage = Controller.Storage(load: { nil }, save: { _ in })
        let validate: Controller.Validate = { if $0 == 42 { 42 } else { nil } }

        var states: [Controller.State]!
        var controller: Controller!
        var cancellables = Set<AnyCancellable>()

        describe("ValidStateController") {
            beforeEach {
                states = []
                controller = .init(
                    work: work,
                    storage: storage,
                    validate: validate,
                )

                controller.statePublisher
                    .sink { states.append($0) }
                    .store(in: &cancellables)

                await controller.start()
            }

            context("when upadating with a valid value") {
                beforeEach {
                    await controller.update(value: 42)
                }

                it("has an valid state") {
                    expect(states) == [
                        .initial,
                        .invalid(.notCached),
                        .valid(42),
                        .valid(42),
                    ]
                }
            }

            context("when upadating with a invalid value") {
                beforeEach {
                    await controller.update(value: 41)
                }

                it("had an invalid state") {
                    expect(states) == [
                        .initial,
                        .invalid(.notCached),
                        .valid(42),
                        .invalid(.invalidated),
                        .valid(42),
                    ]
                }
            }
        }
    }
}
