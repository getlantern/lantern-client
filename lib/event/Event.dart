import 'dart:collection';

enum Event {
  All,
  SurveyAvailable,
}

extension EventParsing on Event {
  // map from [event name] to [the event], for example:
  // "All" -> Event.All
  // "SurveyAvailable" -> Event.SurveyAvailable
  static HashMap<String, Event> valuesMap;

  static Event fromValue(String name) {
    // init the static valuesMap for faster parsing
    if (valuesMap == null) {
      valuesMap = HashMap();
      Event.values.forEach((event) {
        valuesMap[event.toShortString()] = event;
      });
    }

    return valuesMap[name];
  }

  String toShortString() {
    // this is because Enum.EnumA.toString() == "Enum.EnumA" instead of just "EnumA"
    return this.toString().split('.').last;
  }
}
