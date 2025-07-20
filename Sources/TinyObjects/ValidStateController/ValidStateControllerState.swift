//
//  ValidStateControllerState.swift
//  TinyObjects
//
//  Created by Nicholas Clooney on 20/7/2025.
//

public extension ValidStateController {
    enum State: CustomStringConvertible {
        case initial
        case workInProgress
        case valid(Value)
        case invalid(InvalidReason)

        public var description: String {
            switch self {
            case .initial: "initial"
            case .workInProgress: "workInProgress"
            case let .valid(value): "valid(\(value))"
            case let .invalid(reason): "invalid(\(reason))"
            }
        }

        public enum InvalidReason: Sendable, CustomStringConvertible {
            case cancelled
            case notCached
            case invalidated
            case failed(Failure)

            public var description: String {
                switch self {
                case .cancelled: "cancelled"
                case .notCached: "notCached"
                case .invalidated: "invalidated"
                case let .failed(error): "failed(\(error))"
                }
            }
        }
    }
}
