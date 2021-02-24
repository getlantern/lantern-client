lib/model/protos/*: protos/*.proto
	protoc --dart_out=./lib/model --plugin=protoc-gen-dart=$$HOME/.pub-cache/bin/protoc-gen-dart ./protos/*.proto