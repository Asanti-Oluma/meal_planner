import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';

part 'meal_planner_event.dart';
part 'meal_planner_state.dart';

class MealPlannerBloc extends Bloc<MealPlannerEvent, MealPlannerState> {
  final MealApiService _apiService;

  MealPlannerBloc({MealApiService? apiService})
      : _apiService = apiService ?? MealApiService(),
        super(const MealPlannerInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<SearchMealsEvent>(_onSearchMeals);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<LoadMealDetailEvent>(_onLoadMealDetail);
    on<LoadRandomMealEvent>(_onLoadRandomMeal);
    on<ClearSearchEvent>(_onClearSearch);
    on<AddMealToPlanEvent>(_onAddMealToPlan);
    on<UpdatePlannedMealEvent>(_onUpdatePlannedMeal);
    on<RemoveMealFromPlanEvent>(_onRemoveMealFromPlan);
    on<ClearPlanEvent>(_onClearPlan);
  }

  // READ: Load categories
  Future<void> _onLoadCategories(
      LoadCategoriesEvent event, Emitter<MealPlannerState> emit) async {
    if (state.categories.isNotEmpty) return;
    emit(MealPlannerLoading(
      meals: state.meals,
      plannedMeals: state.plannedMeals,
    ));
    try {
      final cats = await _apiService.getCategories();
      emit(MealPlannerLoaded(
        categories: cats,
        meals: state.meals,
        plannedMeals: state.plannedMeals,
      ));
    } on ApiException catch (e) {
      emit(MealPlannerError(e.message,
          meals: state.meals, plannedMeals: state.plannedMeals));
    } catch (e) {
      emit(MealPlannerError('Unexpected error: $e',
          meals: state.meals, plannedMeals: state.plannedMeals));
    }
  }

  // READ: Search meals
  Future<void> _onSearchMeals(
      SearchMealsEvent event, Emitter<MealPlannerState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(MealPlannerLoaded(
        categories: state.categories,
        plannedMeals: state.plannedMeals,
      ));
      return;
    }
    emit(MealPlannerLoading(
      categories: state.categories,
      plannedMeals: state.plannedMeals,
    ));
    try {
      final meals = await _apiService.searchMeals(event.query);
      emit(MealPlannerLoaded(
        meals: meals,
        categories: state.categories,
        plannedMeals: state.plannedMeals,
      ));
    } on ApiException catch (e) {
      emit(MealPlannerError(e.message,
          categories: state.categories, plannedMeals: state.plannedMeals));
    } catch (e) {
      emit(MealPlannerError('Unexpected error: $e',
          categories: state.categories, plannedMeals: state.plannedMeals));
    }
  }

  // READ: Filter by category
  Future<void> _onFilterByCategory(
      FilterByCategoryEvent event, Emitter<MealPlannerState> emit) async {
    emit(MealPlannerLoading(
      categories: state.categories,
      plannedMeals: state.plannedMeals,
      selectedCategory: event.category,
    ));
    try {
      final meals = await _apiService.filterByCategory(event.category);
      emit(MealPlannerLoaded(
        meals: meals,
        categories: state.categories,
        plannedMeals: state.plannedMeals,
        selectedCategory: event.category,
      ));
    } on ApiException catch (e) {
      emit(MealPlannerError(e.message,
          categories: state.categories,
          plannedMeals: state.plannedMeals,
          selectedCategory: event.category));
    } catch (e) {
      emit(MealPlannerError('Unexpected error: $e',
          categories: state.categories, plannedMeals: state.plannedMeals));
    }
  }

  //  READ: Meal detail
  Future<void> _onLoadMealDetail(
      LoadMealDetailEvent event, Emitter<MealPlannerState> emit) async {
    emit(MealPlannerLoading(
      meals: state.meals,
      categories: state.categories,
      plannedMeals: state.plannedMeals,
    ));
    try {
      final meal = await _apiService.getMealById(event.mealId);
      if (meal == null) {
        emit(MealPlannerError('Meal not found',
            meals: state.meals,
            categories: state.categories,
            plannedMeals: state.plannedMeals));
        return;
      }
      emit(MealDetailLoaded(
        meal: meal,
        meals: state.meals,
        categories: state.categories,
        plannedMeals: state.plannedMeals,
      ));
    } on ApiException catch (e) {
      emit(MealPlannerError(e.message,
          meals: state.meals,
          categories: state.categories,
          plannedMeals: state.plannedMeals));
    } catch (e) {
      emit(MealPlannerError('Unexpected error: $e',
          meals: state.meals,
          categories: state.categories,
          plannedMeals: state.plannedMeals));
    }
  }

  // READ: Random meal
  Future<void> _onLoadRandomMeal(
      LoadRandomMealEvent event, Emitter<MealPlannerState> emit) async {
    emit(MealPlannerLoading(
      categories: state.categories,
      plannedMeals: state.plannedMeals,
    ));
    try {
      final meal = await _apiService.getRandomMeal();
      if (meal == null) throw ApiException('No meal returned');
      emit(MealDetailLoaded(
        meal: meal,
        categories: state.categories,
        plannedMeals: state.plannedMeals,
      ));
    } on ApiException catch (e) {
      emit(MealPlannerError(e.message,
          categories: state.categories, plannedMeals: state.plannedMeals));
    } catch (e) {
      emit(MealPlannerError('Unexpected error: $e',
          categories: state.categories, plannedMeals: state.plannedMeals));
    }
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<MealPlannerState> emit) {
    emit(MealPlannerLoaded(
      categories: state.categories,
      plannedMeals: state.plannedMeals,
    ));
  }

  // CREATE: Add meal to plan
  void _onAddMealToPlan(
      AddMealToPlanEvent event, Emitter<MealPlannerState> emit) {
    final id = '${event.dayLabel}_${event.mealTime}';
    final updated = List<PlannedMeal>.from(state.plannedMeals)
      ..removeWhere((p) => p.id == id) // replace if same slot
      ..add(PlannedMeal(
        id: id,
        dayLabel: event.dayLabel,
        mealTime: event.mealTime,
        meal: event.meal,
      ));
    emit(MealPlannerLoaded(
      meals: state.meals,
      categories: state.categories,
      selectedMeal: state.selectedMeal,
      plannedMeals: updated,
      selectedCategory: state.selectedCategory,
    ));
  }

  //  UPDATE: Replace planned meal
  void _onUpdatePlannedMeal(
      UpdatePlannedMealEvent event, Emitter<MealPlannerState> emit) {
    final updated = state.plannedMeals.map((p) {
      if (p.id == event.plannedMealId) return p.copyWith(meal: event.newMeal);
      return p;
    }).toList();
    emit(MealPlannerLoaded(
      meals: state.meals,
      categories: state.categories,
      selectedMeal: state.selectedMeal,
      plannedMeals: updated,
      selectedCategory: state.selectedCategory,
    ));
  }

  // DELETE: Remove planned meal
  void _onRemoveMealFromPlan(
      RemoveMealFromPlanEvent event, Emitter<MealPlannerState> emit) {
    final updated =
        state.plannedMeals.where((p) => p.id != event.plannedMealId).toList();
    emit(MealPlannerLoaded(
      meals: state.meals,
      categories: state.categories,
      selectedMeal: state.selectedMeal,
      plannedMeals: updated,
      selectedCategory: state.selectedCategory,
    ));
  }

  //  CLEAR ALL
  void _onClearPlan(ClearPlanEvent event, Emitter<MealPlannerState> emit) {
    emit(MealPlannerLoaded(
      meals: state.meals,
      categories: state.categories,
      selectedMeal: state.selectedMeal,
      plannedMeals: const [],
      selectedCategory: state.selectedCategory,
    ));
  }

  @override
  Future<void> close() {
    _apiService.close();
    return super.close();
  }
}
