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

        public enum InvalidReason: CustomStringConvertible {
            case cancelled
            case cacheMiss
            case invalidated(Value)
            case failed(Failure)

            public var description: String {
                switch self {
                case .cancelled: "cancelled"
                case .cacheMiss: "cacheMiss"
                case .invalidated: "invalidated"
                case let .failed(error): "failed(\(error))"
                }
            }
        }
    }
}

extension ValidStateController.State: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.valid(lhsValue), .valid(rhsValue)):
            lhsValue == rhsValue
        case (.initial, .initial),
             (.workInProgress, .workInProgress),
             (.invalid, .invalid):
            true
        default:
            false
        }
    }
}
