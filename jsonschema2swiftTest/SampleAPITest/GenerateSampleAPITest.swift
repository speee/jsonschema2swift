//
//  GenerateSampleAPITest.swift
//  jsonschema2swiftTest
//
//  Created by hayato.iida on 2016/08/29.
//  Copyright © 2016年 Speee, Inc. All rights reserved.
//

import XCTest


class GenerateSampleAPITest: XCTestCase {
  var rootJSON: JSON = [:]
  let testHelper = TestHelper(targetDirectory: "SampleAPITest")

  override func setUp() {
    super.setUp()
    rootJSON = testHelper.rootJSON(self)
  }

  func testGenerateEntities() {
    let entities = SchemaGenerated(rootJSON: rootJSON).entities()
    entities.forEach {
      let output = $0.1
      let expect = testHelper.testSwiftData("Entity/" + $0.0.snake2Camel + "Entity")
      XCTAssertEqual(output, expect)
    }
    XCTAssertEqual(entities.count, 11)
  }

  func testGenerateResponseEntities() {
    let entities = SchemaGenerated(rootJSON: rootJSON).responses()
    entities.forEach {
      let output = $0.1
      let expect = testHelper.testSwiftData("Entity/" + $0.0)
      XCTAssertEqual(output, expect)
    }
    let entitiesDict = Set(entities.map {
      $0.0
    })
    XCTAssertEqual(entitiesDict.count, 6)
  }

  func testGenerateAPI() {
    let rootSchema = Schema(byRootJSON: rootJSON)!
    let links = rootJSON["definitions"].flatMap {
      $0.1["links"].arrayValue
    }.map {
      LinkSchema(json: $0, rootJSON: rootJSON)
    }
    let output = APIGenerator(rootSchema: rootSchema, links: links).generate()
    let expect = testHelper.testSwiftData("API")

    XCTAssertEqual(output, expect)
  }
}
