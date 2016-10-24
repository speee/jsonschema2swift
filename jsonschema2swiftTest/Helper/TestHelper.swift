//
//  testHelper.swift
//  jsonschema2swift
//
//  Created by hayato.iida on 2016/08/29.
//  Copyright © 2016年 hayato.iida. All rights reserved.
//

import Foundation

class TestHelper {

  let targetDirectory: String
  init(targetDirectory: String) {
    self.targetDirectory = targetDirectory
  }
  var bundle: Bundle {
    get {
      return Bundle(for: TestHelper.self)
    }
  }

  func testJsonData(_ resourceName: String) -> String {
    return self.testData(resourceName, ofType: "json")
  }

  func testSwiftData(_ resourceName: String) -> String {
    return self.testData(resourceName, ofType: "swift")
  }

  func rootJSON(_ r: Any) -> JSON {
    let test1Input = self.testJsonData("api")
    let dataFromString = test1Input.data(using: String.Encoding.utf8, allowLossyConversion: false)
    return JSON(data: dataFromString!)
  }

  func testData(_ resourceName: String, ofType: String) -> String {
    let resources = bundle.path(forResource: "TestData", ofType: "bundle")
    let newBundle = Bundle(path: resources! + "/" + targetDirectory)
    let outPath = newBundle?.path(forResource: resourceName, ofType: ofType)
    let dataString = try! String(contentsOfFile: outPath!)
    return dataString
  }

}
