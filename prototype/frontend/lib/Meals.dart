import 'Meal.dart';

class Meals {
  static List<Meal> getMeals() {
    List<Meal> meals = [];
    meals.add(Meal('Thunfischsalat', 10, 0));
    meals.add(Meal('Nudelauflauf', 45, 1));
    meals.add(Meal('Pfannkuchen', 30, 2));
    meals.add(Meal('Rindergulasch', 75, 3));
    meals.add(Meal('Jägerschnitzel', 50, 4));
    meals.add(Meal('Bolognese', 35, 5));
    return meals;
  }

  static Meal getMealByID(int id) {
    if (id == null) {
      return null;
    }
    if (id == -1) {
      return Meal('Unentschieden', 0, 6);
    }
    List<Meal> meals = getMeals();
    return meals.firstWhere((meal) => meal.getID == id);
  }
}
