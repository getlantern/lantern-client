import 'package:lantern/package_store.dart';

import 'messages.dart';
import 'vpn.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  void onPageChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  onUpdateCurrentIndexPageView(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: onPageChange,
        controller: _pageController,
        children: [
          MessagesTab(),
          VPNTab(),
          Center(child: Text("Need to build this")),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        updateCurrentIndexPageView: onUpdateCurrentIndexPageView,
      ),
    );
  }
}
