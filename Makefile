# You can install the dart protoc support by running 'dart pub global activate protoc_plugin'

lib/model/protos_shared/vpn.pb.dart: protos_shared/*.proto
	@mkdir -p lib/model && protoc --dart_out=./lib/model --plugin=protoc-gen-dart=$$HOME/.pub-cache/bin/protoc-gen-dart protos_shared/*.proto