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
                    ),
                )
                await fixture.controller.start()
            }

            context("when upadating with a valid value") {
                beforeEach {
                    await fixture.controller.update(value: 42)
                }

                it("has an valid state") {
                    expect(fixture.states) == [
                        .initial,
                        .invalid(.cacheMiss),
                        .valid(42),
                        .valid(42),
                    ]
                }
            }

            context("when upadating with a invalid value") {
                beforeEach {
                    await fixture.controller.update(value: 41)
                }

                it("had an invalid state") {
                    expect(fixture.states) == [
                        .initial,
                        .invalid(.cacheMiss),
                        .valid(42),
                        .invalid(.invalidated(41)),
                        .valid(42),
                    ]
                }
            }
        }
    }
}
