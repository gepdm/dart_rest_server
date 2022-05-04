import 'database_manager.dart';

enum AuthResult {
  authOk,
  wrongCredentials,
  registrationOk,
  emailInUse,
  usernameInUse,
  unknownError,
}

class Auth {
  // TODO: implement password hashing (current solution only temporary)
  // TODO: implement JsonWebTokens to keep track of user session
  // static authenticateUserSession(JWT userSession...);
  static Future<AuthResult> authUserCredentials(
      String email, String password) async {
    // const String salt = Database.getUserSalt(email);
    // const String hashedPassword = hashPassword(password, salt);
    // AuthResult result = Database.verifyCredentials(email, password);
    AuthResult result = await Database.verifyCredentials(email, password);
    // if(result == AuthResult.authOk) generateJWT(...); return userSession;
    return result;
  }

  static Future<AuthResult> registerUser(
      String email, String username, String password) async {
    // const String salt = generateSalt();
    // const String hashedPassword = hashPassword(password, salt);
    return await Database.registerUser(email, username, password, "salt");
  }
}
