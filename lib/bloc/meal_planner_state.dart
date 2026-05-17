part of 'meal_planner_bloc.dart';

abstract class MealPlannerState extends Equatable {
  final List<Meal> meals;
  final List<MealCategory> categories;
  final Meal? selectedMeal;
  final List<PlannedMeal> plannedMeals;
  final String? selectedCategory;

  const MealPlannerState({
    this.meals = const [],
    this.categories = const [],
    this.selectedMeal,
    this.plannedMeals = const [],
    this.selectedCategory,
  });

  @override
  List<Object?> get props =>
      [meals, categories, selectedMeal, plannedMeals, selectedCategory];
}

class MealPlannerInitial extends MealPlannerState {
  const MealPlannerInitial() : super();
}

class MealPlannerLoading extends MealPlannerState {
  const MealPlannerLoading({
    super.meals,
    super.categories,
    super.selectedMeal,
    super.plannedMeals,
    super.selectedCategory,
  });
}

class MealPlannerLoaded extends MealPlannerState {
  const MealPlannerLoaded({
    super.meals,
    super.categories,
    super.selectedMeal,
    super.plannedMeals,
    super.selectedCategory,
  });
}

class MealDetailLoaded extends MealPlannerState {
  const MealDetailLoaded({
    required Meal meal,
    super.meals,
    super.categories,
    super.plannedMeals,
    super.selectedCategory,
  }) : super(selectedMeal: meal);
}

class MealPlannerError extends MealPlannerState {
  final String message;
  const MealPlannerError(
    this.message, {
    super.meals,
    super.categories,
    super.selectedMeal,
    super.plannedMeals,
    super.selectedCategory,
  });

  @override
  List<Object?> get props => [...super.props, message];
}
