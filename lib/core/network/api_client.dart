// to hold api instance/ add authorization headers/ handle base configs

import 'package:dio/dio.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://35.200.252.238:8080',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3NfdXVpZCI6ImI5NmFiOTZkLWNkOTItNDk2MS1hYmQ1LTI4ZWRmYTdjZjE0MCIsImF1dGhvcml6ZWQiOnRydWUsImV4cCI6MTc3MzE2ODIzNSwidXNlcl9pZCI6ImQ2YjZlZGM0LTM0N2YtNDNjMy1iZDkwLWYxZDgyZmY1ZWQ3YSJ9.QEWaS1ZdZ9eZ2ByQtLCP4WW43rkf3SCLyKmuJ18Izes',
          'Content-Type': 'application/json',
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
}
