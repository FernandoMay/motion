import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motion/home.dart';
import 'package:motion/search.dart';
import 'package:motion/widgets.dart';
import 'package:provider/provider.dart';

const String _homePageLocation = '/reply/home';
const String _searchPageLocation = '/reply/search';

class RouterProvider with ChangeNotifier {
  RouterProvider(ReplyHomePath this._routePath);

  ReplyRoutePath _routePath;
  ReplyRoutePath get routePath => _routePath;

  set routePath(ReplyRoutePath? route) {
    if (route != _routePath) {
      _routePath = route!;
      notifyListeners();
    }
  }
}

class ReplyRouterDelegate extends RouterDelegate<ReplyRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<ReplyRoutePath> {
  ReplyRouterDelegate({required this.replyState})
      : navigatorKey = GlobalObjectKey<NavigatorState>(replyState) {
    replyState.addListener(() {
      notifyListeners();
    });
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  RouterProvider replyState;

  @override
  void dispose() {
    replyState.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  ReplyRoutePath get currentConfiguration => replyState.routePath;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RouterProvider>.value(value: replyState),
      ],
      child: Selector<RouterProvider, ReplyRoutePath?>(
        selector: (context, routerProvider) => routerProvider.routePath,
        builder: (context, routePath, child) {
          return Navigator(
            key: navigatorKey,
            // ignore: deprecated_member_use
            onPopPage: (route, result) {
              assert(route.willHandlePopInternally ||
                  replyState.routePath is ReplySearchPath);
              final didPop = route.didPop(result);
              if (didPop) replyState.routePath = const ReplyHomePath();
              return didPop;
            },
            pages: [
              // TODO: Add Shared Z-Axis transition from search icon to search view page (Motion)
              const CustomTransitionPage(
                transitionKey: ValueKey('Home'),
                screen: HomePage(),
              ),
              if (routePath is ReplySearchPath)
                const CustomTransitionPage(
                  transitionKey: ValueKey('Search'),
                  screen: SearchPage(),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(ReplyRoutePath configuration) {
    replyState.routePath = configuration;
    return SynchronousFuture<void>(null);
  }
}

@immutable
abstract class ReplyRoutePath {
  const ReplyRoutePath();
}

class ReplyHomePath extends ReplyRoutePath {
  const ReplyHomePath();
}

class ReplySearchPath extends ReplyRoutePath {
  const ReplySearchPath();
}

// TODO: Add Shared Z-Axis transition from search icon to search view page (Motion)

class ReplyRouteInformationParser
    extends RouteInformationParser<ReplyRoutePath> {
  @override
  Future<ReplyRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final url = Uri.parse(routeInformation.uri.toString());

    if (url.path == _searchPageLocation) {
      return SynchronousFuture<ReplySearchPath>(const ReplySearchPath());
    }

    return SynchronousFuture<ReplyHomePath>(const ReplyHomePath());
  }

  @override
  RouteInformation? restoreRouteInformation(ReplyRoutePath configuration) {
    if (configuration is ReplyHomePath) {
      return RouteInformation(uri: Uri.parse(_homePageLocation));
    }
    if (configuration is ReplySearchPath) {
      return RouteInformation(uri: Uri.parse(_searchPageLocation));
    }
    return null;
  }
}
