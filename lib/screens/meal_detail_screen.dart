import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/meal_planner_bloc.dart';
import '../widgets/error_view.dart';

const _kPrimary = Color(0xFF1A1F3A);
const _kAccent = Color(0xFFF5A623);
//const _kTextDim  = Color(0xFF8A8FA8);
const _kBg = Color(0xFFF4F5F9);

class MealDetailScreen extends StatefulWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MealPlannerBloc>().add(LoadMealDetailEvent(widget.mealId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealPlannerBloc, MealPlannerState>(
      builder: (_, state) {
        if (state is MealPlannerLoading) {
          return const Scaffold(
              backgroundColor: _kBg,
              body: Center(child: CircularProgressIndicator(color: _kAccent)));
        }
        if (state is MealPlannerError) {
          return Scaffold(
            backgroundColor: _kBg,
            body: ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<MealPlannerBloc>()
                  .add(LoadMealDetailEvent(widget.mealId)),
            ),
          );
        }
        final meal = state.selectedMeal;
        if (meal == null) {
          return const Scaffold(
              backgroundColor: _kBg,
              body: Center(child: Text('Meal not found')));
        }

        return Scaffold(
          backgroundColor: _kBg,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    meal.strMeal,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 8)
                        ]),
                  ),
                  background: meal.strMealThumb != null
                      ? CachedNetworkImage(
                          imageUrl: meal.strMealThumb!,
                          fit: BoxFit.cover,
                          memCacheWidth: 800,
                          memCacheHeight: 600,
                          fadeInDuration: const Duration(milliseconds: 300),
                          placeholder: (_, __) => Container(color: _kPrimary),
                          errorWidget: (_, __, ___) => Container(
                              color: _kPrimary,
                              child: const Icon(Icons.restaurant,
                                  color: Colors.white54, size: 64)),
                        )
                      : Container(color: _kPrimary),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (meal.strCategory != null)
                            _Tag(meal.strCategory!, _kAccent),
                          if (meal.strArea != null)
                            _Tag(meal.strArea!, _kPrimary),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const _SectionTitle('Ingredients'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: meal.ingredients
                              .map(
                                (e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                            color: _kAccent,
                                            shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${e.value.trim()} ${e.key}',
                                          style: const TextStyle(
                                              fontSize: 14, color: _kPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const _SectionTitle('Instructions'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          meal.strInstructions ?? 'No instructions available.',
                          style: const TextStyle(
                              fontSize: 14,
                              height: 1.7,
                              color: Color(0xFF444444)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: _kPrimary),
      );
}
