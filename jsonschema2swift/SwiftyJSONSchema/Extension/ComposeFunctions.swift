//
//  ComposeFunctions.swift
//  jsonschema2swift

/// The function composition operator is the only user-defined operator that
/// operates on functions.  That's why the exact precedence does not matter
/// right now.
infix operator • : CompositionPrecedence
// The character is U+2218 RING OPERATOR.
//
// Confusables:
//
// U+00B0 DEGREE SIGN
// U+02DA RING ABOVE
// U+25CB WHITE CIRCLE
// U+25E6 WHITE BULLET
precedencegroup CompositionPrecedence {
  associativity: left
  higherThan: TernaryPrecedence
}

/// Compose functions.
///
///     (g • f)(x) == g(f(x))
///
/// - Returns: a function that applies ``g`` to the result of applying ``f``
///   to the argument of the new function.
public func •<T, U, V>(g: @escaping (U) -> V, f: @escaping (T) -> U) -> ((T) -> V) {
  return { g(f($0)) }
}
