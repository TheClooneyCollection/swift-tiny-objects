//
//  ValidStateControllerInitialLoadingSpec.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 17/7/2025.
//

import Testing

import Quick

import TinyObjects

final class ValidStateControllerInitialLoadingSpec: AsyncSpec {
    override class func spec() {
        typealias Controller = ValidStateController<Int, Never>

        var controller: Controller!
        var storage: Controller.Storage!

        context("when there is a valid value in the storage") {
            beforeEach {
                storage = .init(load: { 42 }, save: { _ in })
            }

            context("when starting the controller") {
                beforeEach {
                    controller = .init(
                        work: { handler in handler(.success(42)) },
                        storage: storage,
                        validate: { if $0 == 42 { 42 } else { nil } },
                    )
                }

                it("has an invalid state") {
                    let state = await controller.state
                    #expect(state == .valid(42))
                }
            }
        }

        context("when there is an invalid value in the storage") {
            beforeEach {
                let not42 = 41
                storage = .init(load: { not42 }, save: { _ in })
            }

            context("when starting the controller") {
                beforeEach {
                    controller = .init(
                        work: { handler in handler(.success(42)) },
                        storage: storage,
                        validate: { if $0 == 42 { 42 } else { nil } },
                    )
                }

                it("has an invalid state") {
                    let state = await controller.state
                    #expect(state == .invalid)
                }
            }
        }

        context("when there is nothing in the storage") {
            beforeEach {
                storage = .init(load: { nil }, save: { _ in })
            }

            context("when starting the controller") {
                beforeEach {
                    controller = .init(
                        work: { handler in handler(.success(42)) },
                        storage: storage,
                        validate: { $0 },
                    )
                }

                it("has an invalid state") {
                    let state = await controller.state
                    #expect(state == .invalid)
                }
            }
        }
    }
}
