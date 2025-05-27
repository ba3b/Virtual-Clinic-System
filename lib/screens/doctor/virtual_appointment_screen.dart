import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/firestore_service.dart';
import '../../components/custom_app_bar.dart';
import '../../models/appointment_model.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';
import '../call_screen.dart';

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

class _DoctorVirtualAppointmentScreenState extends State<DoctorVirtualAppointmentScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _isSendingMessage = false;
  String? _currentUserId;
  String? _currentUserType = 'doctor';
  String? _currentUserName;
  String? _error;
  UserModel? _currentUser;
  UserModel? _patientUser;
  Timer? _sessionTimer;
  bool _sessionExpired = false;
  
  @override
  void initState() {
    super.initState();
    _initializeChat();
    _startSessionMonitoring();
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user info from Provider
      final user = Provider.of<UserId?>(context, listen: false);
      if (user == null) {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      _currentUserId = user.uid;

      // Get current user details (doctor)
      _currentUser = await DatabaseService(uid: user.uid).getUserDetails(user.uid);
      _currentUserType = _currentUser!.userType;
      _currentUserName = _currentUser!.name;

      // Verify this is a doctor
      if (_currentUserType != 'doctor') {
        setState(() {
          _error = 'Only doctors can access this screen';
          _isLoading = false;
        });
        return;
      }

      // Get patient details
      try {
        _patientUser = await DatabaseService(uid: widget.appointment.patientId)
            .getUserDetails(widget.appointment.patientId);
      } catch (e) {
        print('Error loading patient details: $e');
        // Continue without patient details, use the name from props
      }

      // Mark messages as read when opening the chat
      await _markMessagesAsRead();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() {
        _error = 'Error loading chat: $e';
        _isLoading = false;
      });
    }
  }

  void _startSessionMonitoring() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && !_sessionExpired) {
        final now = DateTime.now();
        final sessionEndTime = widget.appointment.dateTime.add(const Duration(minutes: 20));
        
        if (now.isAfter(sessionEndTime)) {
          _handleSessionExpired();
        }
      }
    });
  }

  void _handleSessionExpired() {
    if (_sessionExpired) return;
    
    setState(() {
      _sessionExpired = true;
    });
    
    _sessionTimer?.cancel();
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.access_time, color: Colors.orange),
              SizedBox(width: 8),
              Text('Session Expired'),
            ],
          ),
          content: const Text(
            'The virtual appointment session has ended. You will be redirected back to the appointment details.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to appointment details
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (_currentUserId != null) {
      try {
        await DatabaseService(uid: _currentUserId!)
            .markAppointmentMessagesAsRead(
                widget.appointment.appointmentId, _currentUserId!);
      } catch (e) {
        print('Error marking messages as read: $e');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_sessionExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session has expired. Cannot send messages.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_messageController.text.trim().isEmpty || _isSendingMessage || _currentUser == null) return;

    final messageContent = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final message = MessageModel(
        messageId: '', // Will be generated by Firestore
        appointmentId: widget.appointment.appointmentId,
        senderId: _currentUserId!,
        senderName: 'Dr. $_currentUserName',
        senderType: _currentUserType!,
        content: messageContent,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await DatabaseService(uid: _currentUserId!).sendMessage(message);

      // Scroll to bottom after sending
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Restore the message text
        _messageController.text = messageContent;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startVideoCall() {
    if (_sessionExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session has expired. Cannot start video call.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Create properly structured appointment data
    final appointmentData = _createAppointmentDataForCall();
    
    // Validate data before starting call
    if (!_validateCallData(appointmentData)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to start call: Invalid appointment configuration'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          appointmentData: appointmentData,
          isAudioOnly: false,
          currentUserType: 'doctor',
          currentUserName: _currentUserName ?? 'Doctor',
        ),
      ),
    );
  }

  void _startAudioCall() {
    if (_sessionExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session has expired. Cannot start audio call.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Create properly structured appointment data
    final appointmentData = _createAppointmentDataForCall();
    
    // Validate data before starting call
    if (!_validateCallData(appointmentData)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to start call: Invalid appointment configuration'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          appointmentData: appointmentData,
          isAudioOnly: true,
          currentUserType: 'doctor',
          currentUserName: _currentUserName ?? 'Doctor',
        ),
      ),
    );
  }

  Map<String, dynamic> _createAppointmentDataForCall() {
    return {
      'appointmentId': widget.appointment.appointmentId,
      'patientId': widget.appointment.patientId,
      'doctorId': widget.appointment.doctorId ?? _currentUserId ?? '',
      'patientName': widget.patientName,
      'doctorName': 'Dr. ${_currentUserName ?? 'Doctor'}',
      'dateTime': widget.appointment.dateTime,
      'appointmentDate': widget.appointment.dateTime,
      'appointmentType': widget.appointment.type,
      'status': widget.appointment.status,
      'department': widget.appointment.department,
    };
  }

  bool _validateCallData(Map<String, dynamic> data) {
    // Check required fields
    final appointmentId = data['appointmentId'] as String?;
    final patientName = data['patientName'] as String?;
    final doctorName = data['doctorName'] as String?;
    
    if (appointmentId == null || appointmentId.isEmpty) {
      print('Validation failed: Missing appointment ID');
      return false;
    }
    
    if (patientName == null || patientName.isEmpty) {
      print('Validation failed: Missing patient name');
      return false;
    }
    
    if (doctorName == null || doctorName.isEmpty) {
      print('Validation failed: Missing doctor name');
      return false;
    }
    
    return true;
  }

  void _showPatientInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Patient Information'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', widget.patientName),
            _buildInfoRow('Patient ID', widget.appointment.patientId),
            _buildInfoRow('Appointment Type', widget.appointment.type),
            if (widget.appointment.department != null)
              _buildInfoRow('Department', widget.appointment.department!),
            _buildInfoRow('Status', widget.appointment.status),
            if (_patientUser != null) ...[
              _buildInfoRow('Phone', _patientUser!.phoneNumber),
              _buildInfoRow('Email', _patientUser!.email),
            ],
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
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTheme.bodySmallStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: const CustomAppBar(
          title: 'Virtual Consultation',
          backgroundColor: AppTheme.primaryColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: const CustomAppBar(
          title: 'Virtual Consultation',
          backgroundColor: AppTheme.primaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyStyle.copyWith(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  _initializeChat();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Virtual Consultation',
        backgroundColor: AppTheme.primaryColor,
        actions: [
          // Patient Info Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _showPatientInfo,
              icon: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 22,
              ),
              tooltip: 'Patient Information',
            ),
          ),
          // Audio Call Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _sessionExpired 
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _sessionExpired ? null : _startAudioCall,
              icon: Icon(
                Icons.phone,
                color: _sessionExpired ? Colors.grey : Colors.white,
                size: 22,
              ),
              tooltip: _sessionExpired ? 'Session expired' : 'Start Audio Call',
            ),
          ),
          // Video Call Button
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _sessionExpired 
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _sessionExpired ? null : _startVideoCall,
              icon: Icon(
                Icons.videocam,
                color: _sessionExpired ? Colors.grey : Colors.white,
                size: 22,
              ),
              tooltip: _sessionExpired ? 'Session expired' : 'Start Video Call',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Appointment Info Header
          _buildAppointmentHeader(),
          
          // Messages List
          Expanded(
            child: _buildMessagesList(),
          ),
          
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildAppointmentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sessionExpired ? Colors.grey[100] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patientName,
                  style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _sessionExpired ? Colors.red : Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sessionExpired ? 'Session Ended' : 'Online',
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: _sessionExpired ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.appointment.type.toUpperCase(),
                  style: AppTheme.bodySmallStyle.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _sessionExpired 
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _sessionExpired ? 'EXPIRED' : 'ACTIVE',
                  style: AppTheme.bodySmallStyle.copyWith(
                    color: _sessionExpired ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<List<MessageModel>>(
      stream: DatabaseService(uid: _currentUserId!)
          .getAppointmentMessages(widget.appointment.appointmentId),
      builder: (context, snapshot) {
        // Only show loading indicator on initial load, not on updates
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading messages: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyStyle.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _sessionExpired 
                      ? 'Session has ended'
                      : 'Start consultation with ${widget.patientName}',
                  style: AppTheme.subheadingStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _sessionExpired 
                      ? 'This consultation session has expired'
                      : 'Send a message or start a video call',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // Mark messages as read when they're loaded
        if (!_sessionExpired) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _markMessagesAsRead();
            _scrollToBottom();
          });
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isCurrentUser = message.senderId == _currentUserId;
            final showTimestamp = index == 0 ||
                messages[index - 1].timestamp.difference(message.timestamp).inMinutes.abs() > 5;

            return Column(
              children: [
                if (showTimestamp) _buildTimestamp(message.timestamp),
                _buildMessageBubble(message, isCurrentUser),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTimestamp(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        _formatTimestamp(timestamp),
        style: AppTheme.bodySmallStyle.copyWith(
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.blue,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentUser ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser && message.senderName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName,
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: AppTheme.bodyStyle.copyWith(
                      color: isCurrentUser ? Colors.white : AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: isCurrentUser 
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          color: Colors.white.withOpacity(0.8),
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sessionExpired ? Colors.grey[300] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _sessionExpired ? Colors.grey[200] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: !_sessionExpired,
                  decoration: InputDecoration(
                    hintText: _sessionExpired 
                        ? 'Session expired' 
                        : 'Type your message to ${widget.patientName}...',
                    hintStyle: AppTheme.bodyStyle.copyWith(
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: _sessionExpired
                    ? Colors.grey
                    : (_isSendingMessage 
                        ? AppTheme.primaryColor.withOpacity(0.6)
                        : AppTheme.primaryColor),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sessionExpired || _isSendingMessage ? null : _sendMessage,
                icon: _isSendingMessage
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}