//
//  ValidStateControllerInitialLoadingSpec.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 17/7/2025.
//

import Nimble
import Quick

import TinyObjects

final class ValidStateControllerInitialLoadingSpec: AsyncSpec {
    override class func spec() {
        typealias Fixture = ValidStateControllerFixture<Int, Never>
        var fixture: Fixture!

        func makeFixture(
            storage: Fixture.Controller.Storage,
        ) -> Fixture {
            .init(
                dependencies: .init(
                    // work: Fixture.Work.never(), - this hangs... ofc it does
                    work: { 42 },
                    storage: storage,
                    validate: Fixture.Validate.equalTo(42),
                ),
            )
        }

        describe("ValidStateController") {
            context("when there is a valid value in the storage") {
                beforeEach {
                    fixture = makeFixture(
                        storage: .init(load: { 42 }, save: { _ in }),
                    )
                }

                context("when starting the controller") {
                    beforeEach {
                        await fixture.controller.start()
                    }

                    it("has an valid state") {
                        expect(fixture.states) == [
                            .initial,
                            .valid(42),
                        ]
                    }
                }
            }

            context("when there is an invalid value in the storage") {
                beforeEach {
                    let not42 = 41

                    fixture = makeFixture(
                        storage: .init(load: { not42 }, save: { _ in }),
                    )
                }

                context("when starting the controller") {
                    beforeEach {
                        await fixture.controller.start()
                    }

                    it("has an invalid state") {
                        expect(fixture.states) == [
                            .initial,
                            .invalid(.invalidated(41)),
                            .valid(42), // as expected with `work` being `{ 42 }`
                        ]
                    }
                }
            }

            context("when there is nothing in the storage") {
                beforeEach {
                    fixture = makeFixture(
                        storage: .init(load: { nil }, save: { _ in }),
                    )
                }

                context("when starting the controller") {
                    beforeEach {
                        await fixture.controller.start()
                    }

                    it("has an invalid state") {
                        expect(fixture.states) == [
                            .initial,
                            .invalid(.cacheMiss),
                            .valid(42), // as expected with `work` being `{ 42 }`
                        ]
                    }
                }
            }
        }
    }
}
