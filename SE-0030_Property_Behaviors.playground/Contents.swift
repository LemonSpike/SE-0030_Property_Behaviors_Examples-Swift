import UIKit

//MARK: "Motivation"

/* The standard implementation of lazy is also problematic for value types.
 A lazy getter must be mutating, which means it can't be accessed from an immutable value.
*/
class Object {
  lazy var value: String = "hello"
}

struct ValueObject {
  lazy var value: String = "hello"
}

let valueObject = ValueObject()
//valueObject.value gives the compiler error mentioned above.

let object = Object()
object.value

/*  For instance, some applications may want the lazy initialization to be synchronized, but lazy only provides single-threaded initialization. */

class ThreadedObject {
//  lazy var value: String = {
//    DispatchQueue.main.sync {
//      return "hello"
//    }
//  }()
//The code above doesn't compile. So we can only have single-threaded initialization with lazy vars.
}

/*
There are important property patterns outside of lazy initialization. It often makes sense to have "delayed", once-assignable-then-immutable properties to support multi-phase initialization:
*/

class Foo {
  let immediatelyInitialized = "foo"
  var _initializedLater: String?

  // We want initializedLater to present like a non-optional 'let' to user code;
  // it can only be assigned once, and can't be accessed before being assigned.
  var initializedLater: String {
    get { return _initializedLater! }
    set {
      assert(_initializedLater == nil)
      _initializedLater = newValue
    }
  }
}

/*
Implicitly-unwrapped optionals allow this in a pinch, but give up a lot of safety compared to a non-optional 'let'. Using IUO for multi-phase initialization gives up both immutability and nil-safety.
*/
class ImplicitFoo {
  //`var` IUO compiles, but `let` IUO doesn't compile! i.e we must give up immutability.
  var initializedLater: Bool!
}

print(ImplicitFoo().initializedLater)

/* We also have other application-specific property features like didSet/willSet that add language complexity for limited functionality.
 Beyond what we've baked into the language already, there's a seemingly endless set of common property behaviors, including synchronized access, copying, and various kinds of proxying, all begging for language attention to eliminate their boilerplate.
 */

//MARK: "Proposed Solution"
/* I suggest we allow for property behaviors to be implemented within the language.
 A var declaration can specify its behaviors in square brackets after the keyword:
*/

//var [lazy] foo = 1738

/* which implements the property foo in a way described by the property behavior declaration for lazy: */

//var behavior lazy<Value>: Value {
//  var value: Value? = nil
//  initialValue
//
//  mutating get {
//    if let value = value {
//      return value
//    }
//    let initial = initialValue
//    value = initial
//    return initial
//  }
//  set {
//    value = newValue
//  }
//}

/* Property behaviors can control the storage, initialization, and access of affected properties, obviating the need for special language support for lazy, observers, and other special-case property features.
*/

"Examples"

