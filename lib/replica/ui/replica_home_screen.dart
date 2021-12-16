import 'package:flutter/material.dart';
import 'package:lantern/common/common.dart';
import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaHomeScreen is the entrypoint for the user to search through Replica.
/// See docs/replica_home.png for a preview
class ReplicaHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReplicaHomeScreenState();
}

class _ReplicaHomeScreenState extends State<ReplicaHomeScreen> {
  final _textEditingController = TextEditingController();

  Future<void> _navigateToSearchScreen(String query) async {
    await context.pushRoute(ReplicaSearchScreen(searchQuery: query));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Dismiss keyboard when clicking anywhere
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: BaseScreen(
            centerTitle: true,
            title: 'Discover'.i18n,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [renderSearchBar(), renderDescription()],
            )));
  }

  Widget renderDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
      child: CText(
          'Search user-uploaded content on the Lantern Network, or upload your own for others to discover.'
              .i18n,
          style: tsBody1),
    );
  }

  Widget renderSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        controller: _textEditingController,
        textInputAction: TextInputAction.search,
        onFieldSubmitted: (query) async {
          await _navigateToSearchScreen(query);
        },
        decoration: InputDecoration(
          labelText: 'Search',
          suffixIcon: Material(
            color: blue4,
            child: IconButton(
                onPressed: () async {
                  await _navigateToSearchScreen(_textEditingController.text);
                },
                icon: const Icon(Icons.search),
                color: white),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: grey3,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: blue4,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
