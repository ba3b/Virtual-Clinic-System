import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import 'call_screen.dart';

class IncomingCallDialog extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  final String callerName;
  final String callerType;
  final bool isVideoCall;
  final String currentUserType;
  final String currentUserName;

  const IncomingCallDialog({
    Key? key,
    required this.appointmentData,
    required this.callerName,
    required this.callerType,
    required this.isVideoCall,
    required this.currentUserType,
    required this.currentUserName,
  }) : super(key: key);

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
    HapticFeedback.vibrate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _acceptCall() {
    final appointmentId = _getAppointmentId();
    if (appointmentId == null || appointmentId.isEmpty) {
      _showError('Invalid appointment data: Missing appointment ID');
      return;
    }
    final enhancedAppointmentData = _createEnhancedAppointmentData();
    if (!_validateAppointmentData(enhancedAppointmentData)) {
      _showError('Unable to start call: Invalid appointment configuration');
      return;
    }
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          appointmentData: enhancedAppointmentData,
          isAudioOnly: !widget.isVideoCall,
          currentUserType: widget.currentUserType,
          currentUserName: widget.currentUserName,
        ),
      ),
    );
  }

  String? _getAppointmentId() {
    return widget.appointmentData['appointmentId'] as String? ??
        widget.appointmentData['id'] as String?;
  }

  Map<String, dynamic> _createEnhancedAppointmentData() {
    final enhancedData = Map<String, dynamic>.from(widget.appointmentData);
    final appointmentId = _getAppointmentId();
    if (appointmentId != null) {
      enhancedData['appointmentId'] = appointmentId;
    }
    if (widget.currentUserType == 'patient') {
      enhancedData['patientName'] = widget.currentUserName;
      enhancedData['doctorName'] = widget.callerName;
      enhancedData['patientId'] ??= '';
      enhancedData['doctorId'] ??= '';
    } else {
      enhancedData['doctorName'] = widget.currentUserName;
      enhancedData['patientName'] = widget.callerName;
      enhancedData['doctorId'] ??= '';
      enhancedData['patientId'] ??= '';
    }
    final appointmentDate = _getAppointmentDateTime();
    if (appointmentDate != null) {
      enhancedData['appointmentDate'] = appointmentDate;
      enhancedData['dateTime'] = appointmentDate;
    } else {
      final now = DateTime.now();
      enhancedData['appointmentDate'] = now;
      enhancedData['dateTime'] = now;
    }
    enhancedData['appointmentType'] ??= 'virtual';
    enhancedData['status'] ??= 'approved';
    return enhancedData;
  }

  DateTime? _getAppointmentDateTime() {
    var dateTime = widget.appointmentData['appointmentDate'];
    if (dateTime == null) {
      dateTime = widget.appointmentData['dateTime'];
    }
    if (dateTime == null) {
      dateTime = widget.appointmentData['date'];
    }
    if (dateTime is DateTime) {
      return dateTime;
    } else if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        print('Error parsing date string: $e');
      }
    }
    return null;
  }

  bool _validateAppointmentData(Map<String, dynamic> data) {
    final requiredFields = ['appointmentId'];
    for (String field in requiredFields) {
      final value = data[field];
      if (value == null || (value is String && value.isEmpty)) {
        print('Validation failed: Missing or empty field: $field');
        return false;
      }
    }
    final patientName = data['patientName'] as String?;
    final doctorName = data['doctorName'] as String?;
    if (patientName == null || patientName.isEmpty || doctorName == null || doctorName.isEmpty) {
      print('Validation failed: Missing participant names');
      return false;
    }
    final appointmentDate = data['appointmentDate'];
    final dateTime = data['dateTime'];
    if (appointmentDate == null && dateTime == null) {
      print('Validation failed: Missing appointment date/time');
      return false;
    }
    return true;
  }

  void _declineCall() {
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    print('IncomingCallDialog Error: $message');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      widget.callerType == 'doctor'
                          ? Icons.local_hospital
                          : Icons.person,
                      color: AppTheme.primaryColor,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Incoming ${widget.isVideoCall ? 'Video' : 'Audio'} Call',
              style: AppTheme.subheadingStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.callerName,
              style: AppTheme.headingStyle.copyWith(
                fontSize: 24,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.callerType == 'doctor' ? 'Doctor' : 'Patient',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  onTap: _declineCall,
                  color: Colors.red,
                  icon: Icons.call_end,
                  label: 'Decline',
                ),
                _buildActionButton(
                  onTap: _acceptCall,
                  color: Colors.green,
                  icon: widget.isVideoCall ? Icons.videocam : Icons.call,
                  label: 'Accept',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.bodySmallStyle.copyWith(
            color: AppTheme.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}