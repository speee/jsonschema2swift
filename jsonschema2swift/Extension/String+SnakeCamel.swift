//
// Created by hayato.iida on 2016/09/01.
// Copyright (c) 2016 hayato.iida. All rights reserved.
//

import Foundation
extension String {

  var snake2Camel: String {
    let items = self.components(separatedBy: "_")
    var camelCase = ""
     items.enumerated().forEach {
      camelCase += $1.capitalized
    }
    return camelCase
  }
  var snake2camel: String {
    let items = self.components(separatedBy: "_")
    var camelCase = ""
     items.enumerated().forEach {
      camelCase += 0 == $0 ? $1.lowercased() : $1.capitalized
    }
    return camelCase
  }
}
