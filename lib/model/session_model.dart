import '../package_store.dart';
import 'model.dart';

class SessionModel extends Model {
  SessionModel() : super('session');

  Widget proUser(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('prouser', builder: builder);
  }

  Widget yinbiEnabled(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('yinbienabled', builder: builder);
  }
}
