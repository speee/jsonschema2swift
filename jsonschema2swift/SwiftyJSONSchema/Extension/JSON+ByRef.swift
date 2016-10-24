//
//  JSON+ByRef.swift
//  jsonschema2swift
//
//  Created by hayato.iida on 2016/08/30.
//  Copyright © 2016年 hayato.iida. All rights reserved.
//

import Foundation

extension JSON {
  func extract(_ byRef: String, rootJSON: JSON) -> JSON {
    let referencedJSON = self.reference(byRef, rootJSON: rootJSON)
    if let ref = referencedJSON["$ref"].string {
      return referencedJSON.extract(ref, rootJSON: rootJSON)
    }
    return referencedJSON
  }

  func reference(_ byRef: String, rootJSON: JSON) -> JSON {
    let separates = byRef.components(separatedBy: "/")
    let path      = separates[0]
    if path == "#" {
      // "#/definitions/user" -> "definitions/user"
      return rootJSON.reference(removeAndSeparate(separates), rootJSON: rootJSON)
    }
    if separates.count == 1 {
      //再帰の終端
      return self[path]
    }

    let mine = Int(path) != nil ? self[Int(path)!] :  self[path]
    return mine.reference(removeAndSeparate(separates), rootJSON: rootJSON)
  }

  fileprivate func removeAndSeparate(_ separates: [String]) -> String {
    return separates[1 ... (separates.count - 1)].joined(separator: "/")
  }

}
