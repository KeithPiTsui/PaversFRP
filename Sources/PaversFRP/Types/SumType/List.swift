//
//  List.swift
//  PaversFRP
//
//  Created by Keith on 2018/7/20.
//

private typealias Lazy<A> = Arrow<(), A>


public enum List<A> {
  case Nil
  indirect case Cons(A, () -> List<A>)
}

public func head<A> (xs: List<A>) -> A {
  switch xs {
  case .Cons(let x, _):
    return x
  default:
    fatalError("List is empty")
  }
}



public func infiniteOne() -> List<Int> {
  return List<Int>.Cons(1, infiniteOne)
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
  case .Cons(_, let rest):
    return rest
  default:
    fatalError("List is empty")
  }
}

//public let infiniteOne : List<Int> = List<Int>.Cons(1, infiniteOne)
public func fib() -> List<Int> {
  return List<Int>.Cons(1,
                        {List<Int>.Cons(1,
                                        {zipList(xs: fib, ys: tail(xs: fib), f: +)})})
}
