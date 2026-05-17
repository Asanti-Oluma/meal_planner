import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/meal_planner_bloc.dart';
import '../models/meal.dart';
import '../widgets/error_view.dart';
import '../widgets/shimmer_grid.dart';
import 'meal_detail_screen.dart';

const _kPrimary = Color(0xFF1A1F3A);
const _kAccent = Color(0xFFF5A623);
const _kBackground = Color(0xFFF4F5F9);
const _kTextDim = Color(0xFF8A8FA8);

class BrowseMealsScreen extends StatefulWidget {
  final String? targetDay;
  final String? targetSlot;

  const BrowseMealsScreen({super.key, this.targetDay, this.targetSlot});

  @override
  State<BrowseMealsScreen> createState() => _BrowseMealsScreenState();
}

class _BrowseMealsScreenState extends State<BrowseMealsScreen> {
  final _searchController = TextEditingController();

  // TRUE = user is picking a meal for a specific slot → tap adds, no detail view
  bool get _isPicking => widget.targetDay != null && widget.targetSlot != null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addMealToPlan(BuildContext context, Meal meal) {
    context.read<MealPlannerBloc>().add(
          AddMealToPlanEvent(
            dayLabel: widget.targetDay!,
            mealTime: widget.targetSlot!,
            meal: meal,
          ),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${meal.strMeal} added to ${widget.targetDay} ${widget.targetSlot}'),
        backgroundColor: _kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MealPlannerBloc>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        title: _isPicking
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Choose a Meal',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('${widget.targetDay} · ${widget.targetSlot}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70)),
                ],
              )
            : const Text('Browse Meals',
                style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: (q) {
                if (q.trim().isNotEmpty) bloc.add(SearchMealsEvent(q.trim()));
              },
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search any dish...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: _kAccent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () {
                          _searchController.clear();
                          bloc.add(const ClearSearchEvent());
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
        ),
      ),
      body: BlocBuilder<MealPlannerBloc, MealPlannerState>(
        builder: (ctx, state) {
          final categoryRow = state.categories.isNotEmpty
              ? _buildCategoryRow(state, bloc)
              : const SizedBox.shrink();

          if (state is MealPlannerLoading) {
            return Column(
                children: [categoryRow, const Expanded(child: ShimmerGrid())]);
          }
          if (state is MealPlannerError) {
            return ErrorView(
                message: state.message,
                onRetry: () => bloc.add(const LoadCategoriesEvent()));
          }

          if (state.meals.isEmpty) {
            return Column(
              children: [
                categoryRow,
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search,
                            size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text(
                          'Search a dish or pick a category',
                          style: TextStyle(color: _kTextDim, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              categoryRow,
              if (_isPicking)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kAccent.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.touch_app_outlined, size: 18, color: _kAccent),
                      SizedBox(width: 8),
                      Text('Tap any meal to add it to your plan',
                          style: TextStyle(
                              color: _kAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: state.meals.length,
                  itemBuilder: (_, i) {
                    final meal = state.meals[i];
                    return _MealCard(
                      meal: meal,
                      isPicking: _isPicking,
                      onTap: () {
                        if (_isPicking) {
                          // adds directly, never navigates to detail
                          _addMealToPlan(context, meal);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MealDetailScreen(mealId: meal.idMeal),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryRow(MealPlannerState state, MealPlannerBloc bloc) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = state.categories[i];
          final selected = state.selectedCategory == cat.strCategory;
          return GestureDetector(
            onTap: () => bloc.add(FilterByCategoryEvent(cat.strCategory)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? _kPrimary : Colors.grey.shade300),
              ),
              child: Text(cat.strCategory,
                  style: TextStyle(
                    color: selected ? Colors.white : _kPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  )),
            ),
          );
        },
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final bool isPicking;
  final VoidCallback onTap;

  const _MealCard({
    required this.meal,
    required this.isPicking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image — takes ~62% of card height, high quality
                Expanded(
                  flex: 62,
                  child: meal.strMealThumb != null
                      ? CachedNetworkImage(
                          imageUrl: meal.strMealThumb!,
                          fit: BoxFit.cover,
                          memCacheWidth: 400,
                          memCacheHeight: 400,
                          fadeInDuration: const Duration(milliseconds: 250),
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: _kAccent),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: Icon(Icons.restaurant,
                                size: 40, color: Colors.grey.shade300),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade100,
                          child: Icon(Icons.restaurant,
                              size: 40, color: Colors.grey.shade300),
                        ),
                ),
                // Title
                Expanded(
                  flex: 38,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          meal.strMeal,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: _kPrimary),
                        ),
                        if (meal.strCategory != null) ...[
                          const SizedBox(height: 3),
                          Text(meal.strCategory!,
                              style: const TextStyle(
                                  fontSize: 11, color: _kTextDim)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Picking badge
            if (isPicking)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: _kAccent, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
