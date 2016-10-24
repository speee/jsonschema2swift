/// UserEntity.swift
/// generated by jsonschema2swift

import Foundation
import SwiftyJSON


/// user
///
/// ユーザ
public struct UserEntity: EntityType {

  /// 社員名
  var name: String
  /// メールアドレス
  var email: String
  /// 社員ID
  var id: Int
  /// 所属部署
  var departments: [UserDepartmentEntity]
  /// 会社
  var company: CompanyEntity

  var userProfile: UserProfileEntity?

  public init?(json: JSON) {
    guard !json.isEmpty else {
      return nil
    }
    self.name = json["name"].string!
    self.email = json["email"].string!
    self.id = json["id"].int!
    self.departments = json["departments"].arrayValue.map { UserDepartmentEntity(json: $0)! } as [UserDepartmentEntity]
    self.company = CompanyEntity(json: json["company"]) as CompanyEntity!
    self.userProfile = UserProfileEntity(json: json["user_profile"]) as UserProfileEntity?
  }

  static func ==(left: UserEntity, right: UserEntity) -> Bool {
    return left.id == right.id

  }

  var serialized: [String: Any] {
    var param: [String: Any] = [:]
    param["name"] = name.serialized
    param["email"] = email.serialized
    param["id"] = id.serialized
    param["departments"] = departments.serialized
    param["company"] = company.serialized
    param["userProfile"] = userProfile?.serialized
    return param
  }
}
