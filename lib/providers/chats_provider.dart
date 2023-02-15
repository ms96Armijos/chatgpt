import 'package:chatgptflutter/models/chat_model.dart';
import 'package:chatgptflutter/services/api_services.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  
  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUsserMessage ({required String msg}){
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers({required String msg, required String chosenModelId}) async{
    chatList.addAll(await ApiServices.sendMessage(message: msg, modelId: chosenModelId));
    notifyListeners();
  }
}