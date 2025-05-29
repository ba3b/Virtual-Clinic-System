
class AgoraConfig {
  static const String appId = "d68ef126968b41539c2616c029ff05da";
  
  // TODO: Replace with your token server URL or use null for testing
  static const String? token = null; 
  
  static String generateChannelName(String appointmentId) {
    if (appointmentId.isEmpty) {
      return 'clinic_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    String cleanId = appointmentId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    
    if (cleanId.isEmpty) {
      return 'clinic_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    return 'clinic_$cleanId';
  }
  
  static bool isConfigured() {
    return appId.isNotEmpty && appId != "YOUR_AGORA_APP_ID";
  }
  
  static String getConfigurationMessage() {
    if (!isConfigured()) {
      return 'Agora SDK not configured. Please set your App ID in agora_config.dart';
    }
    return 'Agora SDK configured successfully';
  }
}