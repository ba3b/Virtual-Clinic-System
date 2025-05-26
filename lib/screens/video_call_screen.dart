import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

class VideoCallScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  final bool isAudioOnly;

  const VideoCallScreen({
    Key? key,
    required this.appointmentData,
    this.isAudioOnly = false,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with TickerProviderStateMixin {
  bool _isCallActive = false;
  bool _isConnecting = true;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerEnabled = false;
  bool _isControlsVisible = true;
  bool _isFrontCamera = true;
  bool _isRemoteVideoEnabled = true;
  bool _isRemoteAudioEnabled = true;
  
  Timer? _controlsTimer;
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  
  late AnimationController _pulseController;
  late AnimationController _connectingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _connectingAnimation;

  String? _currentUserType;
  String? _otherParticipantName;

  @override
  void initState() {
    super.initState();
    _initializeCall();
    _setupAnimations();
    _startConnecting();
  }

  void _initializeCall() {
    // Get participant info from appointment data
    _otherParticipantName = widget.appointmentData['doctorName'] as String? ?? 'Doctor';
    _currentUserType = 'patient'; // This will be determined from actual user data
    
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
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _connectingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _connectingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _connectingController, curve: Curves.linear),
    );
  }

  void _startConnecting() {
    _connectingController.repeat();
    
    // Simulate connection process
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isCallActive = true;
        });
        _startCallTimer();
        _connectingController.stop();
        _startControlsTimer();
      }
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
      }
    });
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isCallActive) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _showControls() {
    setState(() {
      _isControlsVisible = true;
    });
    _startControlsTimer();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    // TODO: Implement actual mute functionality
  }

  void _toggleVideo() {
    if (!widget.isAudioOnly) {
      setState(() {
        _isVideoEnabled = !_isVideoEnabled;
      });
      // TODO: Implement actual video toggle functionality
    }
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
    });
    // TODO: Implement actual speaker toggle functionality
  }

  void _switchCamera() {
    if (!widget.isAudioOnly && _isVideoEnabled) {
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
      // TODO: Implement actual camera switch functionality
    }
  }

  void _endCall() {
    HapticFeedback.lightImpact();
    
    _callTimer?.cancel();
    _controlsTimer?.cancel();
    _pulseController.dispose();
    _connectingController.dispose();
    
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _controlsTimer?.cancel();
    _pulseController.dispose();
    _connectingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _showControls,
        child: Stack(
          children: [
            // Main Video Area
            _buildVideoArea(),
            
            // Connecting Overlay
            if (_isConnecting) _buildConnectingOverlay(),
            
            // Controls Overlay
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
        // Remote Video (Full Screen)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[900],
          child: _isRemoteVideoEnabled
              ? _buildVideoPlaceholder(isRemote: true)
              : _buildVideoDisabledView(isRemote: true),
        ),
        
        // Local Video (Picture-in-Picture)
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
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildVideoPlaceholder(isRemote: false),
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
          // Participant Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 60,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Participant Name
          Text(
            _otherParticipantName ?? 'Doctor',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Call Status
          Text(
            _isCallActive ? _formatCallDuration() : 'Connecting...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Audio Indicator
          if (_isCallActive && _isRemoteAudioEnabled)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up,
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
            isRemote ? (_otherParticipantName ?? 'Doctor') : 'You',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isRemote ? 18 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoDisabledView({required bool isRemote}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isRemote ? 100 : 50,
            height: isRemote ? 100 : 50,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_off,
              color: Colors.white.withOpacity(0.7),
              size: isRemote ? 50 : 25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${isRemote ? (_otherParticipantName ?? 'Doctor') : 'Your'} camera is off',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isRemote ? 16 : 12,
            ),
          ),
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
          AnimatedBuilder(
            animation: _connectingAnimation,
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
                  value: _connectingAnimation.value,
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Connecting...',
            style: TextStyle(
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
            // Top Controls
            _buildTopControls(),
            
            const Spacer(),
            
            // Bottom Controls
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
            // Back Button
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
            
            // Call Info
            if (_isCallActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCallDuration(),
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
            // Participant Name
            if (_isCallActive)
              Text(
                _otherParticipantName ?? 'Doctor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute Button
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  isActive: !_isMuted,
                  onPressed: _toggleMute,
                ),
                
                // Video Toggle (if not audio-only)
                if (!widget.isAudioOnly)
                  _buildControlButton(
                    icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    isActive: _isVideoEnabled,
                    onPressed: _toggleVideo,
                  ),
                
                // End Call Button
                _buildControlButton(
                  icon: Icons.call_end,
                  isActive: false,
                  isEndCall: true,
                  onPressed: _endCall,
                ),
                
                // Speaker Button
                _buildControlButton(
                  icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_down,
                  isActive: _isSpeakerEnabled,
                  onPressed: _toggleSpeaker,
                ),
                
                // Camera Switch (if video enabled)
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