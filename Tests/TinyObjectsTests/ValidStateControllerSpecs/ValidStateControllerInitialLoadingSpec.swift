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
        var fixture: ValidaStateControllerFixture<Int, Never>!

        func makeFixture(
            storage: ValidStateController<Int, Never>.Storage,
        ) -> ValidaStateControllerFixture<Int, Never> {
            .init(
                dependencies: .init(
                    work: { 42 },
                    storage: storage,
                    validate: { if $0 == 42 { 42 } else { nil } },
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
                        let state = fixture.controller.state

                        expect(state) == .valid(42)
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
                            .invalid(.invalidated),
                            .valid(42),
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
                            .invalid(.notCached),
                            .valid(42),
                        ]
                    }
                }
            }
        }
    }
}
