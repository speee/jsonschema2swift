//
//  Generator.swift
//  jsonschema2swift
//
//  Created by hayato.iida on 2016/08/29.
//  Copyright © 2016年 hayato.iida. All rights reserved.
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

    beGenerated.entities().forEach {
      try! $0.1.write(toFile: "\(path)/Entity/\($0.0.snake2Camel)Entity.swift", atomically: true, encoding: String.Encoding.utf8)
    }

    beGenerated.responses().forEach {
      try! $0.1.write(toFile: "\(path)/Entity/\($0.0).swift", atomically: true, encoding: String.Encoding.utf8)
    }

    let links = rootJSON["definitions"].flatMap {
      $0.1["links"].arrayValue
    }.map {
      LinkSchema(json: $0, rootJSON: rootJSON)
    }
    let api = APIGenerator(rootSchema: rootSchema, links: links).generate()

    try! api.write(toFile: "\(path)/API.swift", atomically: true, encoding: String.Encoding.utf8)


  }

}
