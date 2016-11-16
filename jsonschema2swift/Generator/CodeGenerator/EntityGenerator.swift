//
//  EntityGenerator.swift
//  jsonschema2swift
//
//  Created by hayato.iida on 2016/08/29.
//  Copyright © 2016年 Speee, Inc. All rights reserved.
//

import Foundation

class EntityGenerator {

  let rootSchema: Schema
  let name: String
  let schema: RootSchemaProtocol

  init(rootSchema: Schema, name: String, schema: RootSchemaProtocol) {
    self.rootSchema = rootSchema
    self.name = name
    self.schema = schema
  }

  func generate() -> String {
    return topDocComment ++
           importCode ++
           declareCode ++
           enumDefinitions ++
           parametersCode ++
           initializerCode ++
           mappingBaseCode ++
           comparisonCode ++
           serializedCodeBlock ++
           bottomCode ++
           ""
  }

  var topDocComment: String {
    get {
      return "/// \(name.snake2Camel)Entity.swift" ++
             "/// generated by jsonschema2swift" + n
    }
  }
  var importCode: String {
    get {
      return "import Foundation" ++
             "import SwiftyJSON" + n
    }

  }

  /// example:struct UserEntity: EntityType {
  var declareCode: String {
    get {
      return declareCodeDoc ++
             "public struct \(name.snake2Camel)Entity: \(singleEntityType) {"
    }
  }

  var singleEntityType: String {
    get {
      return containOtherEntity ? "RelatedEntityType" : "SingleEntityType"
    }
  }

  var containOtherEntity: Bool {
    get {
      return self.schema.properties!.reduce(false) {
        $0 || $1.1.containOtherEntity($1.1)
      }
    }
  }

  var declareCodeDoc: String {
    get {
      return "" ++
             (self.schema.title != nil ? "/// \(self.schema.title!)" : "") +
             (self.schema.description != nil ? n + "///" ++ "/// \(self.schema.description!)" : "")
    }
  }

  var enumDefinitions: String {
    return  self.schema.properties!.filter {
      $1.enumDescription != nil
    }.map {
      $1.enumDefinitionCode($0)
    }.reduce("") {
      $0 ++ $1
    }
  }


  var parametersCode: String {
    get {
      return  self.schema.properties!.map {
        let nullableCode = $1.nullable(self.schema.required.contains($0)) ? "?" : ""
        return parametersCodeDoc(schema: $1) ++
               "  public var \($0.snake2camel): " + $1.typeCode($0) + nullableCode + n
      }.reduce("") {
        $0 + $1
      }
    }
  }

  func parametersCodeDoc(schema: PropertySchema) -> String {
    return (schema.description != nil ? "  /// \(schema.description!)" : "") +
           (schema.pattern != nil ? n + "  /// - pattern: \(schema.pattern!)" : "") +
           (schema.minLength != nil ? n + "  /// - minLength: \(schema.minLength!)" : "") +
           (schema.maxLength != nil ? n + "  /// - maxLength: \(schema.maxLength!)" : "") +
           (schema.minimum != nil ? n + "  /// - minimum: \(schema.minimum!)" : "") +
           (schema.maximum != nil ? n + "  /// - minimum: \(schema.maximum!)" : "")
  }

  var mappingBaseCode: String {
    get {
      return "" +
             "  public init?(json: JSON) {" ++
             "    if json.isEmpty {" ++
             "      return nil" ++
             "    }" ++
             mappingCode +
             "  }"
    }
  }

  var mappingCode: String {
    get {
      return  self.schema.properties!.map {
        $1.mappingCode($0, required: self.schema.required.contains($0))
      }.reduce("") {
        $0 + $1
      }
    }
  }

  var initializerCode: String {
    get {
      return "" +
             "  public init(\(initializerParamCode)) {" ++
             initializerMappingCode ++
             "  }" ++
             ""
    }
  }

  var initializerParamCode: String {
    get {
      return self.schema.properties!.map {
        let nullableCode = $1.nullable(self.schema.required.contains($0)) ? "? = nil" : ""
        return "\($0.snake2camel): " + $1.typeCode($0) + nullableCode
      }.combineCodeBlock()
    }
  }

  var initializerMappingCode: String {
    get {
      return self.schema.properties!.map {
        return "    self.\($0.0.snake2camel) = \($0.0.snake2camel)"
      }.combineCodeBlock(n)
    }
  }

  var comparisonCode: String {
    get {
      if self.schema.identity.isEmpty {
        return ""
      }
      return "" ++
             "  public static func ==(left: \(name.snake2Camel)Entity, right: \(name.snake2Camel)Entity) -> Bool {" ++
             "    return " + self.schema.identity.map {
               "left.\($0.propertyKey) == right.\($0.propertyKey)" + n
             }.combineCodeBlock(" && ")
             + n +
             "  }" + n
    }
  }

  var serializedCodeBlock: String {
    get {
      return "" +
             "  var serialized: [String: Any] {" ++
             "    var param: [String: Any] = [:]" ++
             serializedCode +
             "    return param" ++
             "  }"
    }
  }
  var serializedCode: String {
    get {
      return  self.schema.properties!.map {
        $1.serializedCode($0, required: self.schema.required.contains($0))
      }.reduce("") {
        $0 + $1
      }
    }
  }

  var bottomCode: String {
    get {
      return "}"
    }
  }

}


extension RootSchemaProtocol where Self: JsonSchema {
  /// 独自定義
  /// プライマリキーに相当
  /// `==`のコードを生成
  var identity: [PropertySchema] {
    get {
      return json["identity"].arrayValue.map {
        PropertySchema(json: $0, rootJSON: rootJSON)!
      }
    }
  }
}
