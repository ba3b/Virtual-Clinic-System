import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/notification_service.dart';
import '../models/user_model.dart';
import '../theme/theme.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId?>(context);
    
    if (user == null) {
      return GestureDetector(onTap: onTap, child: child);
    }

    return StreamBuilder<int>(
      stream: NotificationService().getUnreadCountStream(user.uid),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        if (count == 0) {
          return GestureDetector(onTap: onTap, child: child);
        }

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              child,
              PositionedDirectional(
                top: -5,
                end: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}