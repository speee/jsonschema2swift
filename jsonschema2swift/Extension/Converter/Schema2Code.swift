//
//  Schema2Code.swift
//  jsonschema2swift
//
//  Created by hayato.iida on 2016/08/30.
//  Copyright © 2016年 hayato.iida. All rights reserved.
//

import Foundation

struct Schema2Code {

  func convert(inputPath: String, outputPath: String) throws {
    let dataFromString = try! Data(contentsOf: URL(fileURLWithPath: inputPath))
    let json = JSON(data: dataFromString)
    Generator(rootJSON: json).generate(path: outputPath)
  }

}
