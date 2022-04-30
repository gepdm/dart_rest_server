import 'dart:io';
import 'dart:convert';

const _encoder = JsonEncoder.withIndent('  ');

void handleUnknowEndpoint(HttpRequest req) {
  HttpResponse res = req.response;
  res.headers.contentType = ContentType.json;
  res.statusCode = HttpStatus.badRequest;
  req.response.close();
}

void handleFoodList(HttpRequest req) {
  HttpResponse res = req.response;
  res.headers.contentType = ContentType.json;
  res.write(_encoder.convert({"Amendoim": "bom", "Parede": "alta"}));
  res.statusCode = HttpStatus.accepted;
  res.close();
}
