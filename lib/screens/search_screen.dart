import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../widgets/news_list.dart';
import '../widgets/search_filters.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  
  bool _showFilters = false;
  String? _selectedLanguage;
  String _sortBy = 'publishedAt';
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedSources;
  String? _selectedDomains;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NewsBloc>().add(const LoadMoreArticles());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    if (_fromDate != null && _toDate != null) {
      context.read<NewsBloc>().add(
        SearchNewsByDateRange(
          query: query,
          fromDate: _fromDate!,
          toDate: _toDate!,
          language: _selectedLanguage,
          sortBy: _sortBy,
        ),
      );
    } else {
      context.read<NewsBloc>().add(
        SearchNews(
          query: query,
          language: _selectedLanguage,
          sortBy: _sortBy,
          sources: _selectedSources,
          domains: _selectedDomains,
        ),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<NewsBloc>().add(const ClearNews());
  }

  void _clearFilters() {
    setState(() {
      _selectedLanguage = null;
      _sortBy = 'publishedAt';
      _fromDate = null;
      _toDate = null;
      _selectedSources = null;
      _selectedDomains = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search News'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          if (_hasActiveFilters())
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search input
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search news...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (_) => _performSearch(),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchController.text.trim().isNotEmpty
                      ? _performSearch
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),

          // Search filters
          if (_showFilters)
            SearchFilters(
              selectedLanguage: _selectedLanguage,
              sortBy: _sortBy,
              fromDate: _fromDate,
              toDate: _toDate,
              selectedSources: _selectedSources,
              selectedDomains: _selectedDomains,
              onLanguageChanged: (language) {
                setState(() {
                  _selectedLanguage = language;
                });
              },
              onSortByChanged: (sortBy) {
                setState(() {
                  _sortBy = sortBy;
                });
              },
              onFromDateChanged: (date) {
                setState(() {
                  _fromDate = date;
                });
              },
              onToDateChanged: (date) {
                setState(() {
                  _toDate = date;
                });
              },
              onSourcesChanged: (sources) {
                setState(() {
                  _selectedSources = sources;
                });
              },
              onDomainsChanged: (domains) {
                setState(() {
                  _selectedDomains = domains;
                });
              },
            ),

          // Search results
          Expanded(
            child: BlocBuilder<NewsBloc, NewsState>(
              builder: (context, state) {
                if (state is NewsInitial) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Search for news articles',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Enter keywords to find relevant news',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is NewsSearching) {
                  return Column(
                    children: [
                      const LoadingWidget(),
                      if (state.previousResults != null)
                        Expanded(
                          child: Opacity(
                            opacity: 0.5,
                            child: NewsList(
                              articles: state.previousResults!,
                              scrollController: _scrollController,
                              hasReachedMax: true,
                            ),
                          ),
                        ),
                    ],
                  );
                } else if (state is NewsSearchLoaded) {
                  return NewsList(
                    articles: state.articles,
                    scrollController: _scrollController,
                    hasReachedMax: state.hasReachedMax,
                    showSearchQuery: true,
                    searchQuery: state.query,
                    totalResults: state.totalResults,
                  );
                } else if (state is NewsLoadingMore) {
                  return NewsList(
                    articles: state.currentArticles,
                    scrollController: _scrollController,
                    hasReachedMax: false,
                    isLoadingMore: true,
                  );
                } else if (state is NewsSearchEmpty) {
                  return EmptyStateWidget(
                    message: state.message,
                    icon: Icons.search_off,
                    onRetry: _performSearch,
                    retryText: 'Search Again',
                  );
                } else if (state is NewsError) {
                  return NewsErrorWidget(
                    message: state.message,
                    isNetworkError: state.isNetworkError,
                    canRetry: state.canRetry,
                    onRetry: () {
                      context.read<NewsBloc>().add(const RetryRequest());
                    },
                    cachedArticles: state.cachedArticles,
                  );
                }

                return const LoadingWidget();
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedLanguage != null ||
        _sortBy != 'publishedAt' ||
        _fromDate != null ||
        _toDate != null ||
        _selectedSources != null ||
        _selectedDomains != null;
  }
}