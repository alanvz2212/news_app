import 'package:equatable/equatable.dart';
import '../models/news_model.dart';

/// Base class for all news events
abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch top headlines
class FetchTopHeadlines extends NewsEvent {
  final String? country;
  final String? category;
  final String? sources;
  final String? query;
  final int pageSize;
  final int page;
  final bool isRefresh;

  const FetchTopHeadlines({
    this.country,
    this.category,
    this.sources,
    this.query,
    this.pageSize = 20,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
        country,
        category,
        sources,
        query,
        pageSize,
        page,
        isRefresh,
      ];
}

/// Event to search for news articles
class SearchNews extends NewsEvent {
  final String query;
  final String? searchIn;
  final String? sources;
  final String? domains;
  final String? excludeDomains;
  final DateTime? from;
  final DateTime? to;
  final String? language;
  final String sortBy;
  final int pageSize;
  final int page;
  final bool isRefresh;

  const SearchNews({
    required this.query,
    this.searchIn,
    this.sources,
    this.domains,
    this.excludeDomains,
    this.from,
    this.to,
    this.language,
    this.sortBy = 'publishedAt',
    this.pageSize = 20,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
        query,
        searchIn,
        sources,
        domains,
        excludeDomains,
        from,
        to,
        language,
        sortBy,
        pageSize,
        page,
        isRefresh,
      ];
}

/// Event to fetch news by category
class FetchNewsByCategory extends NewsEvent {
  final String category;
  final String? country;
  final int pageSize;
  final int page;
  final bool isRefresh;

  const FetchNewsByCategory({
    required this.category,
    this.country,
    this.pageSize = 20,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [category, country, pageSize, page, isRefresh];
}

/// Event to fetch news from specific sources
class FetchNewsBySources extends NewsEvent {
  final String sources;
  final int pageSize;
  final int page;
  final bool isRefresh;

  const FetchNewsBySources({
    required this.sources,
    this.pageSize = 20,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [sources, pageSize, page, isRefresh];
}

/// Event to fetch trending news
class FetchTrendingNews extends NewsEvent {
  final String? country;
  final String? category;
  final int pageSize;
  final int page;
  final bool isRefresh;

  const FetchTrendingNews({
    this.country,
    this.category,
    this.pageSize = 20,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [country, category, pageSize, page, isRefresh];
}

/// Event to fetch news sources
class FetchNewsSources extends NewsEvent {
  final String? category;
  final String? language;
  final String? country;

  const FetchNewsSources({
    this.category,
    this.language,
    this.country,
  });

  @override
  List<Object?> get props => [category, language, country];
}

/// Event to search news by date range
class SearchNewsByDateRange extends NewsEvent {
  final String query;
  final DateTime fromDate;
  final DateTime toDate;
  final String? language;
  final String sortBy;
  final int pageSize;
  final int page;
  final bool isRefresh;

  const SearchNewsByDateRange({
    required this.query,
    required this.fromDate,
    required this.toDate,
    this.language,
    this.sortBy = 'publishedAt',
    this.pageSize = 20,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
        query,
        fromDate,
        toDate,
        language,
        sortBy,
        pageSize,
        page,
        isRefresh,
      ];
}

/// Event to fetch news from specific domains
class FetchNewsByDomains extends NewsEvent {
  final String domains;
  final String? query;
  final String? language;
  final String sortBy;
  final int pageSize;
  final int page;
  final bool isRefresh;

  const FetchNewsByDomains({
    required this.domains,
    this.query,
    this.language,
    this.sortBy = 'publishedAt',
    this.pageSize = 20,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
        domains,
        query,
        language,
        sortBy,
        pageSize,
        page,
        isRefresh,
      ];
}

/// Event to load more articles (pagination)
class LoadMoreArticles extends NewsEvent {
  const LoadMoreArticles();
}

/// Event to refresh current news
class RefreshNews extends NewsEvent {
  const RefreshNews();
}

/// Event to clear news data
class ClearNews extends NewsEvent {
  const ClearNews();
}

/// Event to save article for offline reading
class SaveArticleOffline extends NewsEvent {
  final Article article;

  const SaveArticleOffline({required this.article});

  @override
  List<Object?> get props => [article];
}

/// Event to remove article from offline storage
class RemoveArticleOffline extends NewsEvent {
  final Article article;

  const RemoveArticleOffline({required this.article});

  @override
  List<Object?> get props => [article];
}

/// Event to fetch offline articles
class FetchOfflineArticles extends NewsEvent {
  const FetchOfflineArticles();
}

/// Event to check network connectivity
class CheckConnectivity extends NewsEvent {
  const CheckConnectivity();
}

/// Event to retry failed request
class RetryRequest extends NewsEvent {
  const RetryRequest();
}