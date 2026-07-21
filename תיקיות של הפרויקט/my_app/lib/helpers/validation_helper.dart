/// Provides validation methods for user input.
class ValidationHelper {
  /// Validates that the grade is between 60 and 100.
  static String? validateGrade(double grade) {
    if (grade < 60 || grade > 100) {
      return 'הממוצע חייב להיות בין 60 ל-100';
    }

    return null;
  }
}