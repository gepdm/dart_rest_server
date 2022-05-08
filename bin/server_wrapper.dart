import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'endpoint_handler.dart';

class Server {
  final _endpointRouter = Router();

  Server();

  Future<void> init(dynamic address, int port) async {
    setEndpoints(_endpointRouter);
    await shelf_io.serve(_endpointRouter, "localhost", 4000);
  }

  void setEndpoints(Router router) {
    router.get("/api/public/foods", handleFoodList);
    router.post("/api/register", handleRegister);
    router.post("/api/private/order", handleCreateOrder);
  }
}
