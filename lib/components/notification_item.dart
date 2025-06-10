import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../theme/theme.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final Function() onTap;
  final Function()? onMarkAsRead;
  final Function()? onDelete;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.notificationId),
      background: Container(
        color: AppTheme.errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.white 
                : AppTheme.primaryColor.withOpacity(0.05),
            border: const Border(
              bottom: BorderSide(color: AppTheme.dividerColor, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: notification.isRead 
                            ? FontWeight.normal 
                            : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatDateTime(notification.dateTime),
                          style: AppTheme.bodySmallStyle.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        if (!notification.isRead && onMarkAsRead != null) ...[
                          const Spacer(),
                          TextButton(
                            onPressed: onMarkAsRead,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(80, 20),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: AppTheme.primaryColor,
                            ),
                            child: const Text('Mark as read'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}