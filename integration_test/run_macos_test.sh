# Find all _test.dart files in the integration_test directory and its immediate subdirectories

all_tests_passed=true

# Find all _test.dart files and iterate over them
find integration_test -maxdepth 4 -type f -name '*_test.dart' | while read test_file; do
    echo "Running test: $test_file"
    flutter test "$test_file" -d macOS -r github
    if [ $? -ne 0 ]; then
        echo "Test $test_file failed."
        all_tests_passed=false
    else
        echo "Test $test_file passed."
    fi
done

# Fail the script if any test failed
if [ "$all_tests_passed" = false ]; then
    echo "One or more tests failed."
    exit 1
else
    echo "All tests passed successfully."
    exit 0
fi
