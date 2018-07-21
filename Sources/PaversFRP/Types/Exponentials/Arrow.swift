//
//  Arrow.swift
//  PaversFRP
//
//  Created by Keith on 2018/7/21.
//

public struct Arrow<A, B> {
  private let f: (A) -> B
}

/// Arrow Class
extension Arrow {
  public init(_ f: @escaping (A) -> B) { self.f = f }
  
  public static func arr(_ f: @escaping (A) -> B) -> Arrow<A, B> {
    return Arrow(f)
  }
  
  public static func compose<C>(_ f: Arrow<A, B>, _ g: Arrow<B, C>) -> Arrow<A, C> {
    return Arrow<A, C>(f.f >>> g.f)
  }
  
  public static func first<C>(_ f: Arrow<A, B>) -> Arrow<(A, C),(B, C)> {
    return Arrow<(A, C),(B, C)>({ (a, c) in (f.f(a), c) })
  }
}

/// Functor
extension Arrow {
  /// fmap :: (a -> b) -> f a -> f b
  public static func fmap <C> (_ f: @escaping (B) -> C, _ fa: Arrow<A, B>) -> Arrow<A, C> {
    return compose(fa, Arrow<B, C>(f))
  }
}

/// Applicative
extension Arrow {
  /// apply :: f(a -> b) -> f a -> f b
  public static func apply<C>(_ f: Arrow<A, (B) -> C>, _ fa: Arrow<A, B>) -> Arrow<A, C> {
    let fb: (A) -> C = { a in
      let g = f.f(a)
      let b = fa.f(a)
      return g(b)
    }
    return Arrow<A, C>(fb)
  }
  
  /// pure :: a -> f a
  public static func pure(_ b: B) -> Arrow<A, B> {
    return Arrow<A, B>({_ in b})
  }
}

/// Monad
extension Arrow {
  
  /// bind :: m a -> (a -> m b) -> m b
  public static func bind<C>(_ ma: Arrow<A, B>, _ f: @escaping (B) -> Arrow<A, C>) -> Arrow<A, C> {
    let fb: (A) -> C = { a in
      let b = ma.f(a)
      return f(b).f(a)
    }
    return Arrow<A, C>(fb)
  }
  
}
