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

final class ValidStateControllerUpdatingSpec: AsyncSpec {
    override class func spec() {
        typealias Fixture = ValidStateControllerFixture<Int, Never>

        var fixture: Fixture!

        describe("ValidStateController") {
            beforeEach {
                fixture = .init(
                    dependencies: .init(
                        work: { 42 },
                        storage: .init(load: { nil }, save: { _ in }),
                        validate: Fixture.Validate.equalTo(42),
                        retryPolicy: .noRetry,
                    ),
                )
                await fixture.controller.start()
            }

            context("when upadating with a valid value") {
                beforeEach {
                    await fixture.controller.update(value: 42)
                }

                it("has an initial valid state and a second valid state") {
                    expect(fixture.states) == [
                        .initial,
                        .invalid(.cacheMiss),
                        .valid(42), // comes from first `work` when storage is empty
                        .valid(42), // comes from `update`
                    ]
                }
            }

            context("when upadating with a invalid value") {
                beforeEach {
                    await fixture.controller.update(value: 41)
                }

                it("has an invalid state then a paused state") {
                    expect(fixture.states) == [
                        .initial,
                        .invalid(.cacheMiss),
                        .valid(42), // comes from first `work` when storage is empty
                        .invalid(.invalidated(41)),
                        .paused,
                    ]
                }
            }
        }
    }
}
