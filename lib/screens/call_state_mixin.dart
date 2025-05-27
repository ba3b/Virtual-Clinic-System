import 'dart:async';
import 'package:flutter/material.dart';
import '../api/firestore_service.dart';
import 'incoming_call_dialog.dart';

mixin CallStateMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription? _callStateSubscription;
  bool _isCallDialogShowing = false;
  String? _lastCallState;
  DatabaseService? _databaseService;

  void initializeCallStateListener({
    required String appointmentId,
    required String currentUserId,
    required String currentUserType,
    required String currentUserName,
    required Map<String, dynamic> appointmentData,
  }) {
    // Validate required parameters
    if (appointmentId.isEmpty || currentUserId.isEmpty || 
        currentUserType.isEmpty || currentUserName.isEmpty) {
      print('Warning: Invalid parameters for call state listener');
      return;
    }

    _databaseService = DatabaseService(uid: currentUserId);
    
    // Listen to call state changes
    _callStateSubscription = _databaseService!
        .getCallStateStream(appointmentId)
        .listen((callStateData) {
      if (callStateData != null && mounted) {
        final callState = callStateData['callState'] as String?;
        final callerType = callStateData['callerType'] as String?;
        final callerName = callStateData['callerName'] as String?;
        
        // Check if this is a new incoming call
        if (callState == 'calling' && 
            callerType != null && 
            callerType != currentUserType &&
            !_isCallDialogShowing &&
            _lastCallState != 'calling') {
          
          _lastCallState = callState;
          _showIncomingCallDialog(
            appointmentData: appointmentData,
            callerName: callerName ?? 'Unknown',
            callerType: callerType,
            currentUserType: currentUserType,
            currentUserName: currentUserName,
          );
        } else if (callState == 'ended' || callState == 'idle') {
          _lastCallState = callState;
          // Reset state when call ends
          if (_isCallDialogShowing) {
            Navigator.of(context).pop();
            _isCallDialogShowing = false;
          }
        }
      }
    }, onError: (error) {
      print('Error listening to call state: $error');
    });
  }

  void _showIncomingCallDialog({
    required Map<String, dynamic> appointmentData,
    required String callerName,
    required String callerType,
    required String currentUserType,
    required String currentUserName,
  }) {
    if (_isCallDialogShowing || !mounted) return;
    
    _isCallDialogShowing = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => IncomingCallDialog(
        appointmentData: appointmentData,
        callerName: callerName,
        callerType: callerType,
        isVideoCall: true, // You can determine this from appointmentData
        currentUserType: currentUserType,
        currentUserName: currentUserName,
      ),
    ).then((_) {
      _isCallDialogShowing = false;
    });
  }

  void disposeCallStateListener() {
    _callStateSubscription?.cancel();
    _callStateSubscription = null;
    _databaseService = null;
  }
}