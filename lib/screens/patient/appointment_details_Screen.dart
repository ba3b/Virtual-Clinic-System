import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'virtual_appointment_screen.dart';
import '../../api/firestore_service.dart';
import '../../components/custom_app_bar.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';
import '../../localization/app_localizations.dart';
import 'dart:async';

class AppointmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;

  const AppointmentDetailsScreen({
    Key? key,
    required this.appointmentData,
  }) : super(key: key);

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _doctorDetails;
  bool _isLoadingData = true;
  Timer? _timeCheckTimer;

  @override
  void initState() {
    super.initState();
    _loadAdditionalData();
    _startTimeMonitoring();
  }

  @override
  void dispose() {
    _timeCheckTimer?.cancel();
    super.dispose();
  }

  void _startTimeMonitoring() {
    _timeCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
        });
      }
    });
  }

  Future<void> _loadAdditionalData() async {
    try {
      setState(() {
        _isLoadingData = true;
      });

      final doctorId = widget.appointmentData['doctorId'] as String?;

      if (doctorId != null) {
        _doctorDetails =
            await DatabaseService(uid: doctorId).getUserDetails(doctorId);
      }

      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('Error loading additional data: $e');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _cancelAppointment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = Provider.of<UserId?>(context, listen: false);
      if (user == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final appointmentId = widget.appointmentData['appointmentId'] as String;

      await DatabaseService(uid: user.uid).cancelAppointment(appointmentId);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('appointment_cancelled_success')),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = '${AppLocalizations.of(context).translate('error_cancelling_appointment')}: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(BuildContext context) {
    final date = widget.appointmentData['appointmentDate'] as DateTime? ??
        widget.appointmentData['dateTime'] as DateTime?;
    
    if (date != null) {
      final locale = Localizations.localeOf(context).languageCode;
      return '${DateFormat.yMMMMEEEEd(locale).format(date)} - ${DateFormat.jm(locale).format(date)}';
    }
    return AppLocalizations.of(context).translate('date_not_available');
  }

  String _getAppointmentTitle(BuildContext context) {
    final type = widget.appointmentData['appointmentType'] as String;

    if (type == 'vaccination') {
      return AppLocalizations.of(context).translate('vaccination_appointment');
    } else if (type == 'virtual') {
      return AppLocalizations.of(context).translate('virtual_consultation');
    } else {
      return AppLocalizations.of(context).translate('physical_consultation');
    }
  }

  Widget _buildStatusChip(BuildContext context) {
    final status = widget.appointmentData['status'] as String;

    late final Color color;
    late final IconData icon;
    late final String displayText;

    switch (status) {
      case AppointmentModel.statusPending:
        color = Colors.amber;
        icon = Icons.pending_outlined;
        displayText = AppLocalizations.of(context).translate('pending_review');
        break;
      case AppointmentModel.statusApproved:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        displayText = AppLocalizations.of(context).translate('approved');
        break;
      case AppointmentModel.statusRejected:
        color = Colors.red;
        icon = Icons.cancel_outlined;
        displayText = AppLocalizations.of(context).translate('rejected');
        break;
      case AppointmentModel.statusCompleted:
        color = Colors.green;
        icon = Icons.task_alt;
        displayText = AppLocalizations.of(context).translate('completed');
        break;
      case AppointmentModel.statusCancelled:
        color = Colors.grey;
        icon = Icons.cancel_outlined;
        displayText = AppLocalizations.of(context).translate('cancelled');
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            displayText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  bool _canCancelAppointment() {
    final status = widget.appointmentData['status'] as String;
    final appointmentDate = widget.appointmentData['appointmentDate'] as DateTime? ??
        widget.appointmentData['dateTime'] as DateTime?;

    if (appointmentDate == null) return false;

    return status == AppointmentModel.statusPending &&
        appointmentDate.difference(DateTime.now()).inHours > 24;
  }

  bool _canJoinVirtualAppointment() {
    final status = widget.appointmentData['status'] as String;
    final type = widget.appointmentData['appointmentType'] as String;
    final appointmentDate = widget.appointmentData['appointmentDate'] as DateTime? ??
        widget.appointmentData['dateTime'] as DateTime?;
    
    if (appointmentDate == null) return false;
    
    final now = DateTime.now();

    if (status != AppointmentModel.statusApproved ||
        type != AppointmentModel.typeVirtual) {
      return false;
    }

    final startWindow = appointmentDate.subtract(const Duration(minutes: 1));
    final endWindow = appointmentDate.add(const Duration(minutes: 20));

    return now.isAfter(startWindow) && now.isBefore(endWindow);
  }

  Color _getAppointmentColor() {
    final type = widget.appointmentData['appointmentType'] as String;
    switch (type) {
      case 'virtual':
        return AppTheme.primaryColor;
      case 'physical':
        return Colors.blue;
      case 'vaccination':
        return Colors.green;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getAppointmentIcon() {
    final type = widget.appointmentData['appointmentType'] as String;
    switch (type) {
      case 'virtual':
        return Icons.videocam_rounded;
      case 'physical':
        return Icons.person_rounded;
      case 'vaccination':
        return Icons.vaccines_rounded;
      default:
        return Icons.calendar_today;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentType = widget.appointmentData['appointmentType'] as String;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('appointment_details'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            _getAppointmentColor(),
                            _getAppointmentColor().withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getAppointmentIcon(),
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getAppointmentTitle(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDateTime(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _buildStatusChip(context),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('appointment_info'),
                            style:
                                AppTheme.subheadingStyle.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          if (appointmentType != 'vaccination') ...[
                            _buildInfoRow(
                              Icons.local_hospital_outlined,
                              AppLocalizations.of(context).translate('department'),
                              widget.appointmentData['department'] as String? ??
                                  AppLocalizations.of(context).translate('general'),
                            ),
                            _buildInfoRow(
                              Icons.person_outline,
                              AppLocalizations.of(context).translate('doctor'),
                              _doctorDetails?.name != null
                                  ? '${AppLocalizations.of(context).translate('dr_prefix')} ${_doctorDetails!.name}'
                                  : widget.appointmentData['doctorName']
                                          as String? ??
                                      AppLocalizations.of(context).translate('not_assigned_yet'),
                            ),
                          ],
                          if (appointmentType == 'vaccination')
                            _buildInfoRow(
                              Icons.vaccines_outlined,
                              AppLocalizations.of(context).translate('vaccination_type'),
                              widget.appointmentData['vaccinationType']
                                      as String? ??
                                  AppLocalizations.of(context).translate('standard_vaccination'),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_canJoinVirtualAppointment())
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.green.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VirtualAppointmentScreen(
                                    appointmentData: widget.appointmentData,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.videocam_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.of(context).translate('join_virtual_appointment'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (_canJoinVirtualAppointment()) const SizedBox(height: 20),

                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (_canCancelAppointment())
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _cancelAppointment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                AppLocalizations.of(context).translate('cancel_appointment'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getAppointmentColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: _getAppointmentColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmallStyle.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}