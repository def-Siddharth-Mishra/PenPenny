import 'package:intl/intl.dart';

class CurrencyHelper {
  static const Map<String, Map<String, String>> currencies = {
    'USD': {'name': 'US Dollar', 'symbol': '\$'},
    'EUR': {'name': 'Euro', 'symbol': '€'},
    'GBP': {'name': 'British Pound', 'symbol': '£'},
    'JPY': {'name': 'Japanese Yen', 'symbol': '¥'},
    'INR': {'name': 'Indian Rupee', 'symbol': '₹'},
    'CAD': {'name': 'Canadian Dollar', 'symbol': 'C\$'},
    'AUD': {'name': 'Australian Dollar', 'symbol': 'A\$'},
    'CHF': {'name': 'Swiss Franc', 'symbol': 'CHF'},
    'CNY': {'name': 'Chinese Yuan', 'symbol': '¥'},
    'SEK': {'name': 'Swedish Krona', 'symbol': 'kr'},
  };

  static String getCurrencySymbol(String currencyCode) {
    return currencies[currencyCode]?['symbol'] ?? currencyCode;
  }

  static String getCurrencyName(String currencyCode) {
    return currencies[currencyCode]?['name'] ?? currencyCode;
  }

  static String formatAmount(double amount, String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);
    
    // Format similar to the original app
    String locale = 'en_US';
    if (currencyCode == 'INR') {
      locale = 'en_IN';
    }
    
    return NumberFormat('$symbol##,##,##,###.####', locale).format(amount);
  }

  static List<String> getAllCurrencyCodes() {
    return currencies.keys.toList();
  }

  // Legacy format method for compatibility
  static String format(
    double amount, {
    String? symbol = "₹",
    String? name = "INR",
    String? locale = "en_IN",
  }) {
    return NumberFormat('$symbol##,##,##,###.####', locale).format(amount);
  }
}