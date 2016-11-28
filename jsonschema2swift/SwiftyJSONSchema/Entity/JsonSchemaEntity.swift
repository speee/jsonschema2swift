//
//  JsonSchemaEntity.swift
//  jsonschema2swift
//
//  Created by hayato.iida on 2016/08/30.
//  Copyright © 2016年 Speee, Inc. All rights reserved.
//

import Foundation

protocol JsonSchema {
  var json: JSON { get set }
  var rootJSON: JSON { get set }
  init()
}

protocol Referenceable: JsonSchema {
  var ref: String? { get set }
}

extension Referenceable {
  init?(json: JSON, rootJSON: JSON) {
    guard !json.isEmpty else {
      return nil
    }
    self.init()
    self.rootJSON = rootJSON
    if let ref = json["$ref"].string {
      // schemaが参照形式の場合
      self.json = json.extract(ref, rootJSON: rootJSON)
      self.ref = ref
    } else {
      self.json = json
    }
  }

  init?(byRootJSON: JSON) {
    self.init(json: byRootJSON, rootJSON: byRootJSON)
  }

  init?(byRef: String, rootJSON: JSON) {
    self.init(json: rootJSON.extract(byRef, rootJSON: rootJSON), rootJSON: rootJSON)
    self.ref = byRef
  }
}

protocol RootSchemaProtocol: JsonSchema {
  var links: [LinkSchema]? { get }
  var properties: [String: PropertySchema]? { get }
  var required: [String] { get }
  var title: String? { get }
  var description: String? { get }
}

extension RootSchemaProtocol {
  var title: String? {
    get {
      return json["title"].string
    }
  }

  var description: String? {
    get {
      return json["description"].string
    }
  }
  var links: [LinkSchema]? {
    get {
      return json["links"].array?.map {
        LinkSchema(json: $0, rootJSON: rootJSON)
      }
    }
  }

  var properties: [String: PropertySchema]? {
    get {
      return json["properties"].dictionaryValue.mapPairs {
        ($0, PropertySchema(json: $1, rootJSON: self.rootJSON)!)
      }
    }
  }
  var required: [String] {
    get {
      return json["required"].arrayValue.map {
        $0.stringValue
      }
    }
  }
}

/// type
/// typeは必ず配列形式で記載し、2個以内とする
/// 2個指定する場合は、片方を"null"にする
///  ["String", "Integer"]と記載すると、型を定義できないため

enum ConcreteType: String {
  case null = "null"
  case array = "array"
  case object = "object"
  case boolean = "boolean"
  case integer = "integer"
  case number = "number"
  case string = "string"
}

protocol TypeSchema: JsonSchema {
  var items: DefinitionSchema? { get }
  var type: [ConcreteType]? { get }
  var format: String? { get }
  var oneOf: [PropertySchema]? { get }
  var ref: String? { get set }
  var enumValues: [String]? { get }
  /// 独自定義
  var enumDescription: [EnumDescription]? { get }
  var media: MediaSchema? { get }
  var title: String? { get }
  var description: String? { get }
  
}

extension TypeSchema {
  var title: String? {
    get {
      return json["title"].string
    }
  }

  var description: String? {
    get {
      return json["description"].string
    }
  }
  var enumValues: [String]? {
    get {
      return json["enum"].array?.map {
        $0.stringValue
      }
    }
  }

  var type: [ConcreteType]? {
    get {
      return json["type"].array?.map {
        ConcreteType(rawValue: $0.stringValue)!
      }
    }
  }

  var format: String? {
    get {
      return json["format"].string
    }
  }

  var items: DefinitionSchema? {
    get {
      return DefinitionSchema(json: json["items"], rootJSON: rootJSON)
    }
  }

  var media: MediaSchema? {
    get {
      return MediaSchema(json: json["media"])
    }
  }
  /// 独自定義
  var enumDescription: [EnumDescription]? {
    get {
      return json["enumDescription"].array?.map {
        EnumDescription(json: $0, rootJSON: rootJSON)
      }
    }
  }

  var oneOf: [PropertySchema]? {
    get {
      return json["oneOf"].array?.map {
        PropertySchema(json: $0, rootJSON: rootJSON)!
      }
    }
  }

}


struct Schema: Referenceable, TypeSchema, RootSchemaProtocol {
  var json: JSON
  var rootJSON: JSON
  var ref: String?
  init() {
    self.json = [:]
    self.rootJSON = [:]
  }

  var schema: String? {
    get {
      return json["$schema"].string
    }
  }
  var type: [String]? {
    get {
      return json["type"].array?.map {
        $0.stringValue
      }
    }
  }
  var definitions: [String: DefinitionSchema]? {
    get {
      return json["definitions"].dictionaryValue.mapPairs {
        ($0, DefinitionSchema(json: $1, rootJSON: self.rootJSON)!)
      }
    }
  }

  var id: String? {
    get {
      return json["id"].string
    }
  }
  var title: String? {
    get {
      return json["title"].string
    }
  }

  var description: String? {
    get {
      return json["description"].string
    }
  }

}

struct DefinitionSchema: Referenceable, TypeSchema, RootSchemaProtocol {
  var json: JSON
  var rootJSON: JSON
  var ref: String?
  init() {
    self.json = [:]
    self.rootJSON = [:]
  }

  var definitions: [String: PropertySchema]? {
    get {
      return json["definitions"].dictionaryValue.mapPairs {
        ($0, PropertySchema(json: $1, rootJSON: self.rootJSON)!)
      }
    }
  }
  var title: String? {
    get {
      return json["title"].string
    }
  }

  var description: String? {
    get {
      return json["description"].string
    }
  }

}

struct TargetSchema: Referenceable, TypeSchema, RootSchemaProtocol {
  var json: JSON
  var rootJSON: JSON
  var ref: String?
  init() {
    self.json = [:]
    self.rootJSON = [:]
  }

  var title: String? {
    get {
      return json["title"].string
    }
  }

  var description: String? {
    get {
      return json["description"].string
    }
  }
}

struct PropertySchema: Referenceable, TypeSchema {
  var json: JSON
  var rootJSON: JSON
  var ref: String?
  init() {
    self.json = [:]
    self.rootJSON = [:]
  }

  var maximum: String? {
    get {
      return json["maximum"].string
    }
  }
  var multipleOf: String? {
    get {
      return json["multipleOf"].string
    }
  }
  var exclusiveMaximum: String? {
    get {
      return json["exclusiveMaximum"].string
    }
  }
  var minimum: String? {
    get {
      return json["minimum"].string
    }
  }
  var exclusiveMinimum: String? {
    get {
      return json["exclusiveMinimum"].string
    }
  }
  var maxLength: String? {
    get {
      return json["maxLength"].string
    }
  }
  var minLength: String? {
    get {
      return json["minLength"].string
    }
  }
  var pattern: String? {
    get {
      return json["pattern"].string
    }
  }
  var additionalItems: String? {
    get {
      return json["additionalItems"].string
    }
  }
  var maxItems: String? {
    get {
      return json["maxItems"].string
    }
  }
  var minItems: String? {
    get {
      return json["minItems"].string
    }
  }
  var uniqueItems: String? {
    get {
      return json["uniqueItems"].string
    }
  }
  var maxProperties: String? {
    get {
      return json["maxProperties"].string
    }
  }
  var minProperties: String? {
    get {
      return json["minProperties"].string
    }
  }
  var additionalProperties: String? {
    get {
      return json["additionalProperties"].string
    }
  }
  var definitions: String? {
    get {
      return json["definitions"].string
    }
  }
  var properties: [String: PropertySchema]? {
    get {
      return json["properties"].dictionaryValue.mapPairs {
        ($0, PropertySchema(json: $1, rootJSON: self.rootJSON)!)
      }
    }
  }
  var patternProperties: String? {
    get {
      return json["patternProperties"].string
    }
  }
  var dependencies: String? {
    get {
      return json["dependencies"].string
    }
  }

  var allOf: [PropertySchema]? {
    get {
      return json["allOf"].array?.map {
        PropertySchema(json: $0, rootJSON: rootJSON)!
      }
    }
  }
  var anyOf: [PropertySchema]? {
    get {
      return json["anyOf"].array?.map {
        PropertySchema(json: $0, rootJSON: rootJSON)!
      }
    }
  }
  var not: PropertySchema? {
    get {
      return PropertySchema(json: json["not"], rootJSON: rootJSON)
    }
  }


}

struct LinkSchema {
  var json: JSON
  var rootJSON: JSON

  var href: String
  var rel: String

  var encType: String?
  var description: String?
  var method: String?
  var title: String?
  var mediaType: String?
  var schema: Schema?
  var targetSchema: TargetSchema?


  init(json: JSON, rootJSON: JSON) {
    self.href = json["href"].stringValue
    self.rel = json["rel"].stringValue
    self.encType = json["encType"].stringValue
    self.description = json["description"].stringValue
    self.method = json["method"].stringValue
    self.title = json["title"].stringValue
    self.mediaType = json["mediaType"].stringValue
    self.schema = Schema(json: json["schema"], rootJSON: rootJSON)
    self.targetSchema = TargetSchema(json: json["targetSchema"], rootJSON: rootJSON)
    self.json = json
    self.rootJSON = rootJSON
  }
}

struct MediaSchema {
  var binaryEncoding: String
  var type: String

  init?(json: JSON) {
    guard !json.isEmpty else {
      return nil
    }
    self.binaryEncoding = json["binaryEncoding"].stringValue
    self.type = json["type"].stringValue
  }
}

/// 独自定義
/// enumプロパティの解説用に、独自に定義したプロパティ
/// モデルクラスを自動生成する際に、各要素の名称を付けるために使う

struct EnumDescription {
  var json: JSON
  var rootJSON: JSON


  var key: String
  var value: String

  init(json: JSON, rootJSON: JSON) {
    self.key = json["key"].stringValue
    self.value = json["value"].stringValue
    self.json = json
    self.rootJSON = rootJSON
  }
}
