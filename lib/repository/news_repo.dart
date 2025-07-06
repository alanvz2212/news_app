import '../models/news_model.dart';
import '../services/api_services.dart';

/// Abstract repository class that defines the contract for news data operations
/// This allows for different implementations (API, local storage, mock data, etc.)
abstract class NewsRepository {
  
  /// Get top headlines with optional filtering
  /// 
  /// Parameters:
  /// - [country]: Country code (e.g., 'us', 'in', 'gb')
  /// - [category]: News category (business, entertainment, general, health, science, sports, technology)
  /// - [sources]: Comma-separated string of news sources or blogs
  /// - [q]: Keywords or phrases to search for in headlines
  /// - [pageSize]: Number of results to return per page (default: 20, max: 100)
  /// - [page]: Page number to retrieve (default: 1)
  /// 
  /// Returns: [ApiResponse<Welcome>] containing the news data or error
  Future<ApiResponse<Welcome>> getTopHeadlines({
    String? country,
    String? category,
    String? sources,
    String? q,
    int pageSize = 20,
    int page = 1,
  });

  /// Search for articles across all news sources
  /// 
  /// Parameters:
  /// - [q]: Keywords or phrases to search for (required)
  /// - [searchIn]: Fields to restrict search to (title, description, content)
  /// - [sources]: Comma-separated string of news sources or blogs
  /// - [domains]: Comma-separated string of domains to restrict search to
  /// - [excludeDomains]: Comma-separated string of domains to exclude
  /// - [from]: Oldest article allowed (ISO 8601 format)
  /// - [to]: Newest article allowed (ISO 8601 format)
  /// - [language]: Language code (e.g., 'en', 'es', 'fr')
  /// - [sortBy]: Sort order (relevancy, popularity, publishedAt)
  /// - [pageSize]: Number of results to return per page (default: 20, max: 100)
  /// - [page]: Page number to retrieve (default: 1)
  /// 
  /// Returns: [ApiResponse<Welcome>] containing the search results or error
  Future<ApiResponse<Welcome>> searchNews({
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
  });

  /// Get available news sources
  /// 
  /// Parameters:
  /// - [category]: Category to filter sources by
  /// - [language]: Language code to filter sources by
  /// - [country]: Country code to filter sources by
  /// 
  /// Returns: [ApiResponse<SourcesResponse>] containing available sources or error
  Future<ApiResponse<SourcesResponse>> getNewsSources({
    String? category,
    String? language,
    String? country,
  });

  /// Get headlines by specific category
  /// 
  /// Parameters:
  /// - [category]: News category (required)
  /// - [country]: Country code to filter by
  /// - [pageSize]: Number of results to return per page (default: 20)
  /// - [page]: Page number to retrieve (default: 1)
  /// 
  /// Returns: [ApiResponse<Welcome>] containing category news or error
  Future<ApiResponse<Welcome>> getNewsByCategory({
    required String category,
    String? country,
    int pageSize = 20,
    int page = 1,
  });

  /// Get headlines from specific sources
  /// 
  /// Parameters:
  /// - [sources]: Comma-separated string of news sources (required)
  /// - [pageSize]: Number of results to return per page (default: 20)
  /// - [page]: Page number to retrieve (default: 1)
  /// 
  /// Returns: [ApiResponse<Welcome>] containing source-specific news or error
  Future<ApiResponse<Welcome>> getNewsBySources({
    required String sources,
    int pageSize = 20,
    int page = 1,
  });

  /// Get trending news (popular articles)
  /// 
  /// Parameters:
  /// - [country]: Country code to filter by
  /// - [category]: Category to filter by
  /// - [pageSize]: Number of results to return per page (default: 20)
  /// - [page]: Page number to retrieve (default: 1)
  /// 
  /// Returns: [ApiResponse<Welcome>] containing trending news or error
  Future<ApiResponse<Welcome>> getTrendingNews({
    String? country,
    String? category,
    int pageSize = 20,
    int page = 1,
  });

  /// Search news with date range
  /// 
  /// Parameters:
  /// - [query]: Search query (required)
  /// - [fromDate]: Start date for search range (required)
  /// - [toDate]: End date for search range (required)
  /// - [language]: Language code to filter by
  /// - [sortBy]: Sort order (default: 'publishedAt')
  /// - [pageSize]: Number of results to return per page (default: 20)
  /// - [page]: Page number to retrieve (default: 1)
  /// 
  /// Returns: [ApiResponse<Welcome>] containing date-filtered news or error
  Future<ApiResponse<Welcome>> searchNewsByDateRange({
    required String query,
    required DateTime fromDate,
    required DateTime toDate,
    String? language,
    String sortBy = 'publishedAt',
    int pageSize = 20,
    int page = 1,
  });

  /// Get news from specific domains
  /// 
  /// Parameters:
  /// - [domains]: Comma-separated string of domains (required)
  /// - [query]: Optional search query
  /// - [language]: Language code to filter by
  /// - [sortBy]: Sort order (default: 'publishedAt')
  /// - [pageSize]: Number of results to return per page (default: 20)
  /// - [page]: Page number to retrieve (default: 1)
  /// 
  /// Returns: [ApiResponse<Welcome>] containing domain-specific news or error
  Future<ApiResponse<Welcome>> getNewsByDomains({
    required String domains,
    String? query,
    String? language,
    String sortBy = 'publishedAt',
    int pageSize = 20,
    int page = 1,
  });

  /// Cache management methods
  
  /// Clear all cached data
  Future<void> clearCache();

  /// Check if data is cached and still valid
  /// 
  /// Parameters:
  /// - [key]: Cache key to check
  /// 
  /// Returns: [bool] indicating if cached data exists and is valid
  Future<bool> isCacheValid(String key);

  /// Get cached data
  /// 
  /// Parameters:
  /// - [key]: Cache key to retrieve
  /// 
  /// Returns: [Welcome?] cached news data or null if not found/expired
  Future<Welcome?> getCachedData(String key);

  /// Cache news data
  /// 
  /// Parameters:
  /// - [key]: Cache key to store under
  /// - [data]: News data to cache
  /// - [duration]: How long to keep the cache (optional)
  Future<void> cacheData(String key, Welcome data, {Duration? duration});

  /// Offline support methods
  
  /// Check if device is online
  /// 
  /// Returns: [bool] indicating network connectivity status
  Future<bool> isOnline();

  /// Get offline news (cached/stored locally)
  /// 
  /// Returns: [ApiResponse<Welcome>] containing offline news or error
  Future<ApiResponse<Welcome>> getOfflineNews();

  /// Save news for offline reading
  /// 
  /// Parameters:
  /// - [articles]: List of articles to save offline
  Future<void> saveForOfflineReading(List<Article> articles);

  /// Get saved offline articles
  /// 
  /// Returns: [List<Article>] containing saved articles
  Future<List<Article>> getSavedOfflineArticles();

  /// Remove article from offline storage
  /// 
  /// Parameters:
  /// - [article]: Article to remove from offline storage
  Future<void> removeFromOfflineStorage(Article article);

  /// Dispose resources and cleanup
  void dispose();
}