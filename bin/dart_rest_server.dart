import 'dart:io';

import 'database_manager.dart';
import 'server_wrapper.dart';

void main(List<String> arguments) async {
  Server server = Server();
  await Database.connect("root", "temp_password123");
  server.init(InternetAddress.loopbackIPv4, 4000);
}
