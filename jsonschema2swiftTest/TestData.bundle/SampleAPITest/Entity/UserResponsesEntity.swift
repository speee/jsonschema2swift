/// UserResponsesEntity.swift
/// generated by jsonschema2swift

import Foundation
import SwiftyJSON


public struct UserResponsesEntity: ResponseEntityType {


  var data: [UserEntity]?

  public init?(json: JSON) {
    guard !json.isEmpty else {
      return nil
    }
    self.data = json["data"].arrayValue.map { UserEntity(json: $0)! } as [UserEntity]?
  }

  var serialized: [String: Any] {
    var param: [String: Any] = [:]
    param["data"] = data?.serialized
    return param
  }
}
