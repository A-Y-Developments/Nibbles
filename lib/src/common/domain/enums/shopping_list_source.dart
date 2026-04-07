import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';

enum ShoppingListSource { recipe, mealPlan, manual }

extension ShoppingListSourceX on ShoppingListSource {
  String toJson() => switch (this) {
    ShoppingListSource.recipe => 'recipe',
    ShoppingListSource.mealPlan => 'mealPlan',
    ShoppingListSource.manual => 'manual',
  };

  static ShoppingListSource fromJson(String value) => switch (value) {
    'recipe' => ShoppingListSource.recipe,
    'mealPlan' => ShoppingListSource.mealPlan,
    'manual' => ShoppingListSource.manual,
    _ => throw ServerException('Unknown ShoppingListSource: $value'),
  };
}
