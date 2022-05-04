import 'dart:io';

import 'database_manager.dart';
import 'server_wrapper.dart';
import 'user_authentication.dart';

void main(List<String> arguments) async {
  Server server = Server();
  await Database.connect("root", "temp_password123");
  if (await Auth.authUserCredentials("marcelo@gmail.com", "password123") ==
      AuthResult.authOk) print("Deu certo");
  server.init(InternetAddress.loopbackIPv4, 4000);
}
