
class AgoraConfig {
  // TODO: Replace with your actual Agora App ID
  static const String appId = "d68ef126968b41539c2616c029ff05da";
  
  // TODO: Replace with your token server URL or use null for testing
  static const String? token = null; // Use null for testing without token
  
  // Generate a unique channel name based on appointment ID
  static String generateChannelName(String appointmentId) {
    if (appointmentId.isEmpty) {
      // Fallback to timestamp-based channel name
      return 'clinic_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    // Use appointment ID to create a consistent channel name
    // Clean the appointment ID to ensure it's valid for Agora
    String cleanId = appointmentId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    
    if (cleanId.isEmpty) {
      return 'clinic_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    return 'clinic_$cleanId';
  }
  
  // Validate if Agora is properly configured
  static bool isConfigured() {
    return appId.isNotEmpty && appId != "YOUR_AGORA_APP_ID";
  }
  
  // Get configuration status message
  static String getConfigurationMessage() {
    if (!isConfigured()) {
      return 'Agora SDK not configured. Please set your App ID in agora_config.dart';
    }
    return 'Agora SDK configured successfully';
  }
}