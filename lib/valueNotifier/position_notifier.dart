import 'package:lantern/package_store.dart';

class PositionNotifier extends ChangeNotifier {
  int _currentPage = 0;

  int get page => _currentPage;

  void changePage(int position) => _currentPage = position;
}
