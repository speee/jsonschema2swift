//
// Created by hayato.iida on 2016/09/16.
// Copyright (c) 2016 Speee, Inc. All rights reserved.
//

import Foundation


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

  func mappingCode(_ propertyName: String, required: Bool) -> String {
    return self.codeParseOneOf(propertyName, block: codeMappingBy(required))
  }

  func serializedCode(_ propertyName: String, required: Bool) -> String {
    return self.codeParseOneOf(propertyName, block: codeSerializedBy(required))
  }

  func enumDefinitionCode(_ propertyName: String) -> String {
    return self.codeParseOneOf(propertyName, block: codeEnumsDeclare)
  }

  func responseEntityCode(_ propertyName: String = "") -> String {
    return self.codeParseOneOf(propertyName, block: responseEntity)
  }


  fileprivate func codeParseOneOf(_ propertyName: String, block: (_ schema: TypeSchema, _ propertyName: String, _ type: ConcreteType) -> String) -> String {
    if let oneOf = self.oneOf {
      return  oneOf.flatMap {
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

  fileprivate func codeInnerTypeBy(_ schema: TypeSchema, propertyName: String, type: ConcreteType) -> String {
    switch type {
    case .null:
      return ""
    case .array:
      return "\(schema.items!.typeCode())"
    case .object:
        return "\((schema.title ?? propertyName).snake2Camel )" + "Entity"
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

  fileprivate func codeTypeBy(_ schema: TypeSchema, propertyName: String, type: ConcreteType) -> String {
    //FIXME
    if (schema.enumDescription) != nil {
      return propertyName.snake2Camel
    }
    switch type {
    case .array:
      return "[\(codeInnerTypeBy(schema, propertyName: propertyName, type: type))]"
    default:
      return codeInnerTypeBy(schema, propertyName: propertyName, type: type)
    }
  }

  fileprivate func codeMappingBy(_ required: Bool) -> ((TypeSchema, String, ConcreteType) -> String) {
    return { (_ schema: TypeSchema, propertyName: String, type: ConcreteType) in
      //FIXME
      if (schema.enumDescription) != nil {
        return "    self.\(propertyName.snake2camel) = \(propertyName.snake2Camel)(rawValue: json[\"\(propertyName)\"].\(self.rawValue(type: type))!)!" + n
      }
      switch type {
      case .null:
        return ""
      case .array:
        let nullCheck = self.nullable(required) ? "?" : ""
        return "    self.\(propertyName.snake2camel) = json[\"\(propertyName)\"].arrayValue.map { \(self.typeInnerCode())(json: $0)! } as\(nullCheck) \(self.typeCode())" + n
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

  fileprivate func rawValue(type: ConcreteType)->String{
    switch type {
    case .integer:
      return "int"
    default:
      return type.rawValue
    }
  }

  fileprivate func responseEntity(_ schema: TypeSchema, propertyName: String, type: ConcreteType) -> String {
    switch type {
    case .array:
      return "ResponseArray<\(schema.items!.typeCode())>"
    case .object:
      return "ResponseEntity<\(self.typeCode())>"
    default:
      return "ResponseEntity<NoContentEntity>"
    }
  }



  fileprivate func codeSerializedBy(_ required: Bool) -> ((TypeSchema, String, ConcreteType) -> String) {
    return { (_ schema: TypeSchema, propertyName: String, type: ConcreteType) in
      let nullCheck = self.nullable(required) ? "?" : ""
      return "    param[\"\(propertyName.snake2camel)\"] = \(propertyName.snake2camel)\(nullCheck).serialized" + n
    }
  }

  fileprivate func codeEnumsDeclare(_ schema: TypeSchema, propertyName: String, type: ConcreteType) -> String {
    return "  /// \(schema.description!)" ++
           "  enum \(propertyName.snake2Camel): \(schema.codeInnerTypeBy(schema, propertyName: propertyName, type: type)) {" +
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
