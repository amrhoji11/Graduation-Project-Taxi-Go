import 'package:signalr_netcore/signalr_client.dart';

import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/core/storage/token_storage.dart';

/// Thin wrapper around the single backend hub
/// (`TaxiApp.Backend.Infrastructure.Helper.NotificationHub`, mapped at
/// `/notificationHub`). There is only one hub for the whole backend - driver
/// location, trip status, notifications and chat all flow through it.
class SignalRService {
  HubConnection? _hubConnection;
  Future<void>? _connectFuture;

  /// `ApiEndpoints.baseUrl` is `<host>/api`, but the hub is mapped on the
  /// server root (`Program.cs`: `app.MapHub<NotificationHub>("/notificationHub")`),
  /// not under `/api`.
  static String get _hubUrl {
    final base = ApiEndpoints.baseUrl;
    final host = base.endsWith('/api')
        ? base.substring(0, base.length - '/api'.length)
        : base;
    return '$host/notificationHub';
  }

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  Future<void> connect() {
    if (isConnected) return Future.value();
    return _connectFuture ??= _doConnect().whenComplete(() {
      _connectFuture = null;
    });
  }

  Future<void> _doConnect() async {
    final connection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                await TokenStorage.instance.getAccessToken() ?? '',
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection = connection;
    await connection.start();
  }

  Future<void> disconnect() async {
    final connection = _hubConnection;
    _hubConnection = null;
    await connection?.stop();
  }

  /// Registers a handler for a server-sent event. Must be called after
  /// [connect] has resolved.
  void on(String eventName, void Function(List<Object?>? arguments) handler) {
    _hubConnection?.on(eventName, handler);
  }

  void off(String eventName) {
    _hubConnection?.off(eventName);
  }

  /// Generic escape hatch for invoking any hub method by name.
  Future<void> invoke(String methodName, {List<Object>? args}) async {
    final connection = _hubConnection;
    if (connection == null ||
        connection.state != HubConnectionState.Connected) {
      throw StateError(
        'SignalR is not connected. Call SignalRService.connect() first.',
      );
    }
    await connection.invoke(methodName, args: args);
  }

  /// `NotificationHub.SendLocation(decimal lat, decimal lng)` - the driver id
  /// is derived server-side from the JWT, it is never sent as an argument.
  Future<void> sendLocation(double lat, double lng) {
    return invoke('SendLocation', args: [lat, lng]);
  }

  /// `NotificationHub.JoinTrip(int tripId)` - subscribes the caller to the
  /// `trip-{tripId}` group so it receives that trip's DriverLocationUpdated /
  /// RouteUpdated / UpdateTripStatus / ReceiveMessage events.
  Future<void> joinTrip(int tripId) {
    return invoke('JoinTrip', args: [tripId]);
  }

  /// `NotificationHub.LeaveTrip(int tripId)`.
  Future<void> leaveTrip(int tripId) {
    return invoke('LeaveTrip', args: [tripId]);
  }
}
