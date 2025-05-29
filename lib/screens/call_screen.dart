import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../constants/agora_config.dart';
import '../theme/theme.dart';
import '../api/firestore_service.dart';

enum CallState {
  connecting,
  waitingForUser,
  connected,
  reconnecting,
  disconnected,
  ended
}

class CallScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  final bool isAudioOnly;
  final String currentUserType;
  final String currentUserName;

  const CallScreen({
    Key? key,
    required this.appointmentData,
    this.isAudioOnly = false,
    required this.currentUserType,
    required this.currentUserName,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  RtcEngine? _engine;
  bool _isJoined = false;
  bool _isConnecting = true;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerEnabled = false;
  bool _isControlsVisible = true;
  bool _isFrontCamera = true;
  bool _isRemoteVideoEnabled = true;
  bool _isRemoteUserJoined = false;
  bool _isDisposed = false;
  int? _remoteUid;

  bool? _lastRemoteAudioState;
  bool? _lastRemoteVideoState;
  bool _isInitialConnection = true;

  Timer? _controlsTimer;
  Timer? _callTimer;
  Timer? _sessionTimer;
  Timer? _autoEndTimer;
  Duration _callDuration = Duration.zero;
  bool _sessionExpired = false;

  AnimationController? _pulseController;
  AnimationController? _connectingController;
  Animation<double>? _pulseAnimation;
  Animation<double>? _connectingAnimation;

  String? _otherParticipantName;
  String _channelName = '';
  CallState _callState = CallState.connecting;
  String _statusMessage = 'Connecting...';

  DatabaseService? _databaseService;

  @override
  void initState() {
    super.initState();
    _validateAndInitialize();
  }

  void _validateAndInitialize() {
    final appointmentId = _getAppointmentId();
    if (appointmentId == null || appointmentId.isEmpty) {
      _showErrorAndExit('Invalid appointment data: Missing appointment ID');
      return;
    }

    final currentUserId = _getCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      _showErrorAndExit('Invalid user data: Missing user ID');
      return;
    }

    _initializeCall();
    _setupAnimations();
    _initializeAgora();
    _startSessionMonitoring();
    _initializeDatabase();
  }

  String? _getAppointmentId() {
    return widget.appointmentData['appointmentId'] as String? ??
        widget.appointmentData['id'] as String?;
  }

  String? _getCurrentUserId() {
    if (widget.currentUserType == 'patient') {
      return widget.appointmentData['patientId'] as String?;
    } else {
      return widget.appointmentData['doctorId'] as String?;
    }
  }

  void _showErrorAndExit(String message) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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

  void _initializeDatabase() {
    final currentUserId = _getCurrentUserId();
    if (currentUserId != null) {
      _databaseService = DatabaseService(uid: currentUserId);
      _updateCallState('calling');
    }
  }

  Future<void> _updateCallState(String state) async {
    if (_databaseService != null && !_isDisposed) {
      try {
        final appointmentId = _getAppointmentId();
        if (appointmentId != null) {
          await _databaseService!.updateCallState(
            appointmentId: appointmentId,
            callState: state,
            callerType: widget.currentUserType,
            callerName: widget.currentUserName,
          );
        }
      } catch (e) {
        print('Error updating call state: $e');
      }
    }
  }

  void _initializeCall() {
    if (widget.currentUserType == 'patient') {
      _otherParticipantName =
          widget.appointmentData['doctorName'] as String? ?? 'Doctor';
    } else {
      _otherParticipantName =
          widget.appointmentData['patientName'] as String? ?? 'Patient';
    }

    final appointmentId = _getAppointmentId();
    if (appointmentId != null) {
      _channelName = AgoraConfig.generateChannelName(appointmentId);
    } else {
      _channelName = 'default_channel_${DateTime.now().millisecondsSinceEpoch}';
    }

    if (widget.isAudioOnly) {
      _isVideoEnabled = false;
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    _connectingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _connectingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _connectingController!, curve: Curves.linear),
    );
  }

  void _startSessionMonitoring() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && !_sessionExpired && !_isDisposed) {
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
    if (_sessionExpired || _isDisposed) return;

    setState(() {
      _sessionExpired = true;
      _callState = CallState.ended;
      _statusMessage = 'Session expired';
    });

    _sessionTimer?.cancel();
    _updateCallState('ended');

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
            'Your consultation session has ended. The call will be terminated.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _endCall();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initializeAgora() async {
    try {
      await _requestPermissions();

      await WakelockPlus.enable();

      if (AgoraConfig.appId.isEmpty) {
        throw Exception('Agora App ID not configured');
      }

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print("User joined channel: ${connection.channelId}");
            if (mounted && !_isDisposed) {
              setState(() {
                _isJoined = true;
                _isConnecting = false;
                _callState = CallState.waitingForUser;
                _statusMessage = 'Waiting for $_otherParticipantName...';
                _isInitialConnection = true;
              });
              _connectingController?.stop();
              _startCallTimer();
              _startControlsTimer();
              _updateCallState('joined');
            }
          },
          onUserJoined: (RtcConnection connection, int uid, int elapsed) {
            print("Remote user $uid joined");
            if (mounted && !_isDisposed) {
              setState(() {
                _remoteUid = uid;
                _isRemoteUserJoined = true;
                _callState = CallState.connected;
                _statusMessage = 'Connected';
                _isInitialConnection = false;
              });

              _autoEndTimer?.cancel();

              _updateCallState('connected');

              _showNotification('$_otherParticipantName joined the call');

              if (widget.isAudioOnly &&
                  _pulseController != null &&
                  !_isDisposed) {
                _pulseController!.repeat(reverse: true);
              }
            }
          },
          onUserOffline: (RtcConnection connection, int uid,
              UserOfflineReasonType reason) {
            print("Remote user $uid left channel, reason: $reason");
            if (mounted && !_isDisposed) {
              setState(() {
                _remoteUid = null;
                _isRemoteUserJoined = false;
                _callState = reason == UserOfflineReasonType.userOfflineDropped
                    ? CallState.disconnected
                    : CallState.waitingForUser;
                _statusMessage =
                    reason == UserOfflineReasonType.userOfflineDropped
                        ? 'Connection lost'
                        : '$_otherParticipantName left the call';
              });

              String message =
                  reason == UserOfflineReasonType.userOfflineDropped
                      ? 'Connection lost with $_otherParticipantName'
                      : '$_otherParticipantName left the call';
              _showNotification(message);

              _pulseController?.stop();

              _autoEndTimer = Timer(const Duration(seconds: 30), () {
                if (!_isRemoteUserJoined && mounted && !_isDisposed) {
                  _showAutoEndDialog();
                }
              });
            }
          },
          onRemoteVideoStateChanged: (RtcConnection connection,
              int uid,
              RemoteVideoState state,
              RemoteVideoStateReason reason,
              int elapsed) {
            if (mounted && !_isDisposed && uid == _remoteUid) {
              bool isVideoEnabled =
                  state == RemoteVideoState.remoteVideoStateStarting ||
                      state == RemoteVideoState.remoteVideoStateDecoding;

              if (_lastRemoteVideoState != null &&
                  _lastRemoteVideoState != isVideoEnabled &&
                  !_isInitialConnection) {
                setState(() {
                  _isRemoteVideoEnabled = isVideoEnabled;
                });

                String message = isVideoEnabled
                    ? '$_otherParticipantName turned on camera'
                    : '$_otherParticipantName turned off camera';
                _showNotification(message);
              } else {
                setState(() {
                  _isRemoteVideoEnabled = isVideoEnabled;
                });
              }

              _lastRemoteVideoState = isVideoEnabled;
            }
          },
          onRemoteAudioStateChanged: (RtcConnection connection,
              int uid,
              RemoteAudioState state,
              RemoteAudioStateReason reason,
              int elapsed) {
            if (uid == _remoteUid && mounted && !_isDisposed) {
              bool isAudioEnabled =
                  state == RemoteAudioState.remoteAudioStateStarting ||
                      state == RemoteAudioState.remoteAudioStateDecoding;

              if (_lastRemoteAudioState != null &&
                  _lastRemoteAudioState != isAudioEnabled &&
                  !_isInitialConnection) {
                String message = isAudioEnabled
                    ? '$_otherParticipantName unmuted'
                    : '$_otherParticipantName muted';
                _showNotification(message);
              }

              _lastRemoteAudioState = isAudioEnabled;
            }
          },
          onConnectionStateChanged: (RtcConnection connection,
              ConnectionStateType state, ConnectionChangedReasonType reason) {
            print("Connection state changed: $state, reason: $reason");

            if (mounted && !_isDisposed) {
              CallState newCallState;
              String status = '';

              switch (state) {
                case ConnectionStateType.connectionStateConnecting:
                  newCallState = CallState.connecting;
                  status = 'Connecting...';
                  break;
                case ConnectionStateType.connectionStateConnected:
                  newCallState = _isRemoteUserJoined
                      ? CallState.connected
                      : CallState.waitingForUser;
                  status = _isRemoteUserJoined
                      ? 'Connected'
                      : 'Waiting for $_otherParticipantName...';
                  break;
                case ConnectionStateType.connectionStateReconnecting:
                  newCallState = CallState.reconnecting;
                  status = 'Reconnecting...';
                  break;
                case ConnectionStateType.connectionStateDisconnected:
                  newCallState = CallState.disconnected;
                  status = 'Disconnected';
                  break;
                case ConnectionStateType.connectionStateFailed:
                  newCallState = CallState.disconnected;
                  status = 'Connection failed';
                  break;
              }

              setState(() {
                _callState = newCallState;
                _statusMessage = status;
              });
            }
          },
          onError: (ErrorCodeType err, String msg) {
            print("Agora error: $err, $msg");
            if (mounted && !_isDisposed) {
              _showNotification('Call error: $msg', isError: true);
            }
          },
        ),
      );

      if (!widget.isAudioOnly) {
        await _engine!.enableVideo();
      } else {
        await _engine!.disableVideo();
      }

      if (_channelName.isNotEmpty) {
        await _engine!.joinChannel(
          token: AgoraConfig.token ?? '',
          channelId: _channelName,
          uid: 0,
          options: const ChannelMediaOptions(),
        );

        _connectingController?.repeat();
      } else {
        throw Exception('Invalid channel name');
      }
    } catch (e) {
      print("Error initializing Agora: $e");
      if (mounted && !_isDisposed) {
        setState(() {
          _isConnecting = false;
          _callState = CallState.disconnected;
          _statusMessage = 'Failed to connect';
        });
        _showNotification('Failed to start call: $e', isError: true);
      }
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    if (permissions[Permission.microphone] != PermissionStatus.granted) {
      throw Exception('Microphone permission required');
    }

    if (!widget.isAudioOnly &&
        permissions[Permission.camera] != PermissionStatus.granted) {
      throw Exception('Camera permission required');
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isDisposed) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
      }
    });
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isJoined && !_isDisposed) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _showControls() {
    if (!_isDisposed) {
      setState(() {
        _isControlsVisible = true;
      });
      _startControlsTimer();
    }
  }

  void _showNotification(String message, {bool isError = false}) {
    if (mounted && !_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error : Icons.info,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? Colors.red : Colors.blue.shade600,
          duration: Duration(seconds: isError ? 4 : 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 100,
            left: 20,
            right: 20,
          ),
        ),
      );
    }
  }

  void _showAutoEndDialog() {
    if (!mounted || _isDisposed) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Call Ended'),
          ],
        ),
        content: Text(
          '$_otherParticipantName has left the call. The call will be ended automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _endCall();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMute() async {
    if (_engine != null && !_isDisposed) {
      await _engine!.muteLocalAudioStream(!_isMuted);
      setState(() {
        _isMuted = !_isMuted;
      });
    }
  }

  Future<void> _toggleVideo() async {
    if (!widget.isAudioOnly && _engine != null && !_isDisposed) {
      if (_isVideoEnabled) {
        await _engine!.muteLocalVideoStream(true);
      } else {
        await _engine!.muteLocalVideoStream(false);
      }
      setState(() {
        _isVideoEnabled = !_isVideoEnabled;
      });
    }
  }

  Future<void> _toggleSpeaker() async {
    if (_engine != null && !_isDisposed) {
      await _engine!.setEnableSpeakerphone(!_isSpeakerEnabled);
      setState(() {
        _isSpeakerEnabled = !_isSpeakerEnabled;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (!widget.isAudioOnly &&
        _isVideoEnabled &&
        _engine != null &&
        !_isDisposed) {
      await _engine!.switchCamera();
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    }
  }

  Future<void> _endCall() async {
    if (_isDisposed) return;

    HapticFeedback.lightImpact();

    _isDisposed = true;

    await _updateCallState('ended');

    _callTimer?.cancel();
    _controlsTimer?.cancel();
    _sessionTimer?.cancel();
    _autoEndTimer?.cancel();

    try {
      _pulseController?.stop();
      _connectingController?.stop();
    } catch (e) {
      print('Error stopping animations: $e');
    }

    if (_engine != null) {
      try {
        await _engine!.leaveChannel();
        await _engine!.release();
        _engine = null;
      } catch (e) {
        print('Error disposing Agora engine: $e');
      }
    }

    try {
      await WakelockPlus.disable();
    } catch (e) {
      print('Error disabling wakelock: $e');
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    _callTimer?.cancel();
    _controlsTimer?.cancel();
    _sessionTimer?.cancel();
    _autoEndTimer?.cancel();

    _pulseController?.dispose();
    _connectingController?.dispose();

    if (_engine != null) {
      _engine!.leaveChannel();
      _engine!.release();
    }

    _updateCallState('ended');

    WakelockPlus.disable();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (_callState) {
      case CallState.connected:
        return Colors.green;
      case CallState.connecting:
      case CallState.waitingForUser:
      case CallState.reconnecting:
        return Colors.orange;
      case CallState.disconnected:
      case CallState.ended:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _showControls,
        child: Stack(
          children: [
            _buildVideoArea(),

            if (_isConnecting) _buildConnectingOverlay(),

            if (_isControlsVisible || _isConnecting) _buildControlsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    if (widget.isAudioOnly) {
      return _buildAudioOnlyView();
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[900],
          child:
              _isRemoteUserJoined && _isRemoteVideoEnabled && _remoteUid != null
                  ? AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: _engine!,
                        canvas: VideoCanvas(uid: _remoteUid),
                        connection: RtcConnection(channelId: _channelName),
                      ),
                    )
                  : _buildVideoPlaceholder(isRemote: true),
        ),

        if (_isVideoEnabled)
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _isJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : _buildVideoPlaceholder(isRemote: false),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAudioOnlyView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 3),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 60,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            _otherParticipantName ?? 'Participant',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _isJoined
                ? (_isRemoteUserJoined ? _formatCallDuration() : _statusMessage)
                : 'Connecting...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 40),

          if (_isJoined &&
              !_isMuted &&
              _isRemoteUserJoined &&
              _pulseAnimation != null)
            AnimatedBuilder(
              animation: _pulseAnimation!,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation!.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder({required bool isRemote}) {
    String name = isRemote
        ? (_otherParticipantName ?? 'Participant')
        : widget.currentUserName;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isRemote
              ? [Colors.grey[800]!, Colors.grey[900]!]
              : [AppTheme.primaryColor.withOpacity(0.6), AppTheme.primaryColor],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            color: Colors.white.withOpacity(0.7),
            size: isRemote ? 80 : 40,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isRemote ? 18 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isRemote && !_isRemoteUserJoined && _isJoined) ...[
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_connectingAnimation != null)
            AnimatedBuilder(
              animation: _connectingAnimation!,
              builder: (context, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CircularProgressIndicator(
                    value: _connectingAnimation!.value,
                    strokeWidth: 3,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          Text(
            _statusMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we establish the connection',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return AnimatedOpacity(
      opacity: _isControlsVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.6),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            _buildTopControls(),

            const Spacer(),

            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            GestureDetector(
              onTap: _endCall,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            const Spacer(),

            if (_isJoined)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isRemoteUserJoined
                          ? _formatCallDuration()
                          : _statusMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_isJoined)
              Column(
                children: [
                  Text(
                    _otherParticipantName ?? 'Participant',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!_isRemoteUserJoined)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          color: _getStatusColor(),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  isActive: !_isMuted,
                  onPressed: _toggleMute,
                ),

                if (!widget.isAudioOnly)
                  _buildControlButton(
                    icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    isActive: _isVideoEnabled,
                    onPressed: _toggleVideo,
                  ),

                _buildControlButton(
                  icon: Icons.call_end,
                  isActive: false,
                  isEndCall: true,
                  onPressed: _endCall,
                ),

                _buildControlButton(
                  icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_down,
                  isActive: _isSpeakerEnabled,
                  onPressed: _toggleSpeaker,
                ),

                if (!widget.isAudioOnly && _isVideoEnabled)
                  _buildControlButton(
                    icon: Icons.cameraswitch,
                    isActive: true,
                    onPressed: _switchCamera,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    bool isEndCall = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isEndCall
              ? Colors.red
              : isActive
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (_callState) {
      case CallState.connected:
        return Icons.check_circle;
      case CallState.connecting:
      case CallState.reconnecting:
        return Icons.sync;
      case CallState.waitingForUser:
        return Icons.hourglass_empty;
      case CallState.disconnected:
      case CallState.ended:
        return Icons.error;
    }
  }

  String _formatCallDuration() {
    final hours = _callDuration.inHours;
    final minutes = _callDuration.inMinutes % 60;
    final seconds = _callDuration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}