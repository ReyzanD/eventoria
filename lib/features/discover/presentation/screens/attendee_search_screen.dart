import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/attendee_theme.dart';
import '../../../events/data/models/event_model.dart';
import '../../../explore/presentation/screens/event_details_screen.dart';
import '../controller/discover_controller.dart';
import '../widgets/category_chip.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/near_you_row_item.dart';

class AttendeeSearchScreen extends ConsumerStatefulWidget {
  const AttendeeSearchScreen({super.key});

  @override
  ConsumerState<AttendeeSearchScreen> createState() =>
      _AttendeeSearchScreenState();
}

class _AttendeeSearchScreenState extends ConsumerState<AttendeeSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;
  Set<String> _filterCategories = {};
  double _minPrice = 0;
  double _maxPrice = 5000000;

  static const _categoryEmojis = {
    'Conference': '💼',
    'Festival': '🎉',
    'Workshop': '🔧',
    'Concert': '🎵',
    'Exhibition': '🎨',
  };

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hour:$minutes $amPm';
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _computeStartingPrice(EventModel event) {
    if (event.ticketTiers == null || event.ticketTiers!.isEmpty) {
      return 'Free';
    }
    final minPrice =
        event.ticketTiers!.map((t) => t.price).reduce((a, b) => a < b ? a : b);
    return 'From ${_formatCurrency(minPrice)}+';
  }

  List<String> _buildCategories(List<EventModel> events) {
    final unique = events.map((e) => e.category).toSet().toList()..sort();
    return ['All', ...unique];
  }

  String _categoryLabel(String category, int index) {
    if (index == 0) return 'All';
    final emoji = _categoryEmojis[category];
    return emoji != null ? '$emoji $category' : category;
  }

  List<EventModel> _filterEvents(List<EventModel> events, List<String> categories) {
    var filtered = events;
    if (_selectedCategoryIndex != 0) {
      final selectedCat = categories[_selectedCategoryIndex];
      filtered = filtered
          .where((e) => e.category.toLowerCase() == selectedCat.toLowerCase())
          .toList();
    }
    if (_filterCategories.isNotEmpty) {
      filtered = filtered.where((e) {
        return _filterCategories
            .any((c) => e.category.toLowerCase() == c.toLowerCase());
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(query) ||
            e.venueName.toLowerCase().contains(query) ||
            (e.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    if (_minPrice > 0 || _maxPrice < 5000000) {
      filtered = filtered.where((e) {
        if (e.ticketTiers == null || e.ticketTiers!.isEmpty) {
          return _minPrice <= 0;
        }
        final minTierPrice =
            e.ticketTiers!.map((t) => t.price).reduce((a, b) => a < b ? a : b);
        return minTierPrice >= _minPrice && minTierPrice <= _maxPrice;
      }).toList();
    }
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsyncValue = ref.watch(discoverEventsProvider);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AttendeeTheme.bgColor,
      ),
      child: Scaffold(
        backgroundColor: AttendeeTheme.bgColor,
        body: eventsAsyncValue.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AttendeeTheme.electricBlue),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error: $err',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (allEvents) {
            final categories = _buildCategories(allEvents);
            final results = _filterEvents(allEvents, categories);
            final hasQuery = _searchQuery.isNotEmpty;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AttendeeTheme.bgColor,
                  elevation: 0,
                  title: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AttendeeTheme.cardColor,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          icon: const Icon(
                            Icons.search_rounded,
                            color: AttendeeTheme.electricBlue,
                          ),
                          hintText: 'Search events...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: _filterCategories.isNotEmpty ||
                                  _minPrice > 0 || _maxPrice < 5000000
                              ? AttendeeTheme.electricBlue
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                        onPressed: () async {
                          final result = await showModalBottomSheet<FilterResult>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => FilterBottomSheet(
                              availableCategories: categories
                                  .where((c) => c != 'All')
                                  .toSet(),
                              initial: FilterResult(
                                categories: _filterCategories,
                                minPrice: _minPrice,
                                maxPrice: _maxPrice,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              _filterCategories = result.categories;
                              _minPrice = result.minPrice;
                              _maxPrice = result.maxPrice;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: SizedBox(
                      height: 46,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) => CategoryChip(
                          label: _categoryLabel(categories[index], index),
                          isSelected: _selectedCategoryIndex == index,
                          onTap: () => setState(
                            () => _selectedCategoryIndex = index,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasQuery || _selectedCategoryIndex != 0)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        results.isEmpty
                            ? 'No results found'
                            : '${results.length} ${results.length == 1 ? 'result' : 'results'} found',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                if (results.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasQuery || _selectedCategoryIndex != 0
                                ? Icons.search_off_rounded
                                : Icons.event_busy_rounded,
                            size: 64,
                            color: AttendeeTheme.neonPink.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            hasQuery || _selectedCategoryIndex != 0
                                ? 'No events found'
                                : 'Browse events',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              hasQuery || _selectedCategoryIndex != 0
                                  ? 'Try a different search term or category.'
                                  : 'Use the search bar above to find events.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final ev = results[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NearYouRowItem(
                              title: ev.title,
                              imageUrl: ev.coverImageUrl,
                              date: _formatDate(ev.startDate),
                              time: _formatTime(ev.startDate),
                              location: ev.venueName,
                              category: ev.category,
                              price: _computeStartingPrice(ev),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailsScreen(event: ev),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            );
          },
        ),
      ),
    );
  }
}
