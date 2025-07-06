import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class ApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey =
      '26894c0b8d6d466abc6e4ae61ee36333'; // Replace with your actual API key

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP client with timeout
  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 30);

  /// Get top headlines
  /// [country] - Country code (e.g., 'us', 'in', 'gb')
  /// [category] - Category (business, entertainment, general, health, science, sports, technology)
  /// [sources] - Comma-separated string of news sources or blogs
  /// [q] - Keywords or phrases to search for
  /// [pageSize] - Number of results to return per page (max 100)
  /// [page] - Page number to retrieve
  Future<ApiResponse<Welcome>> getTopHeadlines({
    String? country,
    String? category,
    String? sources,
    String? q,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
      };

      if (country != null) queryParams['country'] = country;
      if (category != null) queryParams['category'] = category;
      if (sources != null) queryParams['sources'] = sources;
      if (q != null) queryParams['q'] = q;

      final uri = Uri.parse(
        '$_baseUrl/top-headlines',
      ).replace(queryParameters: queryParams);

      final response = await _client.get(uri).timeout(_timeout);

      return _handleResponse<Welcome>(
        response,
        (json) => Welcome.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Search for articles
  /// [q] - Keywords or phrases to search for (required)
  /// [searchIn] - Fields to restrict search to (title, description, content)
  /// [sources] - Comma-separated string of news sources or blogs
  /// [domains] - Comma-separated string of domains to restrict search to
  /// [excludeDomains] - Comma-separated string of domains to exclude
  /// [from] - Oldest article allowed (ISO 8601 format)
  /// [to] - Newest article allowed (ISO 8601 format)
  /// [language] - Language code (e.g., 'en', 'es', 'fr')
  /// [sortBy] - Sort order (relevancy, popularity, publishedAt)
  /// [pageSize] - Number of results to return per page (max 100)
  /// [page] - Page number to retrieve
  Future<ApiResponse<Welcome>> searchEverything({
    required String q,
    String? searchIn,
    String? sources,
    String? domains,
    String? excludeDomains,
    DateTime? from,
    DateTime? to,
    String? language,
    String sortBy = 'publishedAt',
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'q': q,
        'apiKey': _apiKey,
        'sortBy': sortBy,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
      };

      if (searchIn != null) queryParams['searchIn'] = searchIn;
      if (sources != null) queryParams['sources'] = sources;
      if (domains != null) queryParams['domains'] = domains;
      if (excludeDomains != null)
        queryParams['excludeDomains'] = excludeDomains;
      if (from != null) queryParams['from'] = from.toIso8601String();
      if (to != null) queryParams['to'] = to.toIso8601String();
      if (language != null) queryParams['language'] = language;

      final uri = Uri.parse(
        '$_baseUrl/everything',
      ).replace(queryParameters: queryParams);

      final response = await _client.get(uri).timeout(_timeout);

      return _handleResponse<Welcome>(
        response,
        (json) => Welcome.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get news sources
  /// [category] - Category to filter sources
  /// [language] - Language code to filter sources
  /// [country] - Country code to filter sources
  Future<ApiResponse<SourcesResponse>> getSources({
    String? category,
    String? language,
    String? country,
  }) async {
    try {
      final Map<String, String> queryParams = {'apiKey': _apiKey};

      if (category != null) queryParams['category'] = category;
      if (language != null) queryParams['language'] = language;
      if (country != null) queryParams['country'] = country;

      final uri = Uri.parse(
        '$_baseUrl/sources',
      ).replace(queryParameters: queryParams);

      final response = await _client.get(uri).timeout(_timeout);

      return _handleResponse<SourcesResponse>(
        response,
        (json) => SourcesResponse.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Handle HTTP response and parse JSON
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Check if API returned an error
        if (jsonData['status'] == 'error') {
          return ApiResponse.error(
            ApiError(
              code: jsonData['code'] ?? 'unknown_error',
              message: jsonData['message'] ?? 'Unknown error occurred',
            ),
          );
        }

        final data = fromJson(jsonData);
        return ApiResponse.success(data);
      } catch (e) {
        return ApiResponse.error(
          ApiError(
            code: 'parse_error',
            message: 'Failed to parse response: $e',
          ),
        );
      }
    } else {
      return ApiResponse.error(
        ApiError(
          code: 'http_error',
          message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        ),
      );
    }
  }

  /// Handle various types of errors
  ApiError _handleError(dynamic error) {
    if (error is SocketException) {
      return ApiError(code: 'network_error', message: 'No internet connection');
    } else if (error is HttpException) {
      return ApiError(
        code: 'http_error',
        message: 'HTTP error: ${error.message}',
      );
    } else if (error.toString().contains('TimeoutException')) {
      return ApiError(code: 'timeout_error', message: 'Request timeout');
    } else {
      return ApiError(
        code: 'unknown_error',
        message: 'An unexpected error occurred: $error',
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final T? data;
  final ApiError? error;
  final bool isSuccess;

  ApiResponse._({this.data, this.error, required this.isSuccess});

  factory ApiResponse.success(T data) {
    return ApiResponse._(data: data, isSuccess: true);
  }

  factory ApiResponse.error(ApiError error) {
    return ApiResponse._(error: error, isSuccess: false);
  }
}

/// API error model
class ApiError {
  final String code;
  final String message;

  ApiError({required this.code, required this.message});

  @override
  String toString() => 'ApiError(code: $code, message: $message)';
}

/// Sources response model
class SourcesResponse {
  final String? status;
  final List<NewsSource>? sources;

  SourcesResponse({this.status, this.sources});

  factory SourcesResponse.fromJson(Map<String, dynamic> json) {
    return SourcesResponse(
      status: json['status'],
      sources: json['sources'] != null
          ? List<NewsSource>.from(
              json['sources'].map((x) => NewsSource.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'sources': sources?.map((x) => x.toJson()).toList(),
    };
  }
}

/// News source model
class NewsSource {
  final String? id;
  final String? name;
  final String? description;
  final String? url;
  final String? category;
  final String? language;
  final String? country;

  NewsSource({
    this.id,
    this.name,
    this.description,
    this.url,
    this.category,
    this.language,
    this.country,
  });

  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      url: json['url'],
      category: json['category'],
      language: json['language'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'url': url,
      'category': category,
      'language': language,
      'country': country,
    };
  }
}

/// News categories enum
enum NewsCategory {
  business,
  entertainment,
  general,
  health,
  science,
  sports,
  technology,
}

/// News languages enum
enum NewsLanguage {
  ar, // Arabic
  de, // German
  en, // English
  es, // Spanish
  fr, // French
  he, // Hebrew
  it, // Italian
  nl, // Dutch
  no, // Norwegian
  pt, // Portuguese
  ru, // Russian
  sv, // Swedish
  ud, // Urdu
  zh, // Chinese
}

/// News countries enum
enum NewsCountry {
  ae, // United Arab Emirates
  ar, // Argentina
  at, // Austria
  au, // Australia
  be, // Belgium
  bg, // Bulgaria
  br, // Brazil
  ca, // Canada
  ch, // Switzerland
  cn, // China
  co, // Colombia
  cu, // Cuba
  cz, // Czech Republic
  de, // Germany
  eg, // Egypt
  fr, // France
  gb, // United Kingdom
  gr, // Greece
  hk, // Hong Kong
  hu, // Hungary
  id, // Indonesia
  ie, // Ireland
  il, // Israel
  in_, // India (using in_ to avoid keyword conflict)
  it, // Italy
  jp, // Japan
  kr, // South Korea
  lt, // Lithuania
  lv, // Latvia
  ma, // Morocco
  mx, // Mexico
  my, // Malaysia
  ng, // Nigeria
  nl, // Netherlands
  no, // Norway
  nz, // New Zealand
  ph, // Philippines
  pl, // Poland
  pt, // Portugal
  ro, // Romania
  rs, // Serbia
  ru, // Russia
  sa, // Saudi Arabia
  se, // Sweden
  sg, // Singapore
  si, // Slovenia
  sk, // Slovakia
  th, // Thailand
  tr, // Turkey
  tw, // Taiwan
  ua, // Ukraine
  us, // United States
  ve, // Venezuela
  za, // South Africa
}

/// Sort options for search
enum SortBy { relevancy, popularity, publishedAt }

/// Extension methods for enums
extension NewsCountryExtension on NewsCountry {
  String get value {
    switch (this) {
      case NewsCountry.in_:
        return 'in';
      default:
        return name;
    }
  }
}

extension NewsCategoryExtension on NewsCategory {
  String get value => name;
}

extension NewsLanguageExtension on NewsLanguage {
  String get value => name;
}

extension SortByExtension on SortBy {
  String get value => name;
}
