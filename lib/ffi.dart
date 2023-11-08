import 'dart:ffi' as ffi; // For FFI
import 'package:ffi/ffi.dart';
import 'package:ffi/src/utf8.dart';

typedef start_func = ffi.Pointer<Utf8> Function(); // FFI fn signature
typedef Start = ffi.Pointer<Utf8> Function(); // Dart fn signature
final dylib = ffi.DynamicLibrary.open('lib.a');

final Start start =
    dylib.lookup<ffi.NativeFunction<start_func>>('Start').asFunction();

void testffi() {
  print("Hi from dart");
  var addressOf = start();
  print(addressOf.toDartString());
}