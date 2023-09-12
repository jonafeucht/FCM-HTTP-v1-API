
class FCMService {
  Future<bool> sendFCMToUser({
    context,
    required String userFCMToken,
    required Map<String, dynamic> notificationData,
  }) async {
    Map<String, dynamic> env = Platform.environment;

    try {
      final serviceAccountMap = {
        "private_key_id": env["service_account_private_key_id"],
        "private_key": env["service_account_private_key"],
        "client_email": env["service_account_client_email"],
        "client_id": env["service_account_client_id"],
        "type": "service_account",
      };
      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountMap);

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      AuthClient credentials = await clientViaServiceAccount(
        accountCredentials,
        scopes,
      );

      var accessToken = credentials.credentials.accessToken.data;
      context.log(accessToken);

      final url = Uri.parse(
          "https://fcm.googleapis.com/v1/projects/${env["FIREBASE_PROJECT_ID"]}/messages:send");

      final res = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "message": {
            'token': userFCMToken,
            'notification': notificationData,
          }
        }),
      );
      if (res.statusCode == 200) {
        context.log("Push notification send.");

        return true;
      } else {
        context.error("Push notification failed.");
        return false;
      }
    } catch (e) {
      context.error(e);
      return false;
    }
  }
}
