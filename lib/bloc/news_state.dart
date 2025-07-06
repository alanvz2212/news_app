import 'package:equatable/equatable.dart';
import '../models/news_model.dart';
import '../services/api_services.dart';

/// Base class for all news states
abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts
class NewsInitial extends NewsState {
  const NewsInitial();
}

/// State when news is being loaded
class NewsLoading extends NewsState {
  final bool isRefresh;
  final bool isLoadingMore;

  const NewsLoading({
    this.isRefresh = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [isRefresh, isLoadingMore];
}

/// State when news is successfully loaded
class NewsLoaded extends NewsState {
  final List<Article> articles;
  final bool hasReachedMax;
  final int currentPage;
  final int totalResults;
  final String? lastQuery;
  final String? lastCategory;
  final String? lastCountry;
  final String? lastSources;
  final DateTime lastUpdated;
  final bool isOffline;

  const NewsLoaded({
    required this.articles,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalResults = 0,
    this.lastQuery,
    this.lastCategory,
    this.lastCountry,
    this.lastSources,
    required this.lastUpdated,
    this.isOffline = false,
  });

  NewsLoaded copyWith({
    List<Article>? articles,
    bool? hasReachedMax,
    int? currentPage,
    int? totalResults,
    String? lastQuery,
    String? lastCategory,
    String? lastCountry,
    String? lastSources,
    DateTime? lastUpdated,
    bool? isOffline,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalResults: totalResults ?? this.totalResults,
      lastQuery: lastQuery ?? this.lastQuery,
      lastCategory: lastCategory ?? this.lastCategory,
      lastCountry: lastCountry ?? this.lastCountry,
      lastSources: lastSources ?? this.lastSources,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        articles,
        hasReachedMax,
        currentPage,
        totalResults,
        lastQuery,
        lastCategory,
        lastCountry,
        lastSources,
        lastUpdated,
        isOffline,
      ];
}

/// State when there's an error loading news
class NewsError extends NewsState {
  final String message;
  final String errorCode;
  final bool isNetworkError;
  final bool canRetry;
  final List<Article>? cachedArticles;

  const NewsError({
    required this.message,
    this.errorCode = 'unknown_error',
    this.isNetworkError = false,
    this.canRetry = true,
    this.cachedArticles,
  });

  @override
  List<Object?> get props => [
        message,
        errorCode,
        isNetworkError,
        canRetry,
        cachedArticles,
      ];
}

/// State when no news articles are found
class NewsEmpty extends NewsState {
  final String message;
  final String? query;

  const NewsEmpty({
    this.message = 'No articles found',
    this.query,
  });

  @override
  List<Object?> get props => [message, query];
}

/// State for news sources
class NewsSourcesState extends NewsState {
  const NewsSourcesState();
}

/// State when news sources are loading
class NewsSourcesLoading extends NewsSourcesState {
  const NewsSourcesLoading();
}

/// State when news sources are successfully loaded
class NewsSourcesLoaded extends NewsSourcesState {
  final List<NewsSource> sources;
  final DateTime lastUpdated;

  const NewsSourcesLoaded({
    required this.sources,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [sources, lastUpdated];
}

/// State when there's an error loading news sources
class NewsSourcesError extends NewsSourcesState {
  final String message;
  final String errorCode;

  const NewsSourcesError({
    required this.message,
    this.errorCode = 'unknown_error',
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// State for offline articles
class OfflineArticlesState extends NewsState {
  const OfflineArticlesState();
}

/// State when offline articles are loading
class OfflineArticlesLoading extends OfflineArticlesState {
  const OfflineArticlesLoading();
}

/// State when offline articles are successfully loaded
class OfflineArticlesLoaded extends OfflineArticlesState {
  final List<Article> articles;
  final DateTime lastUpdated;

  const OfflineArticlesLoaded({
    required this.articles,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [articles, lastUpdated];
}

/// State when there's an error loading offline articles
class OfflineArticlesError extends OfflineArticlesState {
  final String message;

  const OfflineArticlesError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when an article is saved offline
class ArticleSavedOffline extends NewsState {
  final Article article;
  final String message;

  const ArticleSavedOffline({
    required this.article,
    this.message = 'Article saved for offline reading',
  });

  @override
  List<Object?> get props => [article, message];
}

/// State when an article is removed from offline storage
class ArticleRemovedOffline extends NewsState {
  final Article article;
  final String message;

  const ArticleRemovedOffline({
    required this.article,
    this.message = 'Article removed from offline storage',
  });

  @override
  List<Object?> get props => [article, message];
}

/// State for connectivity status
class ConnectivityState extends NewsState {
  final bool isOnline;
  final DateTime lastChecked;

  const ConnectivityState({
    required this.isOnline,
    required this.lastChecked,
  });

  @override
  List<Object?> get props => [isOnline, lastChecked];
}

/// State when loading more articles (pagination)
class NewsLoadingMore extends NewsState {
  final List<Article> currentArticles;

  const NewsLoadingMore({required this.currentArticles});

  @override
  List<Object?> get props => [currentArticles];
}

/// State when refreshing news
class NewsRefreshing extends NewsState {
  final List<Article> currentArticles;

  const NewsRefreshing({required this.currentArticles});

  @override
  List<Object?> get props => [currentArticles];
}

/// State when search is in progress
class NewsSearching extends NewsState {
  final String query;
  final List<Article>? previousResults;

  const NewsSearching({
    required this.query,
    this.previousResults,
  });

  @override
  List<Object?> get props => [query, previousResults];
}

/// State when search results are loaded
class NewsSearchLoaded extends NewsState {
  final List<Article> articles;
  final String query;
  final bool hasReachedMax;
  final int currentPage;
  final int totalResults;
  final DateTime lastUpdated;

  const NewsSearchLoaded({
    required this.articles,
    required this.query,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalResults = 0,
    required this.lastUpdated,
  });

  NewsSearchLoaded copyWith({
    List<Article>? articles,
    String? query,
    bool? hasReachedMax,
    int? currentPage,
    int? totalResults,
    DateTime? lastUpdated,
  }) {
    return NewsSearchLoaded(
      articles: articles ?? this.articles,
      query: query ?? this.query,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalResults: totalResults ?? this.totalResults,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        articles,
        query,
        hasReachedMax,
        currentPage,
        totalResults,
        lastUpdated,
      ];
}

/// State when search returns no results
class NewsSearchEmpty extends NewsState {
  final String query;
  final String message;

  const NewsSearchEmpty({
    required this.query,
    this.message = 'No articles found for your search',
  });

  @override
  List<Object?> get props => [query, message];
}