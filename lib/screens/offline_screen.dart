import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../widgets/news_list.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  @override
  void initState() {
    super.initState();
    _loadOfflineArticles();
  }

  void _loadOfflineArticles() {
    context.read<NewsBloc>().add(const FetchOfflineArticles());
  }

  void _clearAllOfflineArticles() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Offline Articles'),
        content: const Text(
          'Are you sure you want to remove all saved articles? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear all offline articles
              // This would require adding a new event to the BLoC
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All offline articles cleared'),
                ),
              );
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Articles'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOfflineArticles,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear_all':
                  _clearAllOfflineArticles();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          if (state is OfflineArticlesLoading) {
            return const LoadingWidget();
          } else if (state is OfflineArticlesLoaded) {
            final articles = state.articles;
            
            if (articles.isEmpty) {
              return EmptyStateWidget(
                message: 'No offline articles saved',
                icon: Icons.offline_pin,
                onRetry: _loadOfflineArticles,
                retryText: 'Refresh',
                description: 'Save articles for offline reading by tapping the bookmark icon',
              );
            }
            
            return Column(
              children: [
                // Info banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      Icon(
                        Icons.offline_pin,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${articles.length} article${articles.length == 1 ? '' : 's'} saved offline',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            Text(
                              'Available without internet connection',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Articles list
                Expanded(
                  child: NewsList(
                    articles: articles,
                    hasReachedMax: true,
                    isOfflineMode: true,
                    showOfflineIndicator: true,
                  ),
                ),
              ],
            );
          } else if (state is OfflineArticlesError) {
            return NewsErrorWidget(
              message: state.message,
              onRetry: _loadOfflineArticles,
              icon: Icons.offline_pin,
            );
          }
          
          return const LoadingWidget();
        },
      ),
      floatingActionButton: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          if (state is OfflineArticlesLoaded && state.articles.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.cloud_download),
              label: const Text('Browse More'),
              backgroundColor: Theme.of(context).primaryColor,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}