public extension Array where Element: OptionalType {

  /**
   - returns: A new array with `nil` values removed.
   */
  public func compact() -> [Element.Wrapped] {
    return self.filter { $0.optional != nil }.map { $0.optional! }
  }
}



public extension Array where Element: Semigroup {
  /**
   Combines all elements of the array with the semigroup operation.

   - parameter initial: A semigroup value.

   - returns: The concatenation of all the values.
   */
  public func sconcat(_ initial: Element) -> Element {
    return self.reduce(initial, <>)
  }
}

public extension Array where Element: Monoid {
  public func sconcat() -> Element {
    return self.reduce(Element.identity(), <>)
  }
}

public extension Array {
  /**
   Remove repeated elements from an array. This is an O(n^2) implementation based
   on Array.contains.

   - parameter eq: A function to determine equality of two elements.

   - returns: An array of distinct values in the array without changing the order.
   */
  public func distincts( _ eq: (Element, Element) -> Bool) -> Array {
    var result = Array()
    forEach { x in
      if !result.contains(where: { eq(x, $0) }) {
        result.append(x)
      }
    }
    return result
  }

  /**
   Groups elements into a dictionary.

   - parameter grouping: A function that maps elements into a `Hashable` type.

   - returns: A dictionary where each key contains all the elements of `self` that are mapped to the key
              via the `grouping` function.
   */
  public func groupedBy <K: Hashable> (_ grouping: (Element) -> K) -> [K:[Element]] {
    var result: [K:[Element]] = [:]

    for value in self {
      let key = grouping(value)
      result[key] = result[key] ?? []
      result[key]?.append(value)
    }

    return result
  }

  /**
   Sorts an array given a comparator.

   - parameter comparator: A comparator.

   - returns: A sorted array.
   */
  public func sorted(comparator: Comparator<Element>) -> Array {
    return self.sorted(by: comparator.isOrdered)
  }
}

public extension Array where Element: Equatable {

  /**
   Remove repeated elements from an array. This is an O(n^2) implementation based
   on Array.contains.

   - returns: An array of distinct values in the array without changing the order.
   */
  public func distincts() -> Array {
    return self.distincts(==)
  }
}

extension Array: Semigroup {
  public func op(_ other: Array) -> Array {
    return self + other
  }
}

extension Array: Monoid {
  public static func identity () -> Array {
    return []
  }
}

extension Array where Element: EitherType {

  /**
   Extracts the left values from the array.

   - returns: A new array of left values.
   */
  func lefts() -> [Element.A] {
    return PaversFRP.lefts(self)
  }

  /**
   Extracts the right values from the array.

   - returns: A new array of right values.
   */
  func rights() -> [Element.B] {
    return PaversFRP.rights(self)
  }
}

extension Collection where Element == Bool {
  public func all () -> Bool {
    return self.reduce(true) {$0 && $1}
  }
  
  public func some () -> Bool {
    return self.reduce(false) {$0 || $1}
  }
}

