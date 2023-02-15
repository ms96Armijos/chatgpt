import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatgptflutter/constants/api_consts.dart';
import 'package:chatgptflutter/models/chat_model.dart';
import 'package:chatgptflutter/models/models_model.dart';
import 'package:http/http.dart' as http;

class ApiServices{

  static Future<List<ModelsModel>> getModels() async{
    try {
      
      var response  = await http.get(Uri.parse("$BASE_URL/models"),
      headers: {
        'Authorization': 'Bearer $API_KEY'
      });
       
       Map jsonResponse = jsonDecode(response.body);

       if(jsonResponse['error'] != null){
        throw HttpException(jsonResponse['error']['message']);
       }
       print('JsonResponse: $jsonResponse');

       List temp = [];

       for(var value in jsonResponse['data']){
        temp.add(value);
        log('temp ${value['id']}');
       }

  return ModelsModel.modelsFromSnapshot(temp);
    } catch (e) {
      log('error: $e');
      rethrow;
    }
  }


    static Future<List<ChatModel>> sendMessage({required String message, required String modelId}) async{

      print(message);
      print(modelId);
    try {
      
      var response  = await http.post(Uri.parse("$BASE_URL/completions"),
      headers: {
        'Authorization': 'Bearer $API_KEY',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        "model": modelId,
        "prompt": message,
        "max_tokens": 2048
      }) 
      );
      //print('jsonResponse ${response.body}');
       
       Map jsonResponse = jsonDecode(Utf8Decoder().convert(response.body.codeUnits));

       if(jsonResponse['error'] != null){
        throw HttpException(jsonResponse['error']['message']);
       }

      List<ChatModel> chatList = [];
        if(jsonResponse['choices'].length > 0){
          //log('jsonResponse ${jsonResponse['choices'][0]['text']}');
          chatList = List.generate(jsonResponse['choices'].length, (index) => 
          ChatModel(msg: jsonResponse['choices'][index]['text'], 
          chatIndex: 1)
          );
        }

        return chatList;

    } catch (e) {
      log('error: $e');
      rethrow;
    }
  }

}