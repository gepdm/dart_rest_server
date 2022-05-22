import 'dart:io';
import 'dart:convert';

import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';

import 'database_manager.dart';
import 'order.dart';
import 'user_authentication.dart';

const _encoder = JsonEncoder.withIndent('  ');

void handleUnknowEndpoint(HttpRequest req) {
  HttpResponse res = req.response;
  res.headers.contentType = ContentType.json;
  res.statusCode = HttpStatus.badRequest;
  req.response.close();
}

Future<Response> handleFoodList(Request req) async {
  // TODO: cache the query in memory, because the list of foods doesn't
  // change frequently, so we dont need to query the database every time.
  IResultSet foods = await Database.queryFoods();
  List<Map<String, dynamic>> foodMap = [];
  for (var row in foods.rows) {
    foodMap
        .add({"Id": row.colAt(0), "Name": row.colAt(1), "Price": row.colAt(2)});
  }
  return Response.ok(_encoder.convert(foodMap),
      headers: {"content-type": "application/json"});
}

Future<Response> handleCreateOrder(Request req) async {
  var json =
      (JsonDecoder().convert(await Utf8Decoder().bind(req.read()).join()));
  String? email = req.headers["email"];
  String? password = req.headers["password"];

  if (email == null || password == null) {
    return Response.forbidden(
        _encoder.convert({"error": "Please provide your credentials"}));
  } else if (await Database.verifyCredentials(email, password) ==
      AuthResult.authOk) {
    Order order = Order(email, json);
    await Database.insertOrder(order);
    return Response.ok(null);
  } else {
    return Response.forbidden(
        _encoder.convert({"error": "Invalid credentials"}));
  }
}

Future<Response> handleRegister(Request req) async {
  if (req.headers["content-type"] != null &&
      req.headers["content-type"] == "application/json") {
    var json =
        (JsonDecoder().convert(await Utf8Decoder().bind(req.read()).join()));
    if (json["username"] == null ||
        json["email"] == null ||
        json["password"] == null) {
      return Response.badRequest(
          body: _encoder
              .convert({"error": "Please provide registration information"}));
    } else {
      switch (await Database.registerUser(
          json["email"], json["username"], json["password"], "salt")) {
        case AuthResult.registrationOk:
          return Response.ok(null);
        case AuthResult.emailInUse:
          return Response.forbidden(
              _encoder.convert({"error": "Email already registered"}));
        case AuthResult.usernameInUse:
          return Response.forbidden(
              _encoder.convert({"error": "Username already registered"}));
        default:
          return Response.forbidden(
              _encoder.convert({"error": "Unknown error"}));
      }
    }
  } else {
    return Response.badRequest(
        body: _encoder.convert({"error": "Content-Type is not JSON."}));
  }
}

Future<Response> handleLogin(Request req) async {
  if (req.headers["content-type"] != null &&
      req.headers["content-type"]!.startsWith("application/json")) {
    var json =
        (JsonDecoder().convert(await Utf8Decoder().bind(req.read()).join()));
    if (json["email"] == null || json["password"] == null) {
      return Response.badRequest(
          body: _encoder
              .convert({"error": "Please provide registration information"}));
    } else {
      switch (await Auth.authUserCredentials(json["email"], json["password"])) {
        case AuthResult.authOk:
          return Response.ok(_encoder.convert(
              {"status": "Login success", "token": "Not yet implemented"}));
        case AuthResult.wrongCredentials:
          return Response.forbidden(
              _encoder.convert({"status": "Wrong credentials"}));
        default:
          return Response.forbidden(
              _encoder.convert({"status": "Unknown error"}));
      }
    }
  } else {
    return Response.badRequest(
        body: _encoder.convert({
      "status": "Content-Type is not JSON, is ${req.headers["content-type"]}"
    }));
  }
}
