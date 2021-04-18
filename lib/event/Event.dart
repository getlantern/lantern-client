enum Event {
  All,
  SurveyAvailable,
}

extension EventParsing on Event {
  // map from [event name] to [the event], for example:
  // "All" -> Event.All
  // "SurveyAvailable" -> Event.SurveyAvailable
  static var valuesMap = Map<String, Event>.fromIterable(
      Event.values.map((e) => MapEntry(e.toShortString(), e)));

  static Event? fromValue(String name) {
    return valuesMap[name];
  }

  String toShortString() {
    // this is because Enum.EnumA.toString() == "Enum.EnumA" instead of just "EnumA"
    return toString().split('.').last;
  }
}
