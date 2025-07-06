import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../widgets/news_card.dart';

class NewsList extends StatelessWidget {
  final List<Article> articles;
  final ScrollController? scrollController;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool isOfflineMode;
  final bool showOfflineIndicator;
  final bool showSearchQuery;
  final String? searchQuery;
  final int? totalResults;

  const NewsList({
    Key? key,
    required this.articles,
    this.scrollController,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isOfflineMode = false,
    this.showOfflineIndicator = false,
    this.showSearchQuery = false,
    this.searchQuery,
    this.totalResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search results header
        if (showSearchQuery && searchQuery != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search results for "$searchQuery"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (totalResults != null)
                  Text(
                    '$totalResults result${totalResults == 1 ? '' : 's'} found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

        // Offline indicator
        if (showOfflineIndicator)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange[100],
            child: Row(
              children: [
                Icon(
                  Icons.offline_pin,
                  size: 16,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'Offline Mode',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Articles list
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: articles.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= articles.length) {
                // Loading more indicator
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final article = articles[index];
              return NewsCard(
                article: article,
                isOfflineMode: isOfflineMode,
              );
            },
          ),
        ),

        // Bottom loading indicator for refresh
        if (isRefreshing)
          Container(
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Refreshing...'),
              ],
            ),
          ),

        // End of list indicator
        if (hasReachedMax && articles.isNotEmpty && !isLoadingMore)
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'You\'ve reached the end',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}