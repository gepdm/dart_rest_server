import 'dart:io';

import 'server.dart';

void main(List<String> arguments) async {
  Server server = Server();
  server.init(InternetAddress.loopbackIPv4, 4000);
}
