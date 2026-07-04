import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/core/storage/token_storage.dart';

class ApiService {
  final Dio dio;

  ApiService()
      : dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    _setupSsl();
    _setupInterceptors();
  }

  void _setupSsl() {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

        return client;
      },
    );
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.getAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  Future<Response> login({
    required String phoneNumber,
    String countryCode = '+970',
  }) {
    return dio.post(
      ApiEndpoints.login,
      data: {
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
      },
    );
  }

  Future<Response> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) {
    return dio.post(
      ApiEndpoints.verifyOtp,
      data: {
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
      },
    );
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.get(
      path,
      queryParameters: queryParameters,
    );
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }
}