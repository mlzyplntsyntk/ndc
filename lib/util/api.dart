import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Api {

  Future<String> getRequest(String url) async {
    var response = await http.get(
      url
    );
    return response.body;
  }

  Future<String> postRequest(String url, Map data) async {
    var response = await http.post(
      url,
      body: data
    );
    return response.body;
  }
  
}

Api api = Api();