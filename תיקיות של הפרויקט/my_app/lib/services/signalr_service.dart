import 'package:signalr_netcore/signalr_client.dart';

/// Provides SignalR communication for real-time messaging.
class SignalRService {
  HubConnection? _hubConnection;

  /// Initializes the SignalR hub connection and registers the message handler.
  void initHubConnection(String url, Function(String, String, String, String) onMessageReceived) {
    _hubConnection = HubConnectionBuilder().withUrl(url).build();

    _hubConnection!.on("ReceiveMessage", (parameters) {
      if (parameters != null && parameters.length >= 3) {
        onMessageReceived(
          parameters[0].toString(),
          parameters[1].toString(),
          parameters[2].toString(),
          DateTime.now().toString(),
        );
      }
    });
  }

  /// Starts the SignalR connection.
  Future<void> startConnection() async {
    if (_hubConnection?.state == HubConnectionState.Disconnected) {
      await _hubConnection?.start();
    }
  }

  /// Stops the SignalR connection.
  Future<void> stopConnection() async {
    await _hubConnection?.stop();
  }

  /// Sends a message to another user through the SignalR hub.
  void sendMessage(String senderId, String receiverId, String message) {
    _hubConnection?.invoke("SendMessage", args: [senderId, receiverId, message]);
  }
}
