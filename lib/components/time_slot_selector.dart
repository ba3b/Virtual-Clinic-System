import 'package:flutter/material.dart';
import '../theme/theme.dart';

class TimeSlot {
  final String id;
  final String time;
  final bool isAvailable;

  TimeSlot({
    required this.id,
    required this.time,
    required this.isAvailable,
  });
}

class TimeSlotSelector extends StatefulWidget {
  final List<TimeSlot> timeSlots;
  final Function(TimeSlot) onTimeSelected;
  final String? selectedTimeId;

  const TimeSlotSelector({
    Key? key,
    required this.timeSlots,
    required this.onTimeSelected,
    this.selectedTimeId,
  }) : super(key: key);

  @override
  State<TimeSlotSelector> createState() => _TimeSlotSelectorState();
}

class _TimeSlotSelectorState extends State<TimeSlotSelector> {
  String? _selectedTimeId;

  @override
  void initState() {
    super.initState();
    _selectedTimeId = widget.selectedTimeId;
  }

  @override
  void didUpdateWidget(TimeSlotSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTimeId != oldWidget.selectedTimeId) {
      _selectedTimeId = widget.selectedTimeId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = widget.timeSlots[index];
        final bool isSelected = timeSlot.id == _selectedTimeId;
        
        return InkWell(
          onTap: timeSlot.isAvailable
              ? () {
                  setState(() {
                    _selectedTimeId = timeSlot.id;
                  });
                  widget.onTimeSelected(timeSlot);
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : timeSlot.isAvailable
                      ? AppTheme.surfaceColor
                      : AppTheme.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : timeSlot.isAvailable
                        ? AppTheme.dividerColor
                        : Colors.transparent,
              ),
            ),
            child: Center(
              child: Text(
                timeSlot.time,
                style: AppTheme.bodyStyle.copyWith(
                  color: isSelected
                      ? Colors.white
                      : timeSlot.isAvailable
                          ? AppTheme.textPrimaryColor
                          : AppTheme.textSecondaryColor.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}