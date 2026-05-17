import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meal_planner/bloc/meal_planner_bloc.dart';
import 'package:meal_planner/models/meal.dart';
import 'package:meal_planner/services/meal_api_service.dart';

class MockMealApiService extends Mock implements MealApiService {}

void main() {
  late MockMealApiService mockService;

  const testMeal = Meal(
    idMeal: '1',
    strMeal: 'Test Pasta',
    strCategory: 'Pasta',
  );

  setUp(() {
    mockService = MockMealApiService();
  });

  group('MealPlannerBloc - Search', () {
    blocTest<MealPlannerBloc, MealPlannerState>(
      'emits [Loading, Loaded] when SearchMealsEvent succeeds',
      build: () {
        when(() => mockService.searchMeals('pasta'))
            .thenAnswer((_) async => [testMeal]);
        return MealPlannerBloc(apiService: mockService);
      },
      act: (bloc) => bloc.add(const SearchMealsEvent('pasta')),
      expect: () => [
        isA<MealPlannerLoading>(),
        isA<MealPlannerLoaded>()
            .having((s) => s.meals, 'meals', contains(testMeal)),
      ],
    );

    blocTest<MealPlannerBloc, MealPlannerState>(
      'emits [Loading, Error] when SearchMealsEvent throws',
      build: () {
        when(() => mockService.searchMeals(any()))
            .thenThrow(ApiException('Network error'));
        return MealPlannerBloc(apiService: mockService);
      },
      act: (bloc) => bloc.add(const SearchMealsEvent('pasta')),
      expect: () => [
        isA<MealPlannerLoading>(),
        isA<MealPlannerError>()
            .having((s) => s.message, 'message', 'Network error'),
      ],
    );
  });

  group('MealPlannerBloc - Meal Plan CRUD', () {
    blocTest<MealPlannerBloc, MealPlannerState>(
      'CREATE: AddMealToPlanEvent adds meal to plan',
      build: () => MealPlannerBloc(apiService: mockService),
      act: (bloc) => bloc.add(const AddMealToPlanEvent(
        dayLabel: 'Mon',
        mealTime: 'Lunch',
        meal: testMeal,
      )),
      expect: () => [
        isA<MealPlannerLoaded>().having(
          (s) => s.plannedMeals.length,
          'plan count',
          1,
        ),
      ],
    );

    blocTest<MealPlannerBloc, MealPlannerState>(
      'DELETE: RemoveMealFromPlanEvent removes meal',
      build: () => MealPlannerBloc(apiService: mockService),
      seed: () => const MealPlannerLoaded(plannedMeals: [
        PlannedMeal(
          id: 'Mon_Lunch',
          dayLabel: 'Mon',
          mealTime: 'Lunch',
          meal: testMeal,
        )
      ]),
      act: (bloc) => bloc.add(const RemoveMealFromPlanEvent('Mon_Lunch')),
      expect: () => [
        isA<MealPlannerLoaded>().having((s) => s.plannedMeals, 'plan', isEmpty),
      ],
    );

    blocTest<MealPlannerBloc, MealPlannerState>(
      'CLEAR: ClearPlanEvent empties the plan',
      build: () => MealPlannerBloc(apiService: mockService),
      seed: () => const MealPlannerLoaded(plannedMeals: [
        PlannedMeal(
          id: 'Mon_Lunch',
          dayLabel: 'Mon',
          mealTime: 'Lunch',
          meal: testMeal,
        )
      ]),
      act: (bloc) => bloc.add(const ClearPlanEvent()),
      expect: () => [
        isA<MealPlannerLoaded>().having((s) => s.plannedMeals, 'plan', isEmpty),
      ],
    );
  });
}
