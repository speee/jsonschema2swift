# jsonschema2swift

json schema to generate swift code

## インストール

```.sh
$ git clone <本リポジトリ>
$ cd jsonschema2swift
$ git submodule init
$ git submodule update
$ xcodebuild -project jsonschema2swift.xcodeproj
```

## 実行方法
```.sh
$ ./bin/jsonschema2swift {json schema} {output directory}
```

### example
 
```.sh
$ ./bin/jsonschema2swift test1.json ./output
```


## 出力ファイル
[example](./jsonschema2swiftTest/TestData.bundle/SampleAPITest)

- Enttiy/*.swift
- Api.swift
