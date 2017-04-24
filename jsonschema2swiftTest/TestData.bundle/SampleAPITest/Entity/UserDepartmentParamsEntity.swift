/// UserDepartmentParams.swift
/// generated by jsonschema2swift

import Foundation
import SwiftyJSON


/// user_department_params
public struct UserDepartmentParams: SingleEntityType {

  /// 役職名
  public enum Role: String {
    case staff = "一般社員"
    case projectGeneralManager = "主査"
    case supervisor = "主任"
    case sectionHead = "係長"
    case chiefEditor = "主幹"
    case secretary = "参事"
    case assistantSectionChief = "課長代理"
    case sectionChief = "課長"
    case assistantGeneralManager = "次長"
    case assistantManager = "部長代理"
    case viceManager = "副部長"
    case manager = "部長"
    case generalManager = "本部長"
    case counselor = "参与"
    case corporateOfficer = "執行役"
    case auditor = "監査役"
    case director = "取締役"
    case vicePresident = "副社長"
    case president = "社長"
    case chairman = "会長"
  }

  /// 部署ID
  public var id: Int
  /// 役職名
  public var role: RoleEntity.Role?

  public init(id: Int, role: RoleEntity.Role? = nil) {
    self.id = id
    self.role = role
  }

  public init?(json: JSON) {
    if json.isEmpty {
      return nil
    }
    self.id = json["id"].int!
    self.role = RoleEntity.Role(rawValue: json["role"].string!)
  }

  var serialized: [String: Any] {
    var param: [String: Any] = [:]
    param["id"] = id.serialized
    param["role"] = role?.serialized
    return param
  }
}
