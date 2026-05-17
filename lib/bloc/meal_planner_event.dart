part of 'meal_planner_bloc.dart';

abstract class MealPlannerEvent extends Equatable {
  const MealPlannerEvent();
  @override
  List<Object?> get props => [];
}

//  Meal Search / Browse
class LoadCategoriesEvent extends MealPlannerEvent {
  const LoadCategoriesEvent();
}

class SearchMealsEvent extends MealPlannerEvent {
  final String query;
  const SearchMealsEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterByCategoryEvent extends MealPlannerEvent {
  final String category;
  const FilterByCategoryEvent(this.category);
  @override
  List<Object?> get props => [category];
}

class LoadMealDetailEvent extends MealPlannerEvent {
  final String mealId;
  const LoadMealDetailEvent(this.mealId);
  @override
  List<Object?> get props => [mealId];
}

class LoadRandomMealEvent extends MealPlannerEvent {
  const LoadRandomMealEvent();
}

class ClearSearchEvent extends MealPlannerEvent {
  const ClearSearchEvent();
}

//  Meal Plan CRUD

// CREATE – add a meal to the plan
class AddMealToPlanEvent extends MealPlannerEvent {
  final String dayLabel;
  final String mealTime;
  final Meal meal;
  const AddMealToPlanEvent({
    required this.dayLabel,
    required this.mealTime,
    required this.meal,
  });
  @override
  List<Object?> get props => [dayLabel, mealTime, meal];
}

// UPDATE – replace a planned meal
class UpdatePlannedMealEvent extends MealPlannerEvent {
  final String plannedMealId;
  final Meal newMeal;
  const UpdatePlannedMealEvent({
    required this.plannedMealId,
    required this.newMeal,
  });
  @override
  List<Object?> get props => [plannedMealId, newMeal];
}

// DELETE – remove a planned meal
class RemoveMealFromPlanEvent extends MealPlannerEvent {
  final String plannedMealId;
  const RemoveMealFromPlanEvent(this.plannedMealId);
  @override
  List<Object?> get props => [plannedMealId];
}

// CLEAR ALL – reset the plan
class ClearPlanEvent extends MealPlannerEvent {
  const ClearPlanEvent();
}
