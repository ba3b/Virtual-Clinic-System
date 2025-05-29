import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';

class DatePickerComponent extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateSelected;

  const DatePickerComponent({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<DatePickerComponent> createState() => _DatePickerComponentState();
}

class _DatePickerComponentState extends State<DatePickerComponent> {
  late DateTime _selectedDate;
  late PageController _pageController;
  late int _currentMonthPage;

  final Map<int, String> _weekdayNames = {
    7: 'Sun',
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;

    _currentMonthPage = (widget.initialDate.year - widget.firstDate.year) * 12 +
        widget.initialDate.month -
        widget.firstDate.month;

    _pageController = PageController(initialPage: _currentMonthPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isSelectedDate(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isInRange(DateTime date) {
    if (date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate)) {
      return false;
    }

    if (date.weekday == 5 || date.weekday == 6) {
      return false;
    }

    return true;
  }

  void _selectDate(DateTime date) {
    if (_isInRange(date)) {
      setState(() {
        _selectedDate = date;
      });
      widget.onDateSelected(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthNavigation(),
        const SizedBox(height: 16),
        _buildWeekdayHeader(),
        const SizedBox(height: 8),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentMonthPage = page;
              });
            },
            itemBuilder: (context, index) {
              final DateTime firstDateOfMonth = DateTime(
                widget.firstDate.year +
                    (widget.firstDate.month + index - 1) ~/ 12,
                (widget.firstDate.month + index - 1) % 12 + 1,
                1,
              );

              return _buildMonthCalendar(firstDateOfMonth);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    final DateTime currentMonth = DateTime(
      widget.firstDate.year +
          (widget.firstDate.month + _currentMonthPage - 1) ~/ 12,
      (widget.firstDate.month + _currentMonthPage - 1) % 12 + 1,
      1,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentMonthPage > 0
              ? () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              : null,
        ),
        Text(
          DateFormat('MMMM yyyy').format(currentMonth),
          style: AppTheme.subheadingStyle,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            'Sun',
            style: AppTheme.bodySmallStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        ...List.generate(4, (index) {
          final int weekday =
              index + 1; 
          return SizedBox(
            width: 40,
            child: Text(
              _weekdayNames[weekday]!,
              style: AppTheme.bodySmallStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }),
        const SizedBox(width: 40),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildMonthCalendar(DateTime firstDayOfMonth) {
    final int firstWeekday = firstDayOfMonth.weekday;
    final int daysToSubtract = firstWeekday == 7
        ? 0
        : firstWeekday; 
    final DateTime firstDisplayedDate =
        firstDayOfMonth.subtract(Duration(days: daysToSubtract));

    final DateTime lastDayOfMonth = DateTime(
      firstDayOfMonth.year,
      firstDayOfMonth.month + 1,
      0,
    );

    final int daysToShow =
        (lastDayOfMonth.difference(firstDisplayedDate).inDays + 1);
    final int weeksToShow = (daysToShow / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: weeksToShow * 7,
      itemBuilder: (context, index) {
        final DateTime date = firstDisplayedDate.add(Duration(days: index));
        final bool isCurrentMonth = date.month == firstDayOfMonth.month;

        return _buildDateCell(date, isCurrentMonth);
      },
    );
  }

  Widget _buildDateCell(DateTime date, bool isCurrentMonth) {
    final bool isSelected = _isSelectedDate(date);
    final bool isToday = _isToday(date);
    final bool isInRange = _isInRange(date);

    return GestureDetector(
      onTap: isCurrentMonth && isInRange ? () => _selectDate(date) : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : isToday
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: isToday && !isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: AppTheme.bodyStyle.copyWith(
              color: isSelected
                  ? Colors.white
                  : !isCurrentMonth || !isInRange
                      ? AppTheme.textSecondaryColor.withOpacity(0.3)
                      : isToday
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimaryColor,
              fontWeight: isSelected || isToday ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }
}
