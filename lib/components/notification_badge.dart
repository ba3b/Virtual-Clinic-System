import 'package:flutter/material.dart';
import '../theme/theme.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final bool showZero;

  const NotificationBadge({
    Key? key,
    required this.count,
    required this.child,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0 && !showZero) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -5,
          right: -5,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppTheme.errorColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              count > 9 ? '9+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}