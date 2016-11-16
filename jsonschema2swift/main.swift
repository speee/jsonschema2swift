//
//  main.swift
//  jsonschema2swift
//
//  Created by hayato.iida on 2016/08/26.
//  Copyright © 2016年 Speee, Inc. All rights reserved.
//




if CommandLine.argc < 3 {
  print("./jsonschema2swift {jsonFile} {out put directory}")
}

let jsonPath = CommandLine.arguments[1]
let outputPath = CommandLine.arguments[2]
try! Schema2Code().convert(inputPath: jsonPath, outputPath: outputPath)
