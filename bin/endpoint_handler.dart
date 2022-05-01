import 'dart:io';
import 'dart:convert';

import 'package:mysql1/mysql1.dart';

import 'database_manager.dart';

const _encoder = JsonEncoder.withIndent('  ');

void handleUnknowEndpoint(HttpRequest req) {
  HttpResponse res = req.response;
  res.headers.contentType = ContentType.json;
  res.statusCode = HttpStatus.badRequest;
  req.response.close();
}

void handleFoodList(HttpRequest req) async {
  // TODO: cache the query in memory, because the list of foods doesn't
  // change frequently, so we dont need to query the database every time.
  HttpResponse res = req.response;
  res.headers.contentType = ContentType.json;
  res.statusCode = HttpStatus.ok;
  Results foods = await Database.queryFoods();
  List<Map<String, dynamic>> foodMap = [];
  for (var row in foods) {
    foodMap.add({"Name": row[1], "Price": row[2]});
  }
  res.write(_encoder.convert(foodMap));
  res.close();
}
