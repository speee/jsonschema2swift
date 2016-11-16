//
//  SchemaGenerated.swift
//  jsonschema2swift
//
//  Created by hayato.iida on 2016/10/04.
//  Copyright © 2016年 Speee, Inc. All rights reserved.
//

import Foundation

class SchemaGenerated {
  let rootJSON: JSON
  let rootSchema: Schema

  init(rootJSON: JSON) {
    self.rootJSON = rootJSON
    self.rootSchema = Schema(byRootJSON: rootJSON)!
  }

  func entities() -> [(String, String)] {
    return entityRefs().map {
      let schema = Schema(byRef: $0.1, rootJSON: rootJSON)!
      return (schema.title ?? $0.0, EntityGenerator(rootSchema: rootSchema, name: schema.title ?? $0.0, schema: schema).generate())
    }
  }

  func entityRefs() -> [(String, String)] {
    let definitions = rootSchema.definitions!.flatMap {
      return self.definitionSchemas($1.title ?? $0, schema: $1, path: "#/definitions/\($0)")
    }

    let linkSchemas = rootSchema.definitions!.filter {
      ($1.links != nil)
    }.flatMap {
      return self.linkSchemasForEntity($1.title ?? $0, schema: $1.links!)
    }
    let targetSchemas = rootSchema.definitions!.filter {
      ($1.links != nil)
    }.flatMap {
      return self.targetSchemasForEntity($1.title ?? $0, schema: $1.links!)
    }

    let targetParameterSchema = rootSchema.definitions!.filter {
      $1.links != nil
    }.flatMap {
      return self.targetPropertySchemas(schemas: $1.links!, path: "#/definitions/\($0)")
    }
    return definitions + linkSchemas + targetSchemas + targetParameterSchema
  }


  func definitionSchemas(_ key: String, schema: DefinitionSchema, path: String) -> [(String, String)] {
    return schema.definitions!.filter {
          schemaIsObject(schema: $1) || schemaIsObjectInArray(schema: $1)
        }.flatMap {
          self.definitionSchema($0, schema: $1, path: path)
        } + [(key, path: path)]
  }

  func definitionSchema(_ key: String, schema: PropertySchema, path: String) -> [(String, String)] {
    if schemaIsObject(schema: schema) {
      return [(key, path: path + "/definitions/\(key)")]
    } else {
      return self.definitionSchemas(schema.items!.title ?? key, schema: schema.items!, path: path + "/definitions/\(key)/items")
    }
  }

  func schemaIsObject(schema: TypeSchema) -> Bool {
    return !schema.type!.filter {
      $0 == .object
    }.isEmpty
  }

  func schemaIsArray(schema: TypeSchema) -> Bool {
    return !schema.type!.filter {
      $0 == .array
    }.isEmpty
  }

  func schemaIsObjectInArray(schema: TypeSchema) -> Bool {
    return schemaIsArray(schema: schema) &&
           !schema.items!.type!.filter {
             $0 == .object
           }.isEmpty
  }

  func linkSchemasForEntity(_ schemaName: String, schema: [LinkSchema]) -> [(String, String)] {
    return schema.enumerated().filter {
      $0.1.schema?.ref == nil &&
      $0.1.schema?.items?.ref == nil &&
      $0.1.schema?.properties != nil
    }.flatMap {
      refToPropertySchema(schemas: $0.1.schema!.properties, path: "#/definitions/\(schemaName)/links/\($0.0)/schema")
    }.flatMap {
      $0
    }
  }

  func targetSchemasForEntity(_ schemaName: String, schema: [LinkSchema]) -> [(String, String)] {
    return schema.enumerated().filter {
      $0.1.targetSchema?.ref == nil &&
      $0.1.targetSchema?.items?.ref == nil &&
      $0.1.targetSchema?.properties != nil
    }.map {
      targetSchemaForEntity(schema: $0.1.targetSchema!, path: "#/definitions/\(schemaName)/links/\($0.0)/targetSchema")
    }
  }

  func targetSchemaForEntity(schema: TargetSchema, path: String) -> (String, String) {
    if schemaIsObjectInArray(schema: schema) {
      return (schema.title!, path + "/items")
    } else {
      return (schema.title!, path)
    }
  }

  func targetSchemas(_ schemaName: String, json: [JSON]) -> [(String, String)] {
    return json.enumerated().filter {
      !$0.1["targetSchema"].isEmpty
    }.map {
      ($0.1["title"].stringValue, "#/definitions/\(schemaName)/links/\($0.0)/targetSchema")
    }
  }

  func targetPropertySchemas(schemas: [LinkSchema], path: String) -> [(String, String)] {
    return schemas.enumerated().filter {
      $0.1.targetSchema != nil
    }.flatMap {
      return self.targetPropertySchema(schema: $0.1.targetSchema!, path: "\(path)/links/\($0.0)/targetSchema")
    }.flatMap {
      $0
    }
  }


  func targetPropertySchema(schema: TargetSchema, path: String) -> [(String, String)]? {
    guard let properties = schema.properties else {
      return nil
    }
    return refToPropertySchema(schemas: properties, path: path)
  }

  func refToPropertySchema(schemas: [String: PropertySchema]?, path: String) -> [(String, String)]? {
    guard let schemas = schemas else {
      return nil
    }
    let objectRefs = schemas.filter {
      $1.ref == nil &&
      $1.type?.contains(.object) ?? false
    }.flatMap {
      [($1.title ?? $0, "\(path)/properties/\($0)")] + (refToPropertySchema(schemas: $1.properties, path: "\(path)/properties/\($0)") ?? [])
    }

    let arrayRefs = schemas.filter {
      $1.ref == nil &&
      $1.type?.contains(.array) ?? false &&
      $1.items != nil &&
      $1.items?.ref == nil
    }.map {
      ($0, $1.items!)
    }.filter {
      $1.type?.contains(.object) ?? false
    }.flatMap {
      [($1.title ?? $0, "\(path)/properties/\($0)/items")] + (refToPropertySchema(schemas: $1.properties, path: "\(path)/properties/\($0)/items") ?? [])
    }
    return objectRefs + arrayRefs
  }

}
