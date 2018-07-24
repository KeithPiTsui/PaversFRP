/// A type is `Monoid` if it is `Semigroup` with an identity that
/// combine this identity with other value of this type would
/// result to that value.
public protocol Monoid: Semigroup {
  static func identity () -> Self
}
