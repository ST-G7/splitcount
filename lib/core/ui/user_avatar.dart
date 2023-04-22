import 'package:flutter/material.dart';
import 'package:splitcount/core/helper/string_utils.dart';

class UserAvatar extends StatefulWidget {
  final String userName;
  final int size;

  const UserAvatar(this.userName, this.size, {super.key});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  late String _initials;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _initials = widget.userName.computeInitials();
    _fontSize = widget.size.toDouble() / ((_initials.length == 1) ? 2 : 2.5);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.toDouble(),
      height: widget.size.toDouble(),
      child: CircleAvatar(
        child: Text(_initials, style: TextStyle(fontSize: _fontSize)),
      ),
    );
  }
}
