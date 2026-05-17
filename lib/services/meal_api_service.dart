import 'package:dio/dio.dart';
import '../models/meal.dart';

class MealApiService {
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  late final Dio _dio;

  MealApiService({Dio? dio}) {
    _dio = dio ??
        Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Accept': 'application/json'},
        ));

    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
      _RetryInterceptor(_dio),
    ]);
  }

  // READ — search by name
  Future<List<Meal>> searchMeals(String query) async {
    try {
      final res = await _dio.get('/search.php', queryParameters: {'s': query});
      final meals = res.data['meals'] as List<dynamic>?;
      return meals?.map((m) => Meal.fromJson(m)).toList() ?? [];
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // READ — lookup by id
  Future<Meal?> getMealById(String id) async {
    try {
      final res = await _dio.get('/lookup.php', queryParameters: {'i': id});
      final meals = res.data['meals'] as List<dynamic>?;
      if (meals == null || meals.isEmpty) return null;
      return Meal.fromJson(meals.first);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // READ — random meal
  Future<Meal?> getRandomMeal() async {
    try {
      final res = await _dio.get('/random.php');
      final meals = res.data['meals'] as List<dynamic>?;
      if (meals == null || meals.isEmpty) return null;
      return Meal.fromJson(meals.first);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // READ — filter by category
  Future<List<Meal>> filterByCategory(String category) async {
    try {
      final res =
          await _dio.get('/filter.php', queryParameters: {'c': category});
      final meals = res.data['meals'] as List<dynamic>?;
      return meals?.map((m) => Meal.fromJson(m)).toList() ?? [];
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // READ — all categories
  Future<List<MealCategory>> getCategories() async {
    try {
      final res = await _dio.get('/categories.php');
      final cats = res.data['categories'] as List<dynamic>?;
      return cats?.map((c) => MealCategory.fromJson(c)).toList() ?? [];
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  ApiException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timed out. Check your internet.');
      case DioExceptionType.badResponse:
        return ApiException(
            'Server error ${e.response?.statusCode}: ${e.response?.statusMessage}',
            e.response?.statusCode);
      case DioExceptionType.connectionError:
        return ApiException('No internet connection.');
      default:
        return ApiException('Unexpected error: ${e.message}');
    }
  }

  void close() => _dio.close();
}

class _RetryInterceptor extends Interceptor {
  final Dio dio;
  _RetryInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.type == DioExceptionType.connectionTimeout && err.requestOptions.extra['retried'] != true) {
      err.requestOptions.extra['retried'] = true;
      try {
        final res = await dio.fetch(err.requestOptions);
        return handler.resolve(res);
      } catch (_) {}
    }
    super.onError(err, handler);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}
