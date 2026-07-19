import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Network client using Dio with retry, logging, and error handling
class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;
  Dio get dio => _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.arabicwordpuzzle.com',
        connectTimeout: AppConstants.networkTimeout,
        receiveTimeout: AppConstants.networkTimeout,
        sendTimeout: AppConstants.networkTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(_RetryInterceptor());
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 120,
      ),
    );
    return dio;
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkException(
          'انتهت مهلة الاتصال. حاول مرة أخرى.',
          'TIMEOUT',
        );
      case DioExceptionType.badCertificate:
        return const NetworkException(
          'خطأ في شهادة الأمان.',
          'BAD_CERTIFICATE',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          'لا يوجد اتصال بالإنترنت.',
          'NO_CONNECTION',
        );
      case DioExceptionType.cancel:
        return const NetworkException(
          'تم إلغاء الطلب.',
          'CANCELLED',
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 404) {
          return NotFoundException('المورد غير موجود', '404');
        }
        if (code == 401) {
          return const AuthException('غير مصرح', '401');
        }
        if (code == 403) {
          return const PermissionDeniedException('ممنوع', '403');
        }
        if (code == 429) {
          return const RateLimitException('كثرة الطلبات', '429');
        }
        return ServerException(
          'خطأ في الخادم ($code)',
          code.toString(),
        );
      case DioExceptionType.unknown:
        return UnknownException(
          e.message ?? 'حدث خطأ غير متوقع',
          'UNKNOWN',
        );
    }
  }
}

/// Retry interceptor - retries failed requests with exponential backoff
class _RetryInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRetry = err.requestOptions.extra['retry'] != true &&
        (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.receiveTimeout ||
            (err.response?.statusCode ?? 0) >= 500);
    if (shouldRetry) {
      final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;
      if (retryCount < AppConstants.maxRetries) {
        final delay = Duration(
          milliseconds: 500 * (retryCount + 1) * (retryCount + 1),
        );
        await Future<void>.delayed(delay);
        try {
          final dio = Dio(BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
            connectTimeout: err.requestOptions.connectTimeout,
            receiveTimeout: err.requestOptions.receiveTimeout,
          ));
          final response = await dio.fetch<dynamic>(
            err.requestOptions
              ..extra['retry'] = true
              ..extra['retryCount'] = retryCount + 1,
          );
          return handler.resolve(response);
        } catch (_) {
          return handler.next(err);
        }
      }
    }
    handler.next(err);
  }
}
