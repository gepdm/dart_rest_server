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
        "user_id INT UNIQUE NOT NULL AUTO_INCREMENT, "
        "email VARCHAR(254) UNIQUE NOT NULL, "
        "username VARCHAR(255) UNIQUE NOT NULL, "
        "hashed_password VARCHAR(1024), "
        "salt VARCHAR(32), "
        "PRIMARY KEY (user_id));");
    await _conn.query("CREATE TABLE IF NOT EXISTS address ("
        "address_id INT UNIQUE NOT NULL AUTO_INCREMENT, "
        "user_id INT UNIQUE NOT NULL, "
        "rua VARCHAR(255) NOT NULL, "
        "numero INT, "
        "complemento VARCHAR(255), "
        "bairro VARCHAR(255) NOT NULL, "
        "cidade VARCHAR(255) NOT NULL, "
        "cep VARCHAR(8) NOT NULL, "
        "uf VARCHAR(2) NOT NULL, "
        "PRIMARY KEY (address_id), "
        "FOREIGN KEY (user_id) REFERENCES users (user_id));");
    await _conn.query("CREATE TABLE IF NOT EXISTS foods ("
        "food_id INT UNIQUE NOT NULL AUTO_INCREMENT, "
        "food_name VARCHAR(255) UNIQUE NOT NULL, "
        "food_price DOUBLE, "
        "PRIMARY KEY (food_id));");
    await _conn.query("CREATE TABLE IF NOT EXISTS orders ("
        "order_id INT UNIQUE NOT NULL AUTO_INCREMENT, "
        "user_id INT UNIQUE NOT NULL, "
        "order_date DATETIME, "
        "order_total DOUBLE NOT NULL, "
        "PRIMARY KEY (order_id), "
        "FOREIGN KEY (user_id) REFERENCES users (user_id));");
    // Many-to-many table
    await _conn.query("CREATE TABLE IF NOT EXISTS orders_foods ("
        "order_id INT NOT NULL, "
        "food_id INT NOT NULL, "
        "food_qty INT NOT NULL, "
        "food_total DOUBLE NOT NULL, "
        "FOREIGN KEY (order_id) REFERENCES orders (order_id), "
        "FOREIGN KEY (food_id) REFERENCES foods (food_id));");
  }

  static Future<Results> queryFoods() async {
    return _conn.query("SELECT * FROM foods;");
  }
}
