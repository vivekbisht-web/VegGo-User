import 'package:vegon_user/core/constants/app_strings.dart';

class PriceFormatter {
  PriceFormatter._();

  static String format(double amount) {
    if (amount % 1 == 0) {
      return '${AppStrings.rupeeSymbol}${amount.toStringAsFixed(0)}';
    }
    return '${AppStrings.rupeeSymbol}${amount.toStringAsFixed(2)}';
  }
}
