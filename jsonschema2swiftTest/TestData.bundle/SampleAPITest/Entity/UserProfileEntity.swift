/// UserProfileEntity.swift
/// generated by jsonschema2swift

import Foundation
import SwiftyJSON


/// user_profile
///
/// ユーザプロフィール
public struct UserProfileEntity: SingleEntityType {

  /// 身長
  public var height: Double?
  /// プロフィール画像URL
  public var image: String?
  /// 入社日
  public var registedAt: Date
  /// 所属クラブ
  public var clubs: [String]?
  /// 体重
  public var weight: Double?
  /// TOEICのスコア
  public var toeicScore: Int?
  /// 生年月日
  public var birthday: Date?
  /// 社員ID
  public var userId: Int

  public init(height: Double? = nil, image: String? = nil, registedAt: Date, clubs: [String]? = nil, weight: Double? = nil, toeicScore: Int? = nil, birthday: Date? = nil, userId: Int) {
    self.height = height
    self.image = image
    self.registedAt = registedAt
    self.clubs = clubs
    self.weight = weight
    self.toeicScore = toeicScore
    self.birthday = birthday
    self.userId = userId
  }

  public init?(json: JSON) {
    if json.isEmpty {
      return nil
    }
    self.height = json["height"].double
    self.image = json["image"].string
    self.registedAt = Date.generateFromAPIFormat(string: json["registed_at"].string)!
    self.clubs = json["clubs"].array!.map { $0.string! } as? [String]
    self.weight = json["weight"].double
    self.toeicScore = json["toeic_score"].int
    self.birthday = Date.generateFromAPIFormat(string: json["birthday"].string)
    self.userId = json["user_id"].int!
  }

  public static func ==(left: UserProfileEntity, right: UserProfileEntity) -> Bool {
    return left.user_id == right.user_id

  }

  var serialized: [String: Any] {
    var param: [String: Any] = [:]
    param["height"] = height?.serialized
    param["image"] = image?.serialized
    param["registed_at"] = registedAt.serialized
    param["clubs"] = clubs?.serialized
    param["weight"] = weight?.serialized
    param["toeic_score"] = toeicScore?.serialized
    param["birthday"] = birthday?.serialized
    param["user_id"] = userId.serialized
    return param
  }
}
