import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Mock data for demonstration
  final List<FoodHistoryItem> _historyItems = [
    FoodHistoryItem(
      id: '1',
      foodName: 'Margherita Pizza',
      cuisine: 'Italian',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      confidence: 'High',
      imagePath: '', // Would contain actual image path
    ),
    FoodHistoryItem(
      id: '2',
      foodName: 'Chicken Biryani',
      cuisine: 'Indian',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      confidence: 'High',
      imagePath: '',
    ),
    FoodHistoryItem(
      id: '3',
      foodName: 'Caesar Salad',
      cuisine: 'American',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      confidence: 'Medium',
      imagePath: '',
    ),
    FoodHistoryItem(
      id: '4',
      foodName: 'Ramen Bowl',
      cuisine: 'Japanese',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      confidence: 'High',
      imagePath: '',
    ),
    FoodHistoryItem(
      id: '5',
      foodName: 'Tacos al Pastor',
      cuisine: 'Mexican',
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      confidence: 'Medium',
      imagePath: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterChips(),
              Expanded(
                child:
                    _historyItems.isEmpty
                        ? _buildEmptyState()
                        : _buildHistoryList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Food History',
                        style: AppTheme.headingLarge.copyWith(fontSize: 28),
                      ),
                    ),
                    Text(
                      '${_historyItems.length} dishes identified',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              onPressed: _clearHistory,
              icon: Icons.delete_outline_rounded,
              label: 'Clear',
              isPrimary: false,
              size: CustomButtonSize.small,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Today', 'This Week', 'This Month'];

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  filters.map((filter) {
                    final isSelected = filter == 'All';
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          // TODO: Implement filter logic
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                        labelStyle: AppTheme.bodySmall.copyWith(
                          color:
                              isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideX(begin: -0.3, end: 0);
  }

  Widget _buildHistoryList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 100,
        ),
        itemCount: _historyItems.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildHistoryCard(_historyItems[index], index),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(FoodHistoryItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _showItemDetails(item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Food Image Placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Food Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.foodName,
                        style: AppTheme.headingSmall.copyWith(fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Cuisine Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.secondaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          item.cuisine,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Date and Confidence
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _formatDateTime(item.dateTime),
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(
                                item.confidence,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.confidence,
                              style: AppTheme.bodySmall.copyWith(
                                color: _getConfidenceColor(item.confidence),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Button
                IconButton(
                  onPressed: () => _showItemOptions(item),
                  icon: const Icon(Icons.more_vert),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Food History',
            style: AppTheme.headingMedium.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Text(
            'Start identifying food to see your history here',
            style: AppTheme.bodyMedium.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomButton(
            onPressed: () {
              // Navigate to camera screen
            },
            icon: Icons.camera_alt_rounded,
            label: 'Start Scanning',
            isPrimary: true,
            size: CustomButtonSize.large,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms, duration: 600.ms);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Color _getConfidenceColor(String confidence) {
    switch (confidence.toLowerCase()) {
      case 'high':
        return AppTheme.successColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'low':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  void _showItemDetails(FoodHistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailSheet(item),
    );
  }

  Widget _buildDetailSheet(FoodHistoryItem item) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.foodName, style: AppTheme.headingMedium),
                      Text(
                        item.cuisine,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details
            _buildDetailRow('Identified', _formatDateTime(item.dateTime)),
            _buildDetailRow('Confidence', item.confidence),
            _buildDetailRow('Cuisine Type', item.cuisine),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Share functionality
                    },
                    icon: Icons.share_rounded,
                    label: 'Share',
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteItem(item);
                    },
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTheme.bodyMedium)),
        ],
      ),
    );
  }

  void _showItemOptions(FoodHistoryItem item) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Share'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Share functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteItem(item);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear History'),
            content: const Text(
              'Are you sure you want to clear all food history?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _historyItems.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  void _deleteItem(FoodHistoryItem item) {
    setState(() {
      _historyItems.removeWhere((element) => element.id == item.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.foodName} deleted from history'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _historyItems.add(item);
            });
          },
        ),
      ),
    );
  }
}

class FoodHistoryItem {
  final String id;
  final String foodName;
  final String cuisine;
  final DateTime dateTime;
  final String confidence;
  final String imagePath;

  FoodHistoryItem({
    required this.id,
    required this.foodName,
    required this.cuisine,
    required this.dateTime,
    required this.confidence,
    required this.imagePath,
  });
}
