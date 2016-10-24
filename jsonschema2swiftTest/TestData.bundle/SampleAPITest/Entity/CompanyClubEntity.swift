/// CompanyClubEntity.swift
/// generated by jsonschema2swift

import Foundation
import SwiftyJSON


/// company_club
public struct CompanyClubEntity: EntityType {

  /// クラブ名
  var name: String

  var users: [UserEntity]

  public init?(json: JSON) {
    guard !json.isEmpty else {
      return nil
    }
    self.name = json["name"].string!
    self.users = json["users"].arrayValue.map { UserEntity(json: $0)! } as [UserEntity]
  }

  var serialized: [String: Any] {
    var param: [String: Any] = [:]
    param["name"] = name.serialized
    param["users"] = users.serialized
    return param
  }
}