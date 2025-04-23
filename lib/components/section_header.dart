import 'package:flutter/material.dart';
import '../theme/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextAlign titleAlign;
  final TextAlign subtitleAlign;
  final VoidCallback? onActionTap;
  final String? actionText;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.titleAlign = TextAlign.left,
    this.subtitleAlign = TextAlign.left,
    this.onActionTap,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTheme.headingStyle,
                textAlign: titleAlign,
              ),
            ),
            if (onActionTap != null && actionText != null)
              TextButton(
                onPressed: onActionTap,
                child: Text(
                  actionText!,
                  style: AppTheme.bodySmallStyle.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTheme.bodySmallStyle,
            textAlign: subtitleAlign,
          ),
        ],
      ],
    );
  }
}