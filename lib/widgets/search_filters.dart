import 'package:flutter/material.dart';

class SearchFilters extends StatelessWidget {
  final String? selectedLanguage;
  final String sortBy;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? selectedSources;
  final String? selectedDomains;
  final Function(String?) onLanguageChanged;
  final Function(String) onSortByChanged;
  final Function(DateTime?) onFromDateChanged;
  final Function(DateTime?) onToDateChanged;
  final Function(String?) onSourcesChanged;
  final Function(String?) onDomainsChanged;

  const SearchFilters({
    Key? key,
    this.selectedLanguage,
    required this.sortBy,
    this.fromDate,
    this.toDate,
    this.selectedSources,
    this.selectedDomains,
    required this.onLanguageChanged,
    required this.onSortByChanged,
    required this.onFromDateChanged,
    required this.onToDateChanged,
    required this.onSourcesChanged,
    required this.onDomainsChanged,
  }) : super(key: key);

  final Map<String, String> languages = const {
    'ar': 'Arabic',
    'de': 'German',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'he': 'Hebrew',
    'it': 'Italian',
    'nl': 'Dutch',
    'no': 'Norwegian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'sv': 'Swedish',
    'zh': 'Chinese',
  };

  final Map<String, String> sortOptions = const {
    'relevancy': 'Relevancy',
    'popularity': 'Popularity',
    'publishedAt': 'Published Date',
  };

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime?) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Search Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Language filter
          DropdownButtonFormField<String>(
            value: selectedLanguage,
            decoration: const InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Languages'),
              ),
              ...languages.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }),
            ],
            onChanged: onLanguageChanged,
          ),
          const SizedBox(height: 12),
          
          // Sort by filter
          DropdownButtonFormField<String>(
            value: sortBy,
            decoration: const InputDecoration(
              labelText: 'Sort By',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: sortOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onSortByChanged(value);
              }
            },
          ),
          const SizedBox(height: 12),
          
          // Date range
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, fromDate, onFromDateChanged),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'From Date',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          fromDate != null
                              ? '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}'
                              : 'Select date',
                          style: TextStyle(
                            color: fromDate != null ? Colors.black : Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, toDate, onToDateChanged),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'To Date',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          toDate != null
                              ? '${toDate!.day}/${toDate!.month}/${toDate!.year}'
                              : 'Select date',
                          style: TextStyle(
                            color: toDate != null ? Colors.black : Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Clear date range button
          if (fromDate != null || toDate != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  onFromDateChanged(null);
                  onToDateChanged(null);
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear Dates'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          
          // Sources filter
          TextField(
            decoration: const InputDecoration(
              labelText: 'Sources (comma-separated)',
              hintText: 'e.g., bbc-news, cnn, techcrunch',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              onSourcesChanged(value.isEmpty ? null : value);
            },
          ),
          const SizedBox(height: 12),
          
          // Domains filter
          TextField(
            decoration: const InputDecoration(
              labelText: 'Domains (comma-separated)',
              hintText: 'e.g., bbc.co.uk, techcrunch.com',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              onDomainsChanged(value.isEmpty ? null : value);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Filter info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use filters to narrow down your search results. Date range filters work best with specific queries.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuickFilters extends StatelessWidget {
  final Function(String) onQuickFilter;

  const QuickFilters({
    Key? key,
    required this.onQuickFilter,
  }) : super(key: key);

  final List<Map<String, String>> quickFilters = const [
    {'label': 'Today', 'value': 'today'},
    {'label': 'This Week', 'value': 'week'},
    {'label': 'Technology', 'value': 'technology'},
    {'label': 'Business', 'value': 'business'},
    {'label': 'Sports', 'value': 'sports'},
    {'label': 'Health', 'value': 'health'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickFilters.length,
        itemBuilder: (context, index) {
          final filter = quickFilters[index];
          return Container(
            margin: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              onSelected: (selected) {
                if (selected) {
                  onQuickFilter(filter['value']!);
                }
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }
}