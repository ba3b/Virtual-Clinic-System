import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/screens/call_screen.dart';
import '../../api/firestore_service.dart';
import '../../components/custom_app_bar.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';
import '../call_state_mixin.dart';

class VirtualAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;

  const VirtualAppointmentScreen({
    Key? key,
    required this.appointmentData,
  }) : super(key: key);

  @override
  State<VirtualAppointmentScreen> createState() =>
      _VirtualAppointmentScreenState();
}

class _VirtualAppointmentScreenState extends State<VirtualAppointmentScreen>
    with CallStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isSendingMessage = false;
  String? _currentUserId;
  String? _currentUserType;
  String? _currentUserName;
  String? _otherParticipantName;
  String? _error;
  UserModel? _currentUser;
  UserModel? _doctorUser;
  Timer? _sessionTimer;
  bool _sessionExpired = false;

  @override
  void initState() {
    super.initState();
    _validateAppointmentData();
    _initializeChat();
    _startSessionMonitoring();
  }

  void _validateAppointmentData() {
    final appointmentId = widget.appointmentData['appointmentId'] as String?;
    if (appointmentId == null || appointmentId.isEmpty) {
      setState(() {
        _error = 'Invalid appointment data: Missing appointment ID';
      });
      return;
    }

    if (!widget.appointmentData.containsKey('patientId')) {
      widget.appointmentData['patientId'] = '';
    }
    if (!widget.appointmentData.containsKey('doctorId')) {
      widget.appointmentData['doctorId'] = '';
    }
    if (!widget.appointmentData.containsKey('patientName')) {
      widget.appointmentData['patientName'] = 'Patient';
    }
    if (!widget.appointmentData.containsKey('doctorName')) {
      widget.appointmentData['doctorName'] = 'Doctor';
    }
  }

  Future<void> _initializeChat() async {
    if (_error != null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<UserId?>(context, listen: false);
      if (user == null) {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      _currentUserId = user.uid;

      _currentUser =
          await DatabaseService(uid: user.uid).getUserDetails(user.uid);
      _currentUserType = _currentUser!.userType;
      _currentUserName = _currentUser!.name;

      widget.appointmentData['patientId'] = _currentUserId;
      widget.appointmentData['patientName'] = _currentUserName;

      final doctorId = widget.appointmentData['doctorId'] as String?;
      if (doctorId != null && doctorId.isNotEmpty) {
        try {
          _doctorUser =
              await DatabaseService(uid: doctorId).getUserDetails(doctorId);
          _otherParticipantName = 'Dr. ${_doctorUser!.name}';
          widget.appointmentData['doctorName'] = _otherParticipantName;
        } catch (e) {
          print('Error loading doctor details: $e');
          _otherParticipantName =
              widget.appointmentData['doctorName'] as String? ?? 'Doctor';
        }
      } else {
        _otherParticipantName =
            widget.appointmentData['doctorName'] as String? ?? 'Doctor';
      }

      final appointmentId = widget.appointmentData['appointmentId'] as String;
      if (appointmentId.isNotEmpty && _currentUserId!.isNotEmpty) {
        initializeCallStateListener(
          appointmentId: appointmentId,
          currentUserId: _currentUserId!,
          currentUserType: _currentUserType!,
          currentUserName: _currentUserName!,
          appointmentData: widget.appointmentData,
        );
      }

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
        final appointmentDate = _getAppointmentDateTime();

        if (appointmentDate != null) {
          final now = DateTime.now();
          final sessionEndTime =
              appointmentDate.add(const Duration(minutes: 20));

          if (now.isAfter(sessionEndTime)) {
            _handleSessionExpired();
          }
        }
      }
    });
  }

  DateTime? _getAppointmentDateTime() {
    var dateTime = widget.appointmentData['appointmentDate'];
    if (dateTime == null) {
      dateTime = widget.appointmentData['dateTime'];
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
            'Your virtual appointment session has ended. You will be redirected back to the appointment details.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
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
        final appointmentId =
            widget.appointmentData['appointmentId'] as String?;
        if (appointmentId != null) {
          await DatabaseService(uid: _currentUserId!)
              .markAppointmentMessagesAsRead(appointmentId, _currentUserId!);
        }
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
    disposeCallStateListener();
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

    if (_messageController.text.trim().isEmpty ||
        _isSendingMessage ||
        _currentUser == null) return;

    final messageContent = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final appointmentId = widget.appointmentData['appointmentId'] as String;

      final message = MessageModel(
        messageId: '',
        appointmentId: appointmentId,
        senderId: _currentUserId!,
        senderName: _currentUserName!,
        senderType: _currentUserType!,
        content: messageContent,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await DatabaseService(uid: _currentUserId!).sendMessage(message);

      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

    final appointmentId = widget.appointmentData['appointmentId'] as String?;
    if (appointmentId == null || appointmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to start call: Invalid appointment data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    markCurrentUserAsCaller();

    final enhancedAppointmentData =
        Map<String, dynamic>.from(widget.appointmentData);
    enhancedAppointmentData['appointmentId'] = appointmentId;
    enhancedAppointmentData['patientId'] = _currentUserId ?? '';
    enhancedAppointmentData['patientName'] = _currentUserName ?? 'Patient';
    enhancedAppointmentData['doctorName'] = _otherParticipantName ?? 'Doctor';

    final appointmentDateTime = _getAppointmentDateTime();
    if (appointmentDateTime != null) {
      enhancedAppointmentData['appointmentDate'] = appointmentDateTime;
      enhancedAppointmentData['dateTime'] = appointmentDateTime;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          appointmentData: enhancedAppointmentData,
          isAudioOnly: false,
          currentUserType: _currentUserType ?? 'patient',
          currentUserName: _currentUserName ?? 'Patient',
        ),
      ),
    ).then((_) {
      resetCallingState();
    });
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

    final appointmentId = widget.appointmentData['appointmentId'] as String?;
    if (appointmentId == null || appointmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to start call: Invalid appointment data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    markCurrentUserAsCaller();

    final enhancedAppointmentData =
        Map<String, dynamic>.from(widget.appointmentData);
    enhancedAppointmentData['appointmentId'] = appointmentId;
    enhancedAppointmentData['patientId'] = _currentUserId ?? '';
    enhancedAppointmentData['patientName'] = _currentUserName ?? 'Patient';
    enhancedAppointmentData['doctorName'] = _otherParticipantName ?? 'Doctor';

    final appointmentDateTime = _getAppointmentDateTime();
    if (appointmentDateTime != null) {
      enhancedAppointmentData['appointmentDate'] = appointmentDateTime;
      enhancedAppointmentData['dateTime'] = appointmentDateTime;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          appointmentData: enhancedAppointmentData,
          isAudioOnly: true,
          currentUserType: _currentUserType ?? 'patient',
          currentUserName: _currentUserName ?? 'Patient',
        ),
      ),
    ).then((_) {
      resetCallingState();
    });
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
                  _validateAppointmentData();
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
          _buildAppointmentHeader(),

          Expanded(
            child: _buildMessagesList(),
          ),

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
            child: Icon(
              _currentUserType == 'patient'
                  ? Icons.local_hospital
                  : Icons.person,
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
                  _otherParticipantName ?? 'Doctor',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _sessionExpired
                  ? Colors.red.withOpacity(0.1)
                  : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _sessionExpired ? 'Expired' : 'Active',
              style: AppTheme.bodySmallStyle.copyWith(
                color: _sessionExpired ? Colors.red : AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final appointmentId = widget.appointmentData['appointmentId'] as String?;

    if (appointmentId == null || _currentUserId == null) {
      return const Center(
        child: Text('Unable to load messages: Invalid appointment data'),
      );
    }

    return StreamBuilder<List<MessageModel>>(
      stream: DatabaseService(uid: _currentUserId!)
          .getAppointmentMessages(appointmentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
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
                      : 'Start your consultation',
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
                messages[index - 1]
                        .timestamp
                        .difference(message.timestamp)
                        .inMinutes
                        .abs() >
                    5;

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
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                message.senderType == 'doctor'
                    ? Icons.local_hospital
                    : Icons.person,
                color: AppTheme.primaryColor,
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
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: AppTheme.bodyStyle.copyWith(
                      color: isCurrentUser
                          ? Colors.white
                          : AppTheme.textPrimaryColor,
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
              child: Icon(
                _currentUserType == 'doctor'
                    ? Icons.local_hospital
                    : Icons.person,
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
                        : 'Type your message...',
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
                onPressed:
                    _sessionExpired || _isSendingMessage ? null : _sendMessage,
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
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

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
