import 'package:equatable/equatable.dart';

class Meal extends Equatable {
  final String idMeal;
  final String strMeal;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strMealThumb;
  final String? strYoutube;
  final List<MapEntry<String, String>> ingredients;

  const Meal({
    required this.idMeal,
    required this.strMeal,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strMealThumb,
    this.strYoutube,
    this.ingredients = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <MapEntry<String, String>>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(MapEntry(ingredient, measure ?? ''));
      }
    }
    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      strMealThumb: json['strMealThumb'],
      strYoutube: json['strYoutube'],
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toJson() => {
        'idMeal': idMeal,
        'strMeal': strMeal,
        'strCategory': strCategory,
        'strArea': strArea,
        'strInstructions': strInstructions,
        'strMealThumb': strMealThumb,
        'strYoutube': strYoutube,
      };

  Meal copyWith({
    String? idMeal,
    String? strMeal,
    String? strCategory,
    String? strArea,
    String? strInstructions,
    String? strMealThumb,
    String? strYoutube,
    List<MapEntry<String, String>>? ingredients,
  }) {
    return Meal(
      idMeal: idMeal ?? this.idMeal,
      strMeal: strMeal ?? this.strMeal,
      strCategory: strCategory ?? this.strCategory,
      strArea: strArea ?? this.strArea,
      strInstructions: strInstructions ?? this.strInstructions,
      strMealThumb: strMealThumb ?? this.strMealThumb,
      strYoutube: strYoutube ?? this.strYoutube,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  @override
  List<Object?> get props =>
      [idMeal, strMeal, strCategory, strArea, strInstructions];
}

class MealCategory extends Equatable {
  final String idCategory;
  final String strCategory;
  final String? strCategoryThumb;

  const MealCategory({
    required this.idCategory,
    required this.strCategory,
    this.strCategoryThumb,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) => MealCategory(
        idCategory: json['idCategory'] ?? '',
        strCategory: json['strCategory'] ?? '',
        strCategoryThumb: json['strCategoryThumb'],
      );

  @override
  List<Object?> get props => [idCategory, strCategory];
}

/// Represents a day entry in the weekly meal plan.
class PlannedMeal extends Equatable {
  final String id; // unique local id (e.g. "Mon_Breakfast")
  final String dayLabel;
  final String mealTime; // Breakfast | Lunch | Dinner | Snack
  final Meal meal;

  const PlannedMeal({
    required this.id,
    required this.dayLabel,
    required this.mealTime,
    required this.meal,
  });

  PlannedMeal copyWith({Meal? meal, String? mealTime}) => PlannedMeal(
        id: id,
        dayLabel: dayLabel,
        mealTime: mealTime ?? this.mealTime,
        meal: meal ?? this.meal,
      );

  @override
  List<Object?> get props => [id, dayLabel, mealTime, meal];
}
