//
// Created by hayato.iida on 2016/09/15.
// Copyright (c) 2016 Speee, Inc. All rights reserved.
//

import Foundation

infix operator ++: indention
infix operator ++=: indention

precedencegroup indention {
  associativity: left
  lowerThan: AdditionPrecedence
}

func ++(left: String, right: String) -> String {
  return left + "\n" + right
}

func ++=(left: inout String, right: String) -> String {
  left += right + "\n"
  return left
}
