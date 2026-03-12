import 'package:shared_preferences/shared_preferences.dart';

class FilterService {
  static const String _filterKey = 'last_filter';

  static Future<void> saveLastFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_filterKey, filter);
  }

  static Future<String> getLastFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_filterKey) ?? 'all';
  }

  static Future<String> getSharedPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? ''
    ;
  }

  static Future<void> setSharedPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

}
