import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectivityIndiactorScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;

  const ConnectivityIndiactorScaffold(
      {super.key, this.appBar, this.body, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: super.key,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: OfflineBuilder(
        child: body,
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;

          List<Widget> widgets = [];

          if (body != null) {
            widgets.add(body!);
          }

          if (!connected) {
            final offlineIndicator = Positioned(
              left: 0.0,
              right: 0.0,
              child: Container(
                color: const Color(0xFFEE4400),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Center(
                    child: Text(
                      maxLines: 2,
                      softWrap: false,
                      AppLocalizations.of(context)!.noConnectionWarning,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
            widgets.add(offlineIndicator);
          }

          return Stack(fit: StackFit.expand, children: widgets);
        },
      ),
    );
  }
}
