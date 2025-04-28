import 'package:flutter/material.dart';
import '../api/notification_service.dart';
import '../theme/theme.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final bool showZero;
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showZero = false,
    this.onTap,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    // Initialize the notification service
    _notificationService.init();
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _notificationService.unreadCountNotifier,
      builder: (context, count, _) {
        if (count == 0 && !widget.showZero) {
          return GestureDetector(
            onTap: widget.onTap,
            child: widget.child,
          );
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              widget.child,
              Positioned(
                top: -5,
                right: -5,
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