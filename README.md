# Swift Tiny Objects Library

[![Swift](https://github.com/TheClooneyCollection/swift-tiny-objects/actions/workflows/swift.yml/badge.svg)](https://github.com/TheClooneyCollection/swift-tiny-objects/actions/workflows/swift.yml)

The **Tiny Objects** library promotes building extremely small, single-purpose components in Swift.

Each “tiny object” should:

* Have **one responsibility**
* Be as **trivially understandable** as it can from its source alone
* Aim to keep internal logic minimal and understandable
  * For complex responsibilities, split implementation into small functions and compose them together
* Be **fully covered** by unit tests
* Be **immutable** where possible
* Have **no hidden side effects**

## ValidStateController

**ValidStateController** is a generic Swift utility that manages a value’s lifecycle by loading it from storage, validating it, and—if it’s missing or invalid—automatically refreshing it via an async work closure. State changes (initial, work-in-progress, valid, invalid) are exposed as a Combine publisher for easy subscription.

