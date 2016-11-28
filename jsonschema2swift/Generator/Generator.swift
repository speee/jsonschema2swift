//
//  Generator.swift
//  jsonschema2swift
//
//  Created by hayato.iida on 2016/08/29.
//  Copyright © 2016年 Speee, Inc. All rights reserved.
//

import Foundation

class Generator {
  let rootJSON: JSON
  let rootSchema: Schema

  init(rootJSON: JSON) {
    self.rootJSON = rootJSON
    self.rootSchema = Schema(byRootJSON: rootJSON)!
  }

  func generate(path: String) {
    let fileManager: FileManager = FileManager()

    try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    let entityPath = path + "/Entity"
    if fileManager.fileExists(atPath: entityPath) {
      try! fileManager.removeItem(atPath: entityPath)
    }
    try! fileManager.createDirectory(atPath: entityPath, withIntermediateDirectories: true, attributes: nil)

    let beGenerated = SchemaGenerated(rootJSON: rootJSON)

    // generate Entities
    beGenerated.entities().forEach {
          let fileName = fixEntitySuffix(code: "\($0.0.snake2Camel)Entity")
          try! $0.1.write(toFile: "\(path)/Entity/\(fileName).swift",
                          atomically: true, encoding: String.Encoding.utf8)
        }


    // generate API.swift
    let links = rootJSON["definitions"].flatMap {
      $0.1["links"].arrayValue
    }.map {
      LinkSchema(json: $0, rootJSON: rootJSON)
    }.sorted { (schema0: LinkSchema, schema1: LinkSchema) in
      (schema0.title ?? "") < (schema1.title ?? "")
    }
    let api = APIGenerator(rootSchema: rootSchema, links: links).generate()
    try! api.write(toFile: "\(path)/API.swift", atomically: true, encoding: String.Encoding.utf8)


    // generate APIKey.swift
    let apiKey = APIGenerator(rootSchema: rootSchema, links: links).generateKey()
    try! apiKey.write(toFile: "\(path)/APIKey.swift", atomically: true, encoding: String.Encoding.utf8)

  }

}
