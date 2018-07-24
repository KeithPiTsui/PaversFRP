# PaversFRP

This is a Swift framework to support functional programming in many of my other frameworks. Gathering those functionalities together in to one framework would facilitate using FP in other frameworks or applications.

Some codes is from other repositories in github, I will provide a link to that repo.

Most of ideas has Haskell or other FP language counterpart. To start introduce this framework, I would recommend the user to have a look my article about [Type Theory in Swift](https://keithpitsui.github.io/TypeTheoryInSwift/TypeTheoryInSwift.html).


## Table of Contents


# Type Features

There are some different kinds of types having their counterpart in Swift.

`Some Type`, the counterpart in Swift is `enum`.

`Product Type`, the counterpart in Swift is `tuple` and `struct`.

`Exponential Type`, the counterpart in Swift is `function` and `closure`.

`Existential Type`, the counterpart in Swift is `protocol`.

`Recursive type`, the counterpart in Swift is `indirect enum` which some cases refer to its `Self`.


Different kind of type would have different property to facilitate solution of some problems. The functionalities of framework would heavily utilize these concepts.

# Laziness

Another important feature that FP would have is laziness. Laziness means delay evaluation until its value is needed. And Swift is an eager evaluation language, that is when you pass an expression to a function call, the expression would be evaluated first, then pass the value to that function as an argument. Therefore to implement laziness in Swift, we need `function` or `closure`, (`exponential type`), to wrap the expression. In other words, tell me how to generate the value when needed instead of give me the exact value.

The following is an example to take advantage of Laziness in Swift.

In Haskell, The fibonacci sequence is calculated by:
```haskell
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)
```
Because Haskell is a lazy langauge, it only partially evaluate the expression when it needs to. ([WHNF](https://wiki.haskell.org/Weak_head_normal_form))

Another feature of Haskell makes that expression efficient is function value cache, that is if using the same argument to call the same function, it will return the cached value after its first call.

Therefore in Swift, we can implement this fib expression as following. Noticed this implement doesn't have cache feature.
```swift
public enum List<A> {
  case Nil
  indirect case Cons(A, () -> List<A>)
}

public func zipList<A, B, C>(xs: @escaping () -> List<A>,
                             ys: @escaping () -> List<B>,
                             f: @escaping (A, B) -> C) -> List<C> {
  switch (xs(), ys()) {
  case (.Cons(let x, let xrest), .Cons(let y, let yrest)):
    return .Cons( f(x, y), {zipList(xs: xrest, ys: yrest, f: f)})
  default:
    return .Nil
  }
}

public func tail<A> (xs: @escaping () -> List<A>) -> () -> List<A> {
  switch xs() {
  case .Cons(_, let rest): return rest
  default: fatalError("List is empty")
  }
}

public func fib() -> List<Int> {
  return List<Int>.Cons(1, {List<Int>.Cons(1, {zipList(xs: fib, ys: tail(xs: fib), f: +)})})
}
```

# Composition

Composition is key for reusibilty. Because in Haskell, every thing is a pure function, no side effect, every output value only depends on input value. Therefore it is to compose some expressions or functions to make a bigger expression or function. So there is a saying in Haskell, a program is a large expression that solves a specific problem.

Thus, we have base function composition.
```swift
public func >>> <A, B, C> (f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
  return { g(f($0)) }
}
```
Moreover, we have more different kinds of composition. 

For example, the Kleisli composition, which related to Monad.

The following function is to compose two functions that produce optional values, from left to right
```swift
public func >-> <T, U, V>(f: @escaping (T) -> U?, g: @escaping (U) -> V?) -> (T) -> V? {
  return { x in f(x) >>- g }
}
```

# Curry
In Haskell, every function is curried by default. That would faciliate function composition.

Curry in Swift would look like the following:
```swift
public func curry<A, B, C>(_ function: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { (a: A) -> (B) -> C in { (b: B) -> C in function(a, b) } }
}
```

# Initial Obejct and Terminal Object in the category of Swift types.

Initial Object is a type that for every type in Swift, there is a unique function from initial object to that type.

The initial object is `Never` in Swift, and its isomorphic types, like no case enum.


Terminal Object is a type that for every type in Swift, there is a unique function from that type to terminal object.

The terminal object is `Void` in Swift, and its isomorphic types, like `()`, struct wrapped `()`.

One usage of terminal object in this framework is to ignore value when the value is not needed.

```swift
public func terminal<A>(_ x: A) -> () {
  return ()
}
```

# Maths Concept in Swift
Using a maths concept to capture a common behavioral pattern of a type, that can make that pattern more explicit and reuse the pattern more conveniently.

## Semigroup
```swift
/// A type is a Semigroup if it has an associative, binary operation.
public protocol Semigroup {
  /// An associative operation, i.e. a.op(b.op(c)) == (a.op(b)).op(c)
  func op(_ other: Self) -> Self
}
```

## Monoid
```swift
/// A type is `Monoid` if it is `Semigroup` with an identity that
/// combine this identity with other value of this type would
/// result to that value.
public protocol Monoid: Semigroup {
  static func identity () -> Self
}
```

## NumericType
```swift
/// A `NumericType` instance is something that acts numeric-like, i.e. can be added, subtracted
/// and multiplied with other numeric types.
public protocol NumericType {
  static func + (lhs: Self, rhs: Self) -> Self
  static func - (lhs: Self, rhs: Self) -> Self
  static func * (lhs: Self, rhs: Self) -> Self
  func negate() -> Self
  static func zero() -> Self
  static func one() -> Self
  init(_ v: Int)
}
```
## Functor
A type that is Funcotr would behave as a primitive context that wraps a value inside its context. 
So it has fmap function that change the value living in that context.

Array as Functor
```swift
public func <^> <T, U>(f: (T) -> U, a: [T]) -> [U] {
  return a.map(f)
}
```

Optional as Funcotr
```swift
public func <^> <T, U>(f: (T) -> U, a: T?) -> U? {
  return a.map(f)
}
```

## Applicative
A type that is Applicative would be a Funcotr, 
at the same time when a function live in that applicative context, 
that function can be applied with a value which live in the same context. 
In addition, there would be a function for an applicative type to lift any value into the applicative context.

```swift
public func <*> <T, U>(fs: [(T) -> U], a: [T]) -> [U] {
  return a.apply(fs)
}
public func pure<T>(_ a: T) -> [T] {
  return [a]
}
```

Optional as Applicative
```swift
public func <*> <T, U>(f: ((T) -> U)?, a: T?) -> U? {
  return a.apply(f)
}
public func pure<T>(_ a: T) -> T? {
  return .some(a)
}
```

## Monad
A type that is Monad would be an Applicative,
at the same time with a bind function to expend its contextual power, that make that following function contextual sensitive.

Array as Monad
```swift
public func >>- <T, U>(a: [T], f: (T) -> [U]) -> [U] {
  return a.flatMap(f)
}
```

Optional as Monad
```swift
public func >>- <T, U>(a: T?, f: (T) -> U?) -> U? {
  return a.flatMap(f)
}
```

# Notice
There are more inside this framework, and documentation of each API of this framework would stay in source file.

# How to use

## Swift Package Manager
Adding the following package dependency into your project.
```swift
.package(url: "https://github.com/KeithPiTsui/PaversFRP.git", from: "1.0.0"),
```

## Manual
1. Copy the ./Source/PaversFRP folder and its contents into your project, and use the source files.
2. Or clone thise repo, then use Swift package manager to generate its xcode project file, and import that xcode project into your own project.


