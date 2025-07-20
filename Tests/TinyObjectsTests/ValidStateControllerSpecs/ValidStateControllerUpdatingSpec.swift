//
//  ValidStateControllerUpdatingSpec.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 20/7/2025.
//

import Nimble
import Quick

import TinyObjects

final class ValidStateControllerUpdatingSpec: AsyncSpec {
    override class func spec() {
        typealias Controller = ValidStateController<Int, Never>

        let work: Controller.Work = { 42 }
        let storage = Controller.Storage(load: { nil }, save: { _ in })
        let validate: Controller.Validate = { if $0 == 42 { 42 } else { nil } }

        var controller: Controller!

        describe("ValidStateController") {
            beforeEach {
                controller = await .init(
                    work: work,
                    storage: storage,
                    validate: validate,
                )
            }

            context("when upadating with a valid value") {
                beforeEach {
                    await controller.update(value: 42)
                }

                it("has an valid state") {
                    let state = await controller.state

                    expect(state) == .valid(42)
                }
            }

            context("when upadating with a invalid value") {
                beforeEach {
                    await controller.update(value: 41)
                }

                it("has an valid state") {
                    let state = await controller.state

                    expect(state) == .invalid
                }
            }
        }
    }
}
