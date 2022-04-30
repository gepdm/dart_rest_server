import 'dart:io';
import 'endpoint_handler.dart';

class Server {
  late final HttpServer _server;

  Server();

  Future<void> init(dynamic address, int port) async {
    _server = await HttpServer.bind(address, port);
    _server.listen(endpointsRouter);
  }

  void endpointsRouter(HttpRequest req) {
    switch (req.uri.path) {
      case "/api/public/food_list":
        handleFoodList(req);
        break;
      default:
        handleUnknowEndpoint(req);
        break;
    }
  }
}
