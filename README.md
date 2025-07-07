# Swift Tiny Objects Library

The **Tiny Objects** library promotes building extremely small, single-purpose components in Swift.

Each “tiny object” should:

* Have **one responsibility**
* Be as **trivially understandable** as it can from its source alone
* Aim to keep internal logic minimal and understandable
  * For complex responsibilities, split implementation into small functions and compose them together
* Be **fully covered** by unit tests
* Be **immutable** where possible
* Have **no hidden side effects**
