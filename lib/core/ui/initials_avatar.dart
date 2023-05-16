import 'package:flutter/material.dart';
import 'package:splitcount/core/helper/string_utils.dart';

class InitialsAvatar extends StatefulWidget {
  final String text;
  final int size;

  const InitialsAvatar({required this.text, required this.size, super.key});

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
    _fontSize = widget.size.toDouble() / ((_initials.length == 1) ? 2 : 2.5);
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: widget.size.toDouble(),
        child: Text(_initials, style: TextStyle(fontSize: _fontSize)));
  }
}
