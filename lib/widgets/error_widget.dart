import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../widgets/news_list.dart';

class NewsErrorWidget extends StatelessWidget {
  final String message;
  final String? errorCode;
  final bool isNetworkError;
  final bool canRetry;
  final VoidCallback? onRetry;
  final List<Article>? cachedArticles;
  final IconData? icon;

  const NewsErrorWidget({
    Key? key,
    required this.message,
    this.errorCode,
    this.isNetworkError = false,
    this.canRetry = true,
    this.onRetry,
    this.cachedArticles,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If we have cached articles, show them with error banner
    if (cachedArticles != null && cachedArticles!.isNotEmpty) {
      return Column(
        children: [
          // Error banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red[50],
            child: Row(
              children: [
                Icon(
                  isNetworkError ? Icons.wifi_off : Icons.error_outline,
                  color: Colors.red[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isNetworkError ? 'No internet connection' : 'Error loading news',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      Text(
                        'Showing cached articles',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (canRetry && onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ),
          
          // Cached articles
          Expanded(
            child: NewsList(
              articles: cachedArticles!,
              hasReachedMax: true,
              showOfflineIndicator: true,
            ),
          ),
        ],
      );
    }

    // Full error screen
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? (isNetworkError ? Icons.wifi_off : Icons.error_outline),
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            
            Text(
              isNetworkError ? 'No Internet Connection' : 'Something went wrong',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            if (canRetry && onRetry != null) ...[
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            if (isNetworkError) ...[
              Text(
                'Please check your internet connection and try again',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ] else if (errorCode != null) ...[
              Text(
                'Error code: $errorCode',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NewsErrorWidget(
      message: 'Please check your internet connection and try again.',
      isNetworkError: true,
      onRetry: onRetry,
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NewsErrorWidget(
      message: 'Our servers are experiencing issues. Please try again later.',
      errorCode: 'server_error',
      onRetry: onRetry,
    );
  }
}