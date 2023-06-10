import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Function? onTap;
  final double size;

  const CircularIconButton(this.icon,
      {super.key, this.active = false, this.onTap, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Material(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          shape: const CircleBorder(),
          child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap != null ? () => onTap!() : null,
              child: Ink(
                  height: size,
                  width: size,
                  child: Icon(
                    icon,
                    size: size * 0.58,
                    weight: 100,
                    grade: 0,
                    color: active
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSecondary,
                  )))),
    );
  }
}
