# Find all _test.dart files in the integration_test directory and its immediate subdirectories
find integration_test -maxdepth 4 -type f -name '*_test.dart' | while read test_file; do
    flutter test "$test_file" -d macOS
    if [ $? -ne 0 ]; then
        echo "Test $test_file failed."
        continue
    fi
done
