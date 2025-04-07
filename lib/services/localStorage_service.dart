import 'package:shared_preferences/shared_preferences.dart';


class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<void> saveData(String key, String value) async {
    final pref = await SharedPreferences.getInstance();
     await pref.setString(key, value);
  }

  Future<String?> getData(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  Future<void> deleteData(String key) async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }
}