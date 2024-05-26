// bengali_year_converter.dart

class BengaliYearConverter {
  static String convertToBengali(int year) {
    Map<String, String> bengaliDigits = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };

    String yearString = year.toString();
    String bengaliYear = '';

    for (int i = 0; i < yearString.length; i++) {
      if (bengaliDigits.containsKey(yearString[i])) {
        bengaliYear += bengaliDigits[yearString[i]]!;
      } else {
        bengaliYear += yearString[i];
      }
    }

    return bengaliYear;
  }
}