/// Returns a function that its operand but only runs once.
T Function(T Function()) once<T>() {
  var didIt = false;
  late T result;

  return (Function() fn) {
    if (!didIt) {
      didIt = true;
      result = fn();
    }
    return result;
  };
}
