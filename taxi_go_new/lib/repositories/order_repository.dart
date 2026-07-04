import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/create_order_model.dart';
import 'package:taxi_go_new/models/order_model.dart';
import 'package:taxi_go_new/models/trip_route_model.dart';
import 'package:taxi_go_new/models/update_order_model.dart';

class OrderRepository {
  final ApiClient apiClient;

  OrderRepository({
    required this.apiClient,
  });

  /// `POST /Orders/CreateOrder` - returns the full `OrderDetailDto`, not the
  /// list-shaped `OrderDto`.
  Future<OrderDetailModel> createOrder(CreateOrderModel model) async {
    final response = await apiClient.post(
      ApiEndpoints.createOrder,
      data: model.toJson(),
    );

    return OrderDetailModel.fromJson(_extractMap(response.data));
  }

  /// `GET /Orders/GetAll` - `pageNumber`/`pageSize` are plain non-nullable
  /// `int` query params on the backend with no default, so omitting them
  /// binds to 0 and `Take(0)` silently returns an always-empty page.
  Future<List<OrderModel>> getOrders({
    int pageNumber = 1,
    int pageSize = 50,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.orders,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      },
    );
    return _parseOrders(response.data);
  }

  /// `GET /Orders/{id}` - used for the active-order/tracking screen and for
  /// refetching detail right after create/cancel/rate.
  Future<OrderDetailModel> getOrderById(int orderId) async {
    final response = await apiClient.get(ApiEndpoints.orderById(orderId));
    return OrderDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// `PUT /Orders/{id}` - backend returns a plain status message string,
  /// not an order object.
  Future<String> updateOrder({
    required int orderId,
    required UpdateOrderModel model,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.updateOrder(orderId),
      data: model.toJson(),
    );

    return response.data?.toString() ?? '';
  }

  /// `PUT /Orders/{id}/Cancel` - no request body on the backend
  /// (`CancelOrder(int id)` takes only the route id).
  Future<String> cancelOrder(int orderId) async {
    final response = await apiClient.put(ApiEndpoints.cancelOrder(orderId));
    return response.data?.toString() ?? '';
  }

  /// `POST /PassengerTrips/rate-driver`.
  Future<void> rateDriver({
    required int orderId,
    required int stars,
    String? comment,
  }) async {
    await apiClient.post(
      ApiEndpoints.rateDriver,
      data: {
        'orderId': orderId,
        'stars': stars,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }

  /// `GET /PassengerTrips/route/{orderId}` - real road route + baseline
  /// ETA for this order's trip, the pull counterpart to the
  /// passenger-safe `RouteUpdated` SignalR push.
  Future<TripRouteModel> getTripRoute(int orderId) async {
    final response = await apiClient.get(ApiEndpoints.passengerTripRoute(orderId));
    return TripRouteModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// `GET /Orders/PreviewRoute` - real road route + ETA between two
  /// arbitrary points, before any order/trip exists. Used by the Create
  /// Order screen to draw the actual road route once pickup+dropoff are
  /// both picked.
  Future<TripRouteModel> previewRoute({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.previewRoute,
      queryParameters: {
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'dropoffLat': dropoffLat,
        'dropoffLng': dropoffLng,
      },
    );
    return TripRouteModel.fromJson(response.data as Map<String, dynamic>);
  }

  List<OrderModel> _parseOrders(dynamic data) {
    if (data is List) {
      return data
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;

    if (data is Map && data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }

    return {};
  }
}