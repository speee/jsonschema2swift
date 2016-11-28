//
// Created by hayato.iida on 2016/09/16.
// Copyright (c) 2016 Speee, Inc. All rights reserved.
//

import Foundation

enum CodeClass {
  case null
  case array
  case object
  case bool
  case int
  case double
  case string
  case date
  case image
}

extension PropertySchema {
  var propertyKey: String {
    get {
      return title ?? ref!.components(separatedBy: "/").last!
    }
  }
}


extension TypeSchema {

  func nullable(_ required: Bool) -> Bool {
    if !required {
      return true
    }
    if let oneOf = self.oneOf {
      //OneOf
      return !oneOf.filter {
        $0.type!.contains(.null)
      }.isEmpty
    } else if self.enumValues != nil {
      return false
    } else if let type = self.type {
      assert(type.count <= 2, "propertySchema.type.count > 2")
      return type.contains(.null)
    } else {
      assertionFailure("property  \(title) cant convert to Type")
    }
    return false
  }

  /// - return: "String","Bool","UserEntity"
  func typeCode(_ propertyName: String = "") -> String {
    return self.codeParseOneOf(propertyName, block: codeTypeBy)
  }

  func typeInnerCode(_ propertyName: String = "") -> String {
    return self.codeParseOneOf(propertyName, block: codeInnerTypeBy)
  }

  func codeInnerClass(_ propertyName: String = "") -> CodeClass {
    return self.codeParseOneOf(propertyName, block: codeInnerClassBy)
  }

  func codeClass(_ propertyName: String = "") -> CodeClass {
    return self.codeParseOneOf(propertyName, block: codeClassBy)
  }

  func mappingCode(_ propertyName: String, required: Bool) -> String {
    return self.codeParseOneOf(propertyName, block: codeMappingBy(required))
  }

  func serializedCode(_ propertyName: String, required: Bool) -> String {
    return self.codeParseOneOf(propertyName, block: codeSerializedBy(required))
  }

  func enumDefinitionCode(_ propertyName: String) -> String {
    return self.codeParseOneOf(propertyName, block: codeEnumsDeclare)
  }

  fileprivate func codeParseOneOf(_ propertyName: String, block: (_ schema: TypeSchema, _ propertyName: String, _ type: ConcreteType) -> String) -> String {
    if let oneOf = self.oneOf {
      return oneOf.flatMap {
        return $0.type!.first == .null ? nil : $0
      }.first!.codeTypeString(propertyName, block: block)
    } else if self.enumValues != nil {
    }
    return self.codeTypeString(propertyName, block: block)
  }

  fileprivate func codeTypeString(_ propertyName: String, block: (_ schema: TypeSchema, _ propertyName: String, _ type: ConcreteType) -> String) -> String {
    if let type = self.type {
      assert(type.count <= 2, "propertySchema.type.count > 2")
      let typeNotNull = type.filter {
        $0 != .null
      }.first
      if let type = typeNotNull {
        return block(self, propertyName, type)
      }
    }
    return ""
  }

  fileprivate func codeParseOneOf(_ propertyName: String, block: (_ schema: TypeSchema, _ propertyName: String, _ type: ConcreteType) -> CodeClass) -> CodeClass {
    if let oneOf = self.oneOf {
      return oneOf.flatMap {
        return $0.type!.first == .null ? nil : $0
      }.first!.codeTypeString(propertyName, block: block)
    } else if self.enumValues != nil {
    }
    return self.codeTypeString(propertyName, block: block)
  }

  fileprivate func codeTypeString(_ propertyName: String, block: (_ schema: TypeSchema, _ propertyName: String, _ type: ConcreteType) -> CodeClass) -> CodeClass {
    if let type = self.type {
      assert(type.count <= 2, "propertySchema.type.count > 2")
      let typeNotNull = type.filter {
        $0 != .null
      }.first
      if let type = typeNotNull {
        return block(self, propertyName, type)
      }
    }
    return .null
  }

  fileprivate func codeInnerTypeBy(_ schema: TypeSchema, propertyName: String, type: ConcreteType) -> String {
    switch type {
    case .null:
      return ""
    case .array:
      return "\(schema.items!.typeCode())"
    case .object:
      return fixEntitySuffix(code: "\((schema.title ?? propertyName).snake2Camel)Entity")
    case .boolean:
      return "Bool"
    case .integer:
      return "Int"
    case .number:
      return "Double"
    case .string:
      if let format = self.format, format == "date-time" {
        return "Date"
      } else if (schema.media) != nil {
        return "Image"
      } else {
        return "String"
      }
    }
  }

  func containOtherEntity(_ schema: TypeSchema) -> Bool {
    if let oneOf = self.oneOf {
      //OneOf
      return !oneOf.flatMap {
        $0.type!
      }.reduce(false) {
        return $0 || containOtherEntity(schema, type: $1)
      }
    }

    return schema.type!.reduce(false) {
      return $0 || containOtherEntity(schema, type: $1)
    }
  }

  func containOtherEntity(_ schema: TypeSchema, type: ConcreteType) -> Bool {
    switch type {
    case .object:
      return true
    case .array:
      return containOtherEntity(schema.items!)
    default:
      return false
    }
  }

  fileprivate func codeInnerClassBy(_ schema: TypeSchema, propertyName: String, type: ConcreteType) -> CodeClass {
    switch type {
    case .null:
      return .null
    case .array:
      return schema.items!.codeInnerClass()
    case .object:
      return .object
    case .boolean:
      return .bool
    case .integer:
      return .int
    case .number:
      return .double
    case .string:
      if let format = self.format, format == "date-time" {
        return .date
      } else if (schema.media) != nil {
        return .image
      } else {
        return .string
      }
    }
  }

  fileprivate func codeClassBy(_ schema: TypeSchema, propertyName: String, type: ConcreteType) -> CodeClass {
    switch type {
    case .null:
      return .null
    case .array:
      return .array
    case .object:
      return .object
    case .boolean:
      return .bool
    case .integer:
      return .int
    case .number:
      return .double
    case .string:
      if let format = self.format, format == "date-time" {
        return .date
      } else if (schema.media) != nil {
        return .image
      } else {
        return .string
      }
    }
  }


  var parentSchema: TypeSchema? {
    guard let ref = ref else {
      return nil
    }
    let separates = ref.components(separatedBy: "/")
    return PropertySchema(byRef: separates[0 ... (separates.count - 3)].joined(separator: "/"), rootJSON: self.rootJSON)!
  }

  fileprivate func codeTypeBy(_ schema: TypeSchema, propertyName: String, type: ConcreteType) -> String {
    //FIXME
    if (schema.enumDescription) != nil {
      return getPropertyTypeName(schema, propertyName: propertyName)
    }
    switch type {
    case .array:
      return "[\(codeInnerTypeBy(schema, propertyName: propertyName, type: type))]"
    default:
      return (fixEntitySuffix • codeInnerTypeBy)(schema, propertyName: propertyName, type: type)
    }
  }

  fileprivate func getPropertyTypeName(_ schema: TypeSchema, propertyName: String) -> String {
    if let parentSchema = schema.parentSchema {
      return fixEntitySuffix(code: parentSchema.title!.snake2Camel + "Entity") + "." + (schema.title ?? propertyName).snake2Camel
    } else {
      return propertyName.snake2Camel
    }
  }

  fileprivate func codeMappingBy(_ required: Bool) -> ((TypeSchema, String, ConcreteType) -> String) {
    return { (_ schema: TypeSchema, propertyName: String, type: ConcreteType) in
      //FIXME
      if (schema.enumDescription) != nil {
        return "    self.\(propertyName.snake2camel) = \(self.getPropertyTypeName(schema, propertyName: propertyName))(rawValue: json[\"\(propertyName)\"].\(self.rawValue(type: type))!)!" + n
      }
      switch type {
      case .null:
        return ""
      case .array:
        let nullCheck = self.nullable(required) ? "?" : ""
        return "    self.\(propertyName.snake2camel) = json[\"\(propertyName)\"].arrayValue.map { \(self.mapInitCode(propertyName))! } as\(nullCheck) \(self.typeCode())" + n
      case .object:
        let nullCheck = self.nullable(required) ? "?" : "!"
        return "    self.\(propertyName.snake2camel) = \(self.typeCode())(json: json[\"\(propertyName)\"]) as \(self.typeCode())\(nullCheck)" + n
      case .boolean:
        let nullCheck = self.nullable(required) ? "" : "!"
        return "    self.\(propertyName.snake2camel) = json[\"\(propertyName)\"].\(self.typeCode().snake2camel)\(nullCheck)" + n
      case .integer:
        let nullCheck = self.nullable(required) ? "" : "!"
        return "    self.\(propertyName.snake2camel) = json[\"\(propertyName)\"].\(self.typeCode().snake2camel)\(nullCheck)" + n
      case .number:
        let nullCheck = self.nullable(required) ? "" : "!"
        return "    self.\(propertyName.snake2camel) = json[\"\(propertyName)\"].\(self.typeCode().snake2camel)\(nullCheck)" + n
      case .string:
        let nullCheck = self.nullable(required) ? "" : "!"
        if let format = self.format, format == "date-time" {
          return "    self.\(propertyName.snake2camel) = Date.generateFromAPIFormat(string: json[\"\(propertyName)\"].string)\(nullCheck)" + n
        } else {
          return "    self.\(propertyName.snake2camel) = json[\"\(propertyName)\"].\(self.typeCode().snake2camel)\(nullCheck)" + n
        }
      }
    }
  }

  fileprivate func rawValue(type: ConcreteType) -> String {
    switch type {
    case .integer:
      return "int"
    default:
      return type.rawValue
    }
  }


  func mapInitCode(_ propertyName: String) -> String {
    switch self.codeInnerClass() {
    case .null:
      return ""
    case .array:

      return "json[\"\(propertyName)\"].arrayValue.map { ! }"
    case .object:
      return "\(self.typeInnerCode())(json: $0)"
    case .bool:
      return "$0.bool"
    case .int:
      return "$0.int"
    case .double:
      return "$0.double"
    case .string:
      return "$0.string"
    case .date:
      return "$0.date"
    case .image:
      return "$0.image"
    }
  }


  fileprivate func codeSerializedBy(_ required: Bool) -> ((TypeSchema, String, ConcreteType) -> String) {
    return { (_ schema: TypeSchema, propertyName: String, type: ConcreteType) in
      let nullCheck = self.nullable(required) ? "?" : ""
      return "    param[\"\(propertyName)\"] = \(propertyName.snake2camel)\(nullCheck).serialized" + n
    }
  }

  fileprivate func codeEnumsDeclare(_ schema: TypeSchema, propertyName: String, type: ConcreteType) -> String {
    return "  /// \(schema.description!)" ++
           "  public enum \(propertyName.snake2Camel): \(schema.codeInnerTypeBy(schema, propertyName: propertyName, type: type)) {" +
           schema.enumDescription!.map {
             switch type {
             case .integer:
               return "    case \($0.key.snake2camel) = \($0.value)"
             case .number:
               return "    case \($0.key.snake2camel) = \($0.value)"
             case .string:
               return "    case \($0.key.snake2camel) = \"\($0.value)\""
             default:
               return ""
             }
           }.reduce("") {
             $0 ++ $1
           } ++
           "  }" ++
           ""
  }
}


extension TargetSchema {
  func responseElementCode(_ propertyName: String = "") -> String {
    return self.codeParseOneOf(propertyName, block: responseElement)
  }

  fileprivate func responseElement(_ schema: TypeSchema, propertyName: String, type: ConcreteType) -> String {
    if let entityClass = singleResponse() {
      return "SingleResponse<\(entityClass)>"
    } else if let entityClass = arrayResponse() {
      return "ArrayResponse<\(entityClass)>"
    }
    switch type {
    case .object:
      return "DataResponse<\(self.typeCode())>"
    default:
      return "NoContentResponse"
    }
  }

  func singleResponse() -> String? {
    if self.properties?.count != 1 {
      return nil
    }
    if self.properties?.first?.value.codeClass() != .object {
      return nil
    }
    return self.properties?.first?.value.typeCode()
  }

  func arrayResponse() -> String? {
    if self.properties?.count != 1 {
      return nil
    }
    if self.properties?.first?.value.codeClass() != .array {
      return nil
    }
    return self.properties?.first?.value.typeInnerCode()
  }
}
