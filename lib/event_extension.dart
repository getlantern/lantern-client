enum Event {
  All,
  SurveyAvailable,
  NoNetworkAvailable,
  NetworkAvailable,
  NoProxyAvailable,
  ProxyAvailable
}

extension EventParsing on Event {
  // map from [event name] to [the event], for example:
  // 'All' -> Event.All
  // 'SurveyAvailable' -> Event.SurveyAvailable
  static var valuesMap = {
    for (var item in Event.values) item.toShortString(): item
  };

  static Event? fromValue(String name) {
    return valuesMap[name];
  }

  String toShortString() {
    // this is because Enum.EnumA.toString() == 'Enum.EnumA' instead of just 'EnumA'
    return toString().split('.').last;
  }
}
