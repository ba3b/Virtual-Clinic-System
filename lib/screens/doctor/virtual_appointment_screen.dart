import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../components/prescription_form.dart';
import '../../models/appointment_model.dart';
import '../../theme/theme.dart';

class DoctorVirtualAppointmentScreen extends StatefulWidget {
  final AppointmentModel appointment;
  final String patientName;

  const DoctorVirtualAppointmentScreen({
    Key? key,
    required this.appointment,
    required this.patientName,
  }) : super(key: key);

  @override
  State<DoctorVirtualAppointmentScreen> createState() => _DoctorVirtualAppointmentScreenState();
}

class _DoctorVirtualAppointmentScreenState extends State<DoctorVirtualAppointmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  bool _isSubmittingPrescription = false;
  bool _showPrescription = false;
  bool _isMeetingActive = false;
  
  // Sample messages for demonstration
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'patient',
      'message': 'Hello doctor, I\'ve been having a headache for two days now.',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'sender': 'doctor',
      'message': 'I see. Have you taken any medication for it?',
      'time': DateTime.now().subtract(const Duration(minutes: 4)),
    },
    {
      'sender': 'patient',
      'message': 'Just some over-the-counter painkillers, but they didn\'t help much.',
      'time': DateTime.now().subtract(const Duration(minutes: 2)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'doctor',
          'message': _messageController.text,
          'time': DateTime.now(),
        });
        _messageController.clear();
      });
    }
  }

  void _startMeeting() {
    setState(() {
      _isMeetingActive = true;
    });
  }

  void _endMeeting() {
    setState(() {
      _isMeetingActive = false;
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Consultation?'),
        content: const Text('Would you like to save the diagnosis and proceed to prescription?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _showPrescription = true;
                _tabController.animateTo(2); // Switch to diagnosis tab
              });
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmitPrescription(String medication, String dosage) async {
    setState(() {
      _isSubmittingPrescription = true;
    });
    
    // Simulate API call to save prescription
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isSubmittingPrescription = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription submitted successfully')),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Virtual Appointment',
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show appointment info
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Appointment Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Patient', widget.patientName),
                      _buildInfoRow('Appointment ID', widget.appointment.appointmentId),
                      _buildInfoRow('Status', widget.appointment.status),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Video Call'),
                Tab(text: 'Messages'),
                Tab(text: 'Diagnosis'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoCallTab(),
                _buildMessagesTab(),
                _buildDiagnosisTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCallTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: _isMeetingActive
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.videocam,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Video call with ${widget.patientName}',
                          style: AppTheme.headingStyle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Call in progress...',
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_off,
                          size: 64,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Video call not started',
                          style: AppTheme.headingStyle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Press the button below to start the meeting',
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCallButton(
                icon: Icons.mic,
                label: 'Mute',
                color: Colors.grey,
              ),
              _buildCallButton(
                icon: _isMeetingActive ? Icons.call_end : Icons.call,
                label: _isMeetingActive ? 'End' : 'Start',
                color: _isMeetingActive ? Colors.red : Colors.green,
                onTap: _isMeetingActive ? _endMeeting : _startMeeting,
              ),
              _buildCallButton(
                icon: Icons.videocam,
                label: 'Camera',
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.bodySmallStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 64,
                        color: AppTheme.textSecondaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start the conversation with your patient',
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    final bool isDoctor = message['sender'] == 'doctor';
                    
                    return Align(
                      alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDoctor
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isDoctor ? const Radius.circular(0) : null,
                            bottomLeft: isDoctor ? null : const Radius.circular(0),
                          ),
                          border: Border.all(
                            color: isDoctor
                                ? AppTheme.primaryColor.withOpacity(0.3)
                                : AppTheme.dividerColor,
                            width: 1,
                          ),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['message'],
                              style: AppTheme.bodyStyle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message['time']),
                              style: AppTheme.bodySmallStyle.copyWith(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTheme.bodySmallStyle.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Diagnosis',
                  style: AppTheme.subheadingStyle,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _diagnosisController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter your diagnosis and notes here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_diagnosisController.text.isNotEmpty) {
                      setState(() {
                        _showPrescription = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Diagnosis saved')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a diagnosis'),
                          backgroundColor: AppTheme.errorColor,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Diagnosis'),
                ),
              ],
            ),
          ),
          if (_showPrescription) ...[
            const SizedBox(height: 24),
            PrescriptionForm(
              onSubmit: _handleSubmitPrescription,
              isLoading: _isSubmittingPrescription,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}