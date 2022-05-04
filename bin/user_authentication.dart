import 'database_manager.dart';

enum AuthResult {
  authOk,
  wrongCredentials,
  unknownError,
}

class Auth {
  // TODO: implement password hashing (current solution only temporary)
  // TODO: implement JsonWebTokens to keep track of user session
  // static authenticateUserSession(JWT userSession...);
  static authUserCredentials(String email, String password) async {
    // const String salt = Database.getUserSalt(email);
    // const String hashedPassword = Database.hashPassword(password, salt);
    // AuthResult result = Database.verifyCredentials(email, password);
    AuthResult result = await Database.verifyCredentials(email, password);
    // if(result == AuthResult.authOk) generateJWT(...); return userSession;
    return result;
  }

  
}
