//
// Created by hayato.iida on 2016/08/31.
// Copyright (c) 2016 Speee, Inc. All rights reserved.
//

import Foundation

extension Dictionary {
  init(_ pairs: [Element]) {
    self.init()
    for (k, v) in pairs {
      self[k] = v
    }
  }
}

extension Dictionary {
  func mapPairs<OutKey:Hashable, OutValue>(_ transform: (Element) throws -> (OutKey, OutValue)) rethrows -> [OutKey:OutValue] {
    return Dictionary<OutKey, OutValue>(try map(transform))
  }

  func filterPairs(_ includeElement: (Element) throws -> Bool) rethrows -> [Key:Value] {
    return Dictionary(try filter(includeElement))
  }

}

extension Sequence {
  func toDict<K: Hashable, V>
      (_ convert: (Iterator.Element) -> (K, V?)) -> [K:V] {
    var result: [K:V] = [:]
    for x in self {
      let (key, val) = convert(x)
      result[key] = val
    }
    return result
  }
}
