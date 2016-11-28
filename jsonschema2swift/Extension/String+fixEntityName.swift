//
// Created by hayato.iida on 2016/11/28.
// Copyright (c) 2016 hayato.iida. All rights reserved.
//

import Foundation

func fixEntitySuffix(code: String) -> String {
  return (replaceDataSuffix • replaceParamsSuffix)(code)
}

fileprivate func replaceDataSuffix(code: String) -> String {
  return replaceEntitySuffix(code: code, replace: "Data")
}

fileprivate func replaceParamsSuffix(code: String) -> String {
  return replaceEntitySuffix(code: code, replace: "Params")
}

fileprivate func replaceEntitySuffix(code: String, replace: String) -> String {
  do {
    let rgx = try NSRegularExpression.init(pattern: "\(replace)Entity$")
    let convertedString = rgx.stringByReplacingMatches(in: code, range: NSMakeRange(0, code.characters.count), withTemplate: replace)
    return convertedString
  } catch let error as NSError {
    print(error)
  }
  return code
}


func isEntity(code: String) -> Bool {
  return 0 == getMatchCount(targetString: code, pattern: "_data$")
}

func getMatchCount(targetString: String, pattern: String) -> Int {

  do {

    let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    let targetStringRange = NSRange(location: 0, length: (targetString as NSString).length)

    return regex.numberOfMatches(in: targetString, options: [], range: targetStringRange)

  } catch {
    print("error: getMatchCount")
  }
  return 0
}