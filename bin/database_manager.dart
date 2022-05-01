import 'package:mysql1/mysql1.dart';

class Database {
  static late MySqlConnection _conn;

  static Future<void> connect(String user, String password) async {
    ConnectionSettings settings = ConnectionSettings(
        host: "localhost", port: 3306, user: user, password: password);
    _conn = await MySqlConnection.connect(settings);
    await _configure();
  }

  static Future<void> _configure() async {
    await _conn.query("CREATE DATABASE IF NOT EXISTS main_database;");

    await _conn.query("USE main_database;");
    await _conn.query("CREATE TABLE IF NOT EXISTS users ("
        "email VARCHAR(254) UNIQUE NOT NULL, "
        "username VARCHAR(255) UNIQUE NOT NULL, "
        "hashed_password VARCHAR(1024), "
        "salt VARCHAR(32), "
        "PRIMARY KEY (email));");
    await _conn.query("CREATE TABLE IF NOT EXISTS foods ("
        "food_id INT UNIQUE NOT NULL, "
        "food_name VARCHAR(255) UNIQUE NOT NULL, "
        "food_price DOUBLE, "
        "PRIMARY KEY (food_id));");
  }

  static Future<Results> queryFoods() async {
    return _conn.query("SELECT * FROM foods;");
  }
}
