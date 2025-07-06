import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/news_model.dart';
import '../repository/news_repo.dart';
import '../services/api_services.dart';
import 'news_event.dart';
import 'news_state.dart';

/// BLoC for managing news data and state
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _newsRepository;
  
  // Keep track of current request parameters for pagination
  String? _currentQuery;
  String? _currentCategory;
  String? _currentCountry;
  String? _currentSources;
  String? _currentDomains;
  DateTime? _currentFromDate;
  DateTime? _currentToDate;
  String? _currentLanguage;
  String _currentSortBy = 'publishedAt';
  int _currentPageSize = 20;
  
  // Track the last successful event for retry functionality
  NewsEvent? _lastEvent;

  NewsBloc({required NewsRepository newsRepository})
      : _newsRepository = newsRepository,
        super(const NewsInitial()) {
    
    // Register event handlers
    on<FetchTopHeadlines>(_onFetchTopHeadlines);
    on<SearchNews>(_onSearchNews);
    on<FetchNewsByCategory>(_onFetchNewsByCategory);
    on<FetchNewsBySources>(_onFetchNewsBySources);
    on<FetchTrendingNews>(_onFetchTrendingNews);
    on<FetchNewsSources>(_onFetchNewsSources);
    on<SearchNewsByDateRange>(_onSearchNewsByDateRange);
    on<FetchNewsByDomains>(_onFetchNewsByDomains);
    on<LoadMoreArticles>(_onLoadMoreArticles);
    on<RefreshNews>(_onRefreshNews);
    on<ClearNews>(_onClearNews);
    on<SaveArticleOffline>(_onSaveArticleOffline);
    on<RemoveArticleOffline>(_onRemoveArticleOffline);
    on<FetchOfflineArticles>(_onFetchOfflineArticles);
    on<CheckConnectivity>(_onCheckConnectivity);
    on<RetryRequest>(_onRetryRequest);
  }

  /// Handle fetching top headlines
  Future<void> _onFetchTopHeadlines(
    FetchTopHeadlines event,
    Emitter<NewsState> emit,
  ) async {
    try {
      _lastEvent = event;
      
      if (event.isRefresh && state is NewsLoaded) {
        emit(NewsRefreshing(currentArticles: (state as NewsLoaded).articles));
      } else {
        emit(const NewsLoading());
      }

      // Update current parameters
      _currentQuery = event.query;
      _currentCategory = event.category;
      _currentCountry = event.country;
      _currentSources = event.sources;
      _currentPageSize = event.pageSize;

      final response = await _newsRepository.getTopHeadlines(
        country: event.country,
        category: event.category,
        sources: event.sources,
        q: event.query,
        pageSize: event.pageSize,
        page: event.page,
      );

      if (response.isSuccess && response.data != null) {
        final articles = response.data!.articles ?? [];
        
        if (articles.isEmpty) {
          emit(NewsEmpty(
            message: 'No headlines found',
            query: event.query,
          ));
        } else {
          emit(NewsLoaded(
            articles: articles,
            currentPage: event.page,
            totalResults: response.data!.totalResults ?? 0,
            lastQuery: event.query,
            lastCategory: event.category,
            lastCountry: event.country,
            lastSources: event.sources,
            lastUpdated: DateTime.now(),
            hasReachedMax: articles.length < event.pageSize,
          ));
        }
      } else {
        emit(NewsError(
          message: response.error?.message ?? 'Failed to fetch headlines',
          errorCode: response.error?.code ?? 'unknown_error',
          isNetworkError: response.error?.code == 'network_error',
        ));
      }
    } catch (e) {
      emit(NewsError(
        message: 'An unexpected error occurred: $e',
        errorCode: 'unexpected_error',
      ));
    }
  }

  /// Handle searching news
  Future<void> _onSearchNews(
    SearchNews event,
    Emitter<NewsState> emit,
  ) async {
    try {
      _lastEvent = event;
      
      if (event.isRefresh && state is NewsSearchLoaded) {
        emit(NewsSearching(
          query: event.query,
          previousResults: (state as NewsSearchLoaded).articles,
        ));
      } else {
        emit(NewsSearching(query: event.query));
      }

      // Update current parameters
      _currentQuery = event.query;
      _currentSources = event.sources;
      _currentDomains = event.domains;
      _currentFromDate = event.from;
      _currentToDate = event.to;
      _currentLanguage = event.language;
      _currentSortBy = event.sortBy;
      _currentPageSize = event.pageSize;

      final response = await _newsRepository.searchNews(
        q: event.query,
        searchIn: event.searchIn,
        sources: event.sources,
        domains: event.domains,
        excludeDomains: event.excludeDomains,
        from: event.from,
        to: event.to,
        language: event.language,
        sortBy: event.sortBy,
        pageSize: event.pageSize,
        page: event.page,
      );

      if (response.isSuccess && response.data != null) {
        final articles = response.data!.articles ?? [];
        
        if (articles.isEmpty) {
          emit(NewsSearchEmpty(
            query: event.query,
            message: 'No articles found for "${event.query}"',
          ));
        } else {
          emit(NewsSearchLoaded(
            articles: articles,
            query: event.query,
            currentPage: event.page,
            totalResults: response.data!.totalResults ?? 0,
            lastUpdated: DateTime.now(),
            hasReachedMax: articles.length < event.pageSize,
          ));
        }
      } else {
        emit(NewsError(
          message: response.error?.message ?? 'Failed to search news',
          errorCode: response.error?.code ?? 'unknown_error',
          isNetworkError: response.error?.code == 'network_error',
        ));
      }
    } catch (e) {
      emit(NewsError(
        message: 'An unexpected error occurred: $e',
        errorCode: 'unexpected_error',
      ));
    }
  }

  /// Handle fetching news by category
  Future<void> _onFetchNewsByCategory(
    FetchNewsByCategory event,
    Emitter<NewsState> emit,
  ) async {
    try {
      _lastEvent = event;
      
      if (event.isRefresh && state is NewsLoaded) {
        emit(NewsRefreshing(currentArticles: (state as NewsLoaded).articles));
      } else {
        emit(const NewsLoading());
      }

      _currentCategory = event.category;
      _currentCountry = event.country;
      _currentPageSize = event.pageSize;

      final response = await _newsRepository.getNewsByCategory(
        category: event.category,
        country: event.country,
        pageSize: event.pageSize,
        page: event.page,
      );

      if (response.isSuccess && response.data != null) {
        final articles = response.data!.articles ?? [];
        
        if (articles.isEmpty) {
          emit(NewsEmpty(
            message: 'No articles found in ${event.category} category',
          ));
        } else {
          emit(NewsLoaded(
            articles: articles,
            currentPage: event.page,
            totalResults: response.data!.totalResults ?? 0,
            lastCategory: event.category,
            lastCountry: event.country,
            lastUpdated: DateTime.now(),
            hasReachedMax: articles.length < event.pageSize,
          ));
        }
      } else {
        emit(NewsError(
          message: response.error?.message ?? 'Failed to fetch category news',
          errorCode: response.error?.code ?? 'unknown_error',
          isNetworkError: response.error?.code == 'network_error',
        ));
      }
    } catch (e) {
      emit(NewsError(
        message: 'An unexpected error occurred: $e',
        errorCode: 'unexpected_error',
      ));
    }
  }

  /// Handle fetching news by sources
  Future<void> _onFetchNewsBySources(
    FetchNewsBySources event,
    Emitter<NewsState> emit,
  ) async {
    try {
      _lastEvent = event;
      
      if (event.isRefresh && state is NewsLoaded) {
        emit(NewsRefreshing(currentArticles: (state as NewsLoaded).articles));
      } else {
        emit(const NewsLoading());
      }

      _currentSources = event.sources;
      _currentPageSize = event.pageSize;

      final response = await _newsRepository.getNewsBySources(
        sources: event.sources,
        pageSize: event.pageSize,
        page: event.page,
      );

      if (response.isSuccess && response.data != null) {
        final articles = response.data!.articles ?? [];
        
        if (articles.isEmpty) {
          emit(const NewsEmpty(
            message: 'No articles found from selected sources',
          ));
        } else {
          emit(NewsLoaded(
            articles: articles,
            currentPage: event.page,
            totalResults: response.data!.totalResults ?? 0,
            lastSources: event.sources,
            lastUpdated: DateTime.now(),
            hasReachedMax: articles.length < event.pageSize,
          ));
        }
      } else {
        emit(NewsError(
          message: response.error?.message ?? 'Failed to fetch source news',
          errorCode: response.error?.code ?? 'unknown_error',
          isNetworkError: response.error?.code == 'network_error',
        ));
      }
    } catch (e) {
      emit(NewsError(
        message: 'An unexpected error occurred: $e',
        errorCode: 'unexpected_error',
      ));
    }
  }

  /// Handle fetching trending news
  Future<void> _onFetchTrendingNews(
    FetchTrendingNews event,
    Emitter<NewsState> emit,
  ) async {
    try {
      _lastEvent = event;
      
      if (event.isRefresh && state is NewsLoaded) {
        emit(NewsRefreshing(currentArticles: (state as NewsLoaded).articles));
      } else {
        emit(const NewsLoading());
      }

      _currentCountry = event.country;
      _currentCategory = event.category;
      _currentPageSize = event.pageSize;

      final response = await _newsRepository.getTrendingNews(
        country: event.country,
        category: event.category,
        pageSize: event.pageSize,
        page: event.page,
      );

      if (response.isSuccess && response.data != null) {
        final articles = response.data!.articles ?? [];
        
        if (articles.isEmpty) {
          emit(const NewsEmpty(
            message: 'No trending articles found',
          ));
        } else {
          emit(NewsLoaded(
            articles: articles,
            currentPage: event.page,
            totalResults: response.data!.totalResults ?? 0,
            lastCountry: event.country,
            lastCategory: event.category,
            lastUpdated: DateTime.now(),
            hasReachedMax: articles.length < event.pageSize,
          ));
        }
      } else {
        emit(NewsError(
          message: response.error?.message ?? 'Failed to fetch trending news',
          errorCode: response.error?.code ?? 'unknown_error',
          isNetworkError: response.error?.code == 'network_error',
        ));
      }
    } catch (e) {
      emit(NewsError(
        message: 'An unexpected error occurred: $e',
        errorCode: 'unexpected_error',
      ));
    }
  }

  /// Handle fetching news sources
  Future<void> _onFetchNewsSources(
    FetchNewsSources event,
    Emitter<NewsState> emit,
  ) async {
    try {
      emit(const NewsSourcesLoading());

      final response = await _newsRepository.getNewsSources(
        category: event.category,
        language: event.language,
        country: event.country,
      );

      if (response.isSuccess && response.data != null) {
        final sources = response.data!.sources ?? [];
        
        emit(NewsSourcesLoaded(
          sources: sources,
          lastUpdated: DateTime.now(),
        ));
      } else {
        emit(NewsSourcesError(
          message: response.error?.message ?? 'Failed to fetch news sources',
          errorCode: response.error?.code ?? 'unknown_error',
        ));
      }
    } catch (e) {
      emit(NewsSourcesError(
        message: 'An unexpected error occurred: $e',
        errorCode: 'unexpected_error',
      ));
    }
  }

  /// Handle searching news by date range
  Future<void> _onSearchNewsByDateRange(
    SearchNewsByDateRange event,
    Emitter<NewsState> emit,
  ) async {
    try {
      _lastEvent = event;
      
      emit(NewsSearching(query: event.query));

      _currentQuery = event.query;
      _currentFromDate = event.fromDate;
      _currentToDate = event.toDate;
      _currentLanguage = event.language;
      _currentSortBy = event.sortBy;
      _currentPageSize = event.pageSize;

      final response = await _newsRepository.searchNewsByDateRange(
        query: event.query,
        fromDate: event.fromDate,
        toDate: event.toDate,
        language: event.language,
        sortBy: event.sortBy,
        pageSize: event.pageSize,
        page: event.page,
      );

      if (response.isSuccess && response.data != null) {
        final articles = response.data!.articles ?? [];
        
        if (articles.isEmpty) {
          emit(NewsSearchEmpty(
            query: event.query,
            message: 'No articles found in the specified date range',
          ));
        } else {
          emit(NewsSearchLoaded(
            articles: articles,
            query: event.query,
            currentPage: event.page,
            totalResults: response.data!.totalResults ?? 0,
            lastUpdated: DateTime.now(),
            hasReachedMax: articles.length < event.pageSize,
          ));
        }
      } else {
        emit(NewsError(
          message: response.error?.message ?? 'Failed to search news by date range',
          errorCode: response.error?.code ?? 'unknown_error',
          isNetworkError: response.error?.code == 'network_error',
        ));
      }
    } catch (e) {
      emit(NewsError(
        message: 'An unexpected error occurred: $e',
        errorCode: 'unexpected_error',
      ));
    }
  }

  /// Handle fetching news by domains
  Future<void> _onFetchNewsByDomains(
    FetchNewsByDomains event,
    Emitter<NewsState> emit,
  ) async {
    try {
      _lastEvent = event;
      
      if (event.isRefresh && state is NewsLoaded) {
        emit(NewsRefreshing(currentArticles: (state as NewsLoaded).articles));
      } else {
        emit(const NewsLoading());
      }

      _currentDomains = event.domains;
      _currentQuery = event.query;
      _currentLanguage = event.language;
      _currentSortBy = event.sortBy;
      _currentPageSize = event.pageSize;

      final response = await _newsRepository.getNewsByDomains(
        domains: event.domains,
        query: event.query,
        language: event.language,
        sortBy: event.sortBy,
        pageSize: event.pageSize,
        page: event.page,
      );

      if (response.isSuccess && response.data != null) {
        final articles = response.data!.articles ?? [];
        
        if (articles.isEmpty) {
          emit(const NewsEmpty(
            message: 'No articles found from specified domains',
          ));
        } else {
          emit(NewsLoaded(
            articles: articles,
            currentPage: event.page,
            totalResults: response.data!.totalResults ?? 0,
            lastQuery: event.query,
            lastUpdated: DateTime.now(),
            hasReachedMax: articles.length < event.pageSize,
          ));
        }
      } else {
        emit(NewsError(
          message: response.error?.message ?? 'Failed to fetch domain news',
          errorCode: response.error?.code ?? 'unknown_error',
          isNetworkError: response.error?.code == 'network_error',
        ));
      }
    } catch (e) {
      emit(NewsError(
        message: 'An unexpected error occurred: $e',
        errorCode: 'unexpected_error',
      ));
    }
  }

  /// Handle loading more articles (pagination)
  Future<void> _onLoadMoreArticles(
    LoadMoreArticles event,
    Emitter<NewsState> emit,
  ) async {
    if (state is NewsLoaded) {
      final currentState = state as NewsLoaded;
      
      if (currentState.hasReachedMax) return;

      emit(NewsLoadingMore(currentArticles: currentState.articles));

      try {
        ApiResponse<Welcome>? response;
        final nextPage = currentState.currentPage + 1;

        // Determine which API call to make based on current parameters
        if (_currentQuery != null && _currentFromDate != null && _currentToDate != null) {
          // Date range search
          response = await _newsRepository.searchNewsByDateRange(
            query: _currentQuery!,
            fromDate: _currentFromDate!,
            toDate: _currentToDate!,
            language: _currentLanguage,
            sortBy: _currentSortBy,
            pageSize: _currentPageSize,
            page: nextPage,
          );
        } else if (_currentQuery != null) {
          // General search
          response = await _newsRepository.searchNews(
            q: _currentQuery!,
            sources: _currentSources,
            domains: _currentDomains,
            language: _currentLanguage,
            sortBy: _currentSortBy,
            pageSize: _currentPageSize,
            page: nextPage,
          );
        } else if (_currentSources != null) {
          // Sources-based fetch
          response = await _newsRepository.getNewsBySources(
            sources: _currentSources!,
            pageSize: _currentPageSize,
            page: nextPage,
          );
        } else if (_currentCategory != null) {
          // Category-based fetch
          response = await _newsRepository.getNewsByCategory(
            category: _currentCategory!,
            country: _currentCountry,
            pageSize: _currentPageSize,
            page: nextPage,
          );
        } else {
          // Top headlines
          response = await _newsRepository.getTopHeadlines(
            country: _currentCountry,
            category: _currentCategory,
            sources: _currentSources,
            pageSize: _currentPageSize,
            page: nextPage,
          );
        }

        if (response != null && response.isSuccess && response.data != null) {
          final newArticles = response.data!.articles ?? [];
          final allArticles = [...currentState.articles, ...newArticles];

          emit(currentState.copyWith(
            articles: allArticles,
            currentPage: nextPage,
            hasReachedMax: newArticles.length < _currentPageSize,
            lastUpdated: DateTime.now(),
          ));
        } else {
          emit(NewsError(
            message: response?.error?.message ?? 'Failed to load more articles',
            errorCode: response?.error?.code ?? 'unknown_error',
            cachedArticles: currentState.articles,
          ));
        }
      } catch (e) {
        emit(NewsError(
          message: 'An unexpected error occurred: $e',
          errorCode: 'unexpected_error',
          cachedArticles: currentState.articles,
        ));
      }
    }
  }

  /// Handle refreshing news
  Future<void> _onRefreshNews(
    RefreshNews event,
    Emitter<NewsState> emit,
  ) async {
    if (_lastEvent != null) {
      // Create a refresh version of the last event
      NewsEvent refreshEvent;
      
      if (_lastEvent is FetchTopHeadlines) {
        final lastEvent = _lastEvent as FetchTopHeadlines;
        refreshEvent = FetchTopHeadlines(
          country: lastEvent.country,
          category: lastEvent.category,
          sources: lastEvent.sources,
          query: lastEvent.query,
          pageSize: lastEvent.pageSize,
          page: 1,
          isRefresh: true,
        );
      } else if (_lastEvent is SearchNews) {
        final lastEvent = _lastEvent as SearchNews;
        refreshEvent = SearchNews(
          query: lastEvent.query,
          searchIn: lastEvent.searchIn,
          sources: lastEvent.sources,
          domains: lastEvent.domains,
          excludeDomains: lastEvent.excludeDomains,
          from: lastEvent.from,
          to: lastEvent.to,
          language: lastEvent.language,
          sortBy: lastEvent.sortBy,
          pageSize: lastEvent.pageSize,
          page: 1,
          isRefresh: true,
        );
      } else if (_lastEvent is FetchNewsByCategory) {
        final lastEvent = _lastEvent as FetchNewsByCategory;
        refreshEvent = FetchNewsByCategory(
          category: lastEvent.category,
          country: lastEvent.country,
          pageSize: lastEvent.pageSize,
          page: 1,
          isRefresh: true,
        );
      } else {
        // Default to top headlines
        refreshEvent = const FetchTopHeadlines(isRefresh: true);
      }
      
      add(refreshEvent);
    } else {
      // No previous event, fetch top headlines
      add(const FetchTopHeadlines(isRefresh: true));
    }
  }

  /// Handle clearing news
  Future<void> _onClearNews(
    ClearNews event,
    Emitter<NewsState> emit,
  ) async {
    emit(const NewsInitial());
    _lastEvent = null;
    _clearCurrentParameters();
  }

  /// Handle saving article offline
  Future<void> _onSaveArticleOffline(
    SaveArticleOffline event,
    Emitter<NewsState> emit,
  ) async {
    try {
      await _newsRepository.saveForOfflineReading([event.article]);
      emit(ArticleSavedOffline(article: event.article));
    } catch (e) {
      emit(NewsError(
        message: 'Failed to save article offline: $e',
        errorCode: 'save_offline_error',
      ));
    }
  }

  /// Handle removing article from offline storage
  Future<void> _onRemoveArticleOffline(
    RemoveArticleOffline event,
    Emitter<NewsState> emit,
  ) async {
    try {
      await _newsRepository.removeFromOfflineStorage(event.article);
      emit(ArticleRemovedOffline(article: event.article));
    } catch (e) {
      emit(NewsError(
        message: 'Failed to remove article from offline storage: $e',
        errorCode: 'remove_offline_error',
      ));
    }
  }

  /// Handle fetching offline articles
  Future<void> _onFetchOfflineArticles(
    FetchOfflineArticles event,
    Emitter<NewsState> emit,
  ) async {
    try {
      emit(const OfflineArticlesLoading());
      
      final articles = await _newsRepository.getSavedOfflineArticles();
      
      emit(OfflineArticlesLoaded(
        articles: articles,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(OfflineArticlesError(
        message: 'Failed to fetch offline articles: $e',
      ));
    }
  }

  /// Handle checking connectivity
  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<NewsState> emit,
  ) async {
    try {
      final isOnline = await _newsRepository.isOnline();
      emit(ConnectivityState(
        isOnline: isOnline,
        lastChecked: DateTime.now(),
      ));
    } catch (e) {
      emit(ConnectivityState(
        isOnline: false,
        lastChecked: DateTime.now(),
      ));
    }
  }

  /// Handle retrying failed request
  Future<void> _onRetryRequest(
    RetryRequest event,
    Emitter<NewsState> emit,
  ) async {
    if (_lastEvent != null) {
      add(_lastEvent!);
    } else {
      add(const FetchTopHeadlines());
    }
  }

  /// Clear current parameters
  void _clearCurrentParameters() {
    _currentQuery = null;
    _currentCategory = null;
    _currentCountry = null;
    _currentSources = null;
    _currentDomains = null;
    _currentFromDate = null;
    _currentToDate = null;
    _currentLanguage = null;
    _currentSortBy = 'publishedAt';
    _currentPageSize = 20;
  }

  @override
  Future<void> close() {
    _newsRepository.dispose();
    return super.close();
  }
}