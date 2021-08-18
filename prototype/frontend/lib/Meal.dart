class Meal {
  String _name;
  int _durationInMinutes;
  int _id;

  Meal(name, durationInMinutes, id) {
    _name = name;
    _durationInMinutes = durationInMinutes;
    _id = id;
  }

  static Meal emptyMeal() {
    return null;
  }

  String get getName => _name;
  int get getDurationInMinutes => _durationInMinutes;
  int get getID => _id;
}
