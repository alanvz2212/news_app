import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../widgets/news_list.dart';
import '../widgets/category_tabs.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import 'search_screen.dart';
import 'sources_screen.dart';
import 'offline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  final List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Load initial news
    context.read<NewsBloc>().add(const FetchTopHeadlines());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
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

  void _onCategoryChanged(int index) {
    final category = categories[index];
    context.read<NewsBloc>().add(
      FetchNewsByCategory(category: category),
    );
  }

  void _onRefresh() {
    context.read<NewsBloc>().add(const RefreshNews());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'sources':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SourcesScreen(),
                    ),
                  );
                  break;
                case 'offline':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OfflineScreen(),
                    ),
                  );
                  break;
                case 'refresh':
                  _onRefresh();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sources',
                child: Row(
                  children: [
                    Icon(Icons.source),
                    SizedBox(width: 8),
                    Text('News Sources'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'offline',
                child: Row(
                  children: [
                    Icon(Icons.offline_pin),
                    SizedBox(width: 8),
                    Text('Offline Articles'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: _onCategoryChanged,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: categories.map((category) {
            return Tab(
              text: category.toUpperCase(),
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            ),
          ),
          
          // News content
          Expanded(
            child: BlocBuilder<NewsBloc, NewsState>(
              builder: (context, state) {
                if (state is NewsInitial || state is NewsLoading) {
                  return const LoadingWidget();
                } else if (state is NewsLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: NewsList(
                      articles: state.articles,
                      scrollController: _scrollController,
                      hasReachedMax: state.hasReachedMax,
                    ),
                  );
                } else if (state is NewsLoadingMore) {
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: NewsList(
                      articles: state.currentArticles,
                      scrollController: _scrollController,
                      hasReachedMax: false,
                      isLoadingMore: true,
                    ),
                  );
                } else if (state is NewsRefreshing) {
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: NewsList(
                      articles: state.currentArticles,
                      scrollController: _scrollController,
                      hasReachedMax: false,
                      isRefreshing: true,
                    ),
                  );
                } else if (state is NewsEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: EmptyStateWidget(
                      message: state.message,
                      onRetry: _onRefresh,
                    ),
                  );
                } else if (state is NewsError) {
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: NewsErrorWidget(
                      message: state.message,
                      isNetworkError: state.isNetworkError,
                      canRetry: state.canRetry,
                      onRetry: () {
                        context.read<NewsBloc>().add(const RetryRequest());
                      },
                      cachedArticles: state.cachedArticles,
                    ),
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
}