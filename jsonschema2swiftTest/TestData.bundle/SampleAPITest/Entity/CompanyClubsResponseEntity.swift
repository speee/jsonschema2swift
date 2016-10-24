/// CompanyClubsResponseEntity.swift
/// generated by jsonschema2swift

import Foundation
import SwiftyJSON

/// company_clubs
public struct CompanyClubsResponseEntity: ResponseEntityType {


  var data: CompanyClubsEntity?

  public init?(json: JSON) {
    guard !json.isEmpty else {
      return nil
    }
    self.data = CompanyClubsEntity(json: json["data"]) as CompanyClubsEntity?
  }

  var serialized: [String: Any] {
    var param: [String: Any] = [:]
    param["data"] = data?.serialized
    return param
  }
}