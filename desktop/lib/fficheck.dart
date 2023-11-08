import 'dart:ffi' as ffi; // For FFI
import 'package:ffi/ffi.dart';
import 'package:ffi/src/utf8.dart';

typedef print_hello_func = ffi.Pointer<Utf8> Function(); // FFI fn signature
typedef PrintHello = ffi.Pointer<Utf8> Function(); // Dart fn signature
final dylib = ffi.DynamicLibrary.open('lib.a');

final PrintHello printHello =
    dylib.lookup<ffi.NativeFunction<print_hello_func>>('PrintHello').asFunction();

void testffi() {
  print("Hi from dart");
  var addressOf = printHello();
  print(addressOf.toDartString());
}