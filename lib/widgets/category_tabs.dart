import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final bool isScrollable;

  const CategoryTabs({
    Key? key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    this.isScrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == selectedIndex;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: InkWell(
              onTap: () => onCategorySelected(index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final List<String> selectedCategories;
  final Function(String) onCategoryToggled;
  final bool multiSelect;

  const CategoryChips({
    Key? key,
    required this.categories,
    required this.selectedCategories,
    required this.onCategoryToggled,
    this.multiSelect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = selectedCategories.contains(category);
        
        return FilterChip(
          label: Text(category.toUpperCase()),
          selected: isSelected,
          onSelected: (selected) => onCategoryToggled(category),
          backgroundColor: Colors.grey[200],
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        );
      }).toList(),
    );
  }
}

class CategoryGrid extends StatelessWidget {
  final List<CategoryItem> categories;
  final Function(String) onCategorySelected;

  const CategoryGrid({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        
        return InkWell(
          onTap: () => onCategorySelected(category.name),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  category.color,
                  category.color.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: category.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  category.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class DefaultCategories {
  static List<CategoryItem> get items => [
    const CategoryItem(
      name: 'general',
      icon: Icons.public,
      color: Colors.blue,
    ),
    const CategoryItem(
      name: 'business',
      icon: Icons.business,
      color: Colors.green,
    ),
    const CategoryItem(
      name: 'entertainment',
      icon: Icons.movie,
      color: Colors.purple,
    ),
    const CategoryItem(
      name: 'health',
      icon: Icons.health_and_safety,
      color: Colors.red,
    ),
    const CategoryItem(
      name: 'science',
      icon: Icons.science,
      color: Colors.teal,
    ),
    const CategoryItem(
      name: 'sports',
      icon: Icons.sports,
      color: Colors.orange,
    ),
    const CategoryItem(
      name: 'technology',
      icon: Icons.computer,
      color: Colors.indigo,
    ),
  ];
}