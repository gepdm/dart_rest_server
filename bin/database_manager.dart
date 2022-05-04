import 'package:mysql_client/mysql_client.dart';

import 'user_authentication.dart';

class Database {
  static late MySQLConnection _conn;

  static Future<void> connect(String user, String password) async {
    _conn = await MySQLConnection.createConnection(
        host: "127.0.0.1", port: 3306, userName: user, password: password);
    await _conn.connect();
    await _configure();
  }

  static Future<void> _configure() async {
    await _conn.execute("CREATE DATABASE IF NOT EXISTS main_database;");
    await _conn.execute("USE main_database;");

    await _conn.execute("CREATE TABLE IF NOT EXISTS users ("
        "user_id INT UNIQUE NOT NULL AUTO_INCREMENT, "
        "email VARCHAR(254) UNIQUE NOT NULL, "
        "username VARCHAR(255) UNIQUE NOT NULL, "
        "hashed_password VARCHAR(1024), "
        "salt VARCHAR(32), "
        "PRIMARY KEY (user_id));");
    await _conn.execute("CREATE TABLE IF NOT EXISTS addresses ("
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
    await _conn.execute("CREATE TABLE IF NOT EXISTS foods ("
        "food_id INT UNIQUE NOT NULL AUTO_INCREMENT, "
        "food_name VARCHAR(255) UNIQUE NOT NULL, "
        "food_price DOUBLE, "
        "PRIMARY KEY (food_id));");
    await _conn.execute("CREATE TABLE IF NOT EXISTS orders ("
        "order_id INT UNIQUE NOT NULL AUTO_INCREMENT, "
        "user_id INT UNIQUE NOT NULL, "
        "order_date DATETIME, "
        "order_total DOUBLE NOT NULL, "
        "PRIMARY KEY (order_id), "
        "FOREIGN KEY (user_id) REFERENCES users (user_id));");
    // Many-to-many table
    await _conn.execute("CREATE TABLE IF NOT EXISTS orders_foods ("
        "order_id INT NOT NULL, "
        "food_id INT NOT NULL, "
        "food_qty INT NOT NULL, "
        "food_total DOUBLE NOT NULL, "
        "FOREIGN KEY (order_id) REFERENCES orders (order_id), "
        "FOREIGN KEY (food_id) REFERENCES foods (food_id));");
  }

  static Future<IResultSet> queryFoods() async {
    return _conn.execute("SELECT * FROM foods;");
  }

  static Future<AuthResult> verifyCredentials(
      String email, String hashedPassword) async {
    // NOT SAFE, but the mysql1 package doesn't seems to handle MySql 8 very well
    // possible substitute could be the mysql_client package.
    IResultSet result = await _conn.execute(
        "SELECT email FROM users WHERE email = :email && hashed_password = :password;",
        {"email": email, "password": hashedPassword});
    if (result.rows.isNotEmpty) {
      return AuthResult.authOk;
    } else {
      return AuthResult.wrongCredentials;
    }
  }

  static Future<AuthResult> registerUser(
      String email, String username, String password, String salt) async {
    IResultSet alreadyRegistered = await _conn.execute(
        "SELECT email, username FROM users "
        "WHERE email = :email OR username = :username;",
        {"email": email, "username": username});

    if (alreadyRegistered.rows.isEmpty) {
      await _conn.execute(
          "INSERT INTO users (email, username, hashed_password, salt) "
          "VALUES (:email, :username, :hashed_password, :salt);",
          {
            "email": email,
            "username": username,
            "hashed_password": password,
            "salt": salt
          });
      return AuthResult.registrationOk;
    } else if (alreadyRegistered.rows.first.colAt(0) == email) {
      return AuthResult.emailInUse;
    } else {
      return AuthResult.usernameInUse;
    }
  }
}
