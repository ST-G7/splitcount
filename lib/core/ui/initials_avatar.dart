import 'package:flutter/material.dart';
import 'package:splitcount/core/helper/string_utils.dart';

class InitialsAvatar extends StatefulWidget {
  final String text;
  final int radius;

  const InitialsAvatar({required this.text, required this.radius, super.key});

  @override
  State<InitialsAvatar> createState() => _InitialsAvatarState();
}

class _InitialsAvatarState extends State<InitialsAvatar> {
  late String _initials;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _initials = widget.text.computeInitials();
    _fontSize = widget.radius.toDouble();

    if (_initials.length == 2) {
      _fontSize = _fontSize / 1.25;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: widget.radius.toDouble(),
        child: Text(_initials,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _fontSize,
            )));
  }
}
