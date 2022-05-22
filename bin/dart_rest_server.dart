import 'dart:io';

import 'database_manager.dart';
import 'server_wrapper.dart';
import 'user_authentication.dart';

void main(List<String> arguments) async {
  Server server = Server();
  await Database.connect("temp_user", "temp_password123");
  server.init(InternetAddress.anyIPv4, 4000);
  print('Server running on localhost');
}
