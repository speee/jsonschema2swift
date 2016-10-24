/// DepartmentResponsesEntity.swift
/// generated by jsonschema2swift

import Foundation
import SwiftyJSON


public struct DepartmentResponsesEntity: ResponseEntityType {


  var data: [DepartmentEntity]?

  public init?(json: JSON) {
    guard !json.isEmpty else {
      return nil
    }
    self.data = json["data"].arrayValue.map { DepartmentEntity(json: $0)! } as [DepartmentEntity]?
  }

  var serialized: [String: Any] {
    var param: [String: Any] = [:]
    param["data"] = data?.serialized
    return param
  }
}