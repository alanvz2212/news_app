import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? description;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.description,
    this.icon,
    this.onRetry,
    this.retryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            
            Text(
              message,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (description != null) ...[
              const SizedBox(height: 16),
              Text(
                description!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoNewsFoundWidget extends StatelessWidget {
  final String? query;
  final VoidCallback? onRetry;

  const NoNewsFoundWidget({
    Key? key,
    this.query,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: query != null 
          ? 'No articles found for "$query"'
          : 'No articles found',
      description: query != null
          ? 'Try searching with different keywords or check your spelling'
          : 'There are no articles available at the moment',
      icon: Icons.search_off,
      onRetry: onRetry,
      retryText: 'Search Again',
    );
  }
}

class NoOfflineArticlesWidget extends StatelessWidget {
  final VoidCallback? onBrowse;

  const NoOfflineArticlesWidget({
    Key? key,
    this.onBrowse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: 'No offline articles saved',
      description: 'Save articles for offline reading by tapping the bookmark icon when viewing an article',
      icon: Icons.offline_pin,
      onRetry: onBrowse,
      retryText: 'Browse Articles',
    );
  }
}

class NoSourcesFoundWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoSourcesFoundWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: 'No news sources found',
      description: 'Try adjusting your filters or check your internet connection',
      icon: Icons.source,
      onRetry: onRetry,
      retryText: 'Retry',
    );
  }
}