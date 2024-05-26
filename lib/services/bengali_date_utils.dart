// bengali_date_utils.dart

class BengaliDateUtils {
  static String formatCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static String digitsToBengali(String digits) {
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
    String bengaliString = '';
    for (int i = 0; i < digits.length; i++) {
      if (bengaliDigits.containsKey(digits[i])) {
        bengaliString += bengaliDigits[digits[i]]!;
      } else {
        bengaliString += digits[i];
      }
    }
    return bengaliString;
  }
}