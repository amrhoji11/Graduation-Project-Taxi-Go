import 'package:flutter/material.dart';

import 'package:taxi_go_new/l10n/app_localizations.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
      RouteSettings settings,
      ) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.routeNotFound),
        ),
      ),
    );
  }
}