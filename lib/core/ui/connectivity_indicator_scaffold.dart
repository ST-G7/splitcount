import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectivityIndiactorScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;

  const ConnectivityIndiactorScaffold(
      {super.key, this.appBar, this.body, this.floatingActionButton});

  @override
  State<ConnectivityIndiactorScaffold> createState() =>
      _ConnectivityIndiactorScaffoldState();
}

class _ConnectivityIndiactorScaffoldState
    extends State<ConnectivityIndiactorScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.key,
      appBar: widget.appBar,
      floatingActionButton: widget.floatingActionButton,
      body: OfflineBuilder(
        child: widget.body,
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;

          List<Widget> widgets = [];

          if (widget.body != null) {
            widgets.add(widget.body!);
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
