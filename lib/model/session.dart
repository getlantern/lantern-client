import '../package_store.dart';
import 'model.dart';

class SessionModel extends Model {
  SessionModel() : super("session");

  ValueListenableBuilder<bool> proUser(ValueWidgetBuilder<bool> builder) {
    return subscribedBuilder<bool>("/prouser", builder: builder);
  }

  ValueListenableBuilder<bool> yinbiEnabled(ValueWidgetBuilder<bool> builder) {
    return subscribedBuilder<bool>("/yinbienabled", builder: builder);
  }
}
