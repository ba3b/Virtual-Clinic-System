class AgoraConfig {
  static const String appId = "d68ef126968b41539c2616c029ff05da";
  
  // For testing, you can use null token
  // For production, implement token generation on your server
  static const String? token = null;
  
  // Channel naming convention: appointment_id
  static String generateChannelName(String appointmentId) {
    return "appointment_$appointmentId";
  }
}