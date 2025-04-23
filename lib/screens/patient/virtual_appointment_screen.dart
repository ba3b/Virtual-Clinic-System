import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../components/common_button.dart';
import '../../theme/theme.dart';

class VirtualAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  
  const VirtualAppointmentScreen({
    Key? key,
    required this.appointmentData,
  }) : super(key: key);

  @override
  State<VirtualAppointmentScreen> createState() => _VirtualAppointmentScreenState();
}

class _VirtualAppointmentScreenState extends State<VirtualAppointmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  
  // Sample messages for demonstration
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'doctor',
      'message': 'Hello, how can I help you today?',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'sender': 'patient',
      'message': 'I\'ve been having a headache for two days now.',
      'time': DateTime.now().subtract(const Duration(minutes: 4)),
    },
    {
      'sender': 'doctor',
      'message': 'I see. Have you taken any medication for it?',
      'time': DateTime.now().subtract(const Duration(minutes: 3)),
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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'patient',
          'message': _messageController.text,
          'time': DateTime.now(),
        });
        _messageController.clear();
      });
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
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoCallTab(),
                _buildMessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCallTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_rounded,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'Video Call with Dr. ${widget.appointmentData['doctorName']}',
            style: AppTheme.headingStyle.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'The video call feature will be implemented in the next phase.',
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: CommonButton(
              text: 'Join Call',
              onPressed: () {
                // This will be connected to Agora SDK in the next phase
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video call feature will be implemented next'),
                  ),
                );
              },
            ),
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
                        'Start the conversation with your doctor',
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
                      alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDoctor
                              ? AppTheme.surfaceColor
                              : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomLeft: isDoctor ? const Radius.circular(0) : null,
                            bottomRight: isDoctor ? null : const Radius.circular(0),
                          ),
                          border: Border.all(
                            color: isDoctor
                                ? AppTheme.dividerColor
                                : AppTheme.primaryColor.withOpacity(0.3),
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