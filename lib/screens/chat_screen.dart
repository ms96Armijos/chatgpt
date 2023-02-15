import 'dart:developer';

import 'package:chatgptflutter/constants/constants.dart';
import 'package:chatgptflutter/models/chat_model.dart';
import 'package:chatgptflutter/providers/chats_provider.dart';
import 'package:chatgptflutter/providers/models_provider.dart';
import 'package:chatgptflutter/services/api_services.dart';
import 'package:chatgptflutter/services/assets_manager.dart';
import 'package:chatgptflutter/services/services.dart';
import 'package:chatgptflutter/widgets/chat_widget.dart';
import 'package:chatgptflutter/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  bool isTyping = false;
   TextEditingController? _textEditingController;
   late ScrollController? _listScrollController;
   late FocusNode? focusNode;


  @override
  void initState() {
    // TODO: implement initState
    _listScrollController = ScrollController();
    _textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    focusNode!.dispose();
    _textEditingController!.dispose();
    _listScrollController!.dispose();
  }

  //List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {

    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);


    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.openaiLogo),
        ),
        title: const Text('ChatGPT'),
        actions: [
          IconButton(onPressed: () async{
            await Services.showModalSheet(context: context);
          }, 
          icon: Icon(Icons.more_vert_rounded, color: Colors.white,))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.getChatList.length, //chatList.length,
                itemBuilder: (context, index){
                  return  ChatWidget(
                    msg:  chatProvider.getChatList[index].msg, //chatList[index].msg,
                    chatIndex: chatProvider.getChatList[index].chatIndex //chatList[index].chatIndex,
                  );
                },
              ),
            ),
            if(isTyping) ...[
              const SpinKitThreeBounce(
              color: Colors.white,
              size: 18,
            ),],
            SizedBox(height: 15,),
            Material(
              color: cardColor,
              child: 
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      style: TextStyle(color: Colors.white),
                        controller: _textEditingController,
                        onSubmitted: (value) async {
                          await senMessageFCT(modelsProvider: modelsProvider, chatProvider: chatProvider);
                        },
                        decoration: const InputDecoration.collapsed(
                          hintText: "How can I help you",
                          hintStyle: TextStyle(color: Colors.grey)
                        ),
                    ),
                  ),
                  IconButton(onPressed: () async { await senMessageFCT(modelsProvider: modelsProvider, chatProvider: chatProvider);},
                  icon: Icon(Icons.send, color: Colors.white,))
                ],),
              ),
            )
          ],
        ),
      ),
    );
  }

void scrollListToEND(){
  _listScrollController!.animateTo(_listScrollController!.position.maxScrollExtent, 
  duration: const Duration(seconds: 2), 
  curve: Curves.easeInOut
  );
}

  Future<void> senMessageFCT({required ModelsProvider modelsProvider, required ChatProvider chatProvider})async{
                    
                    if(isTyping){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: TextWidget(label: 'You cant send multiple messages at a time',),
                        backgroundColor: Colors.red,
                        ),
                        );
                      return;
                    }
                    try {
                      String msg = _textEditingController!.text;
                      setState(() {
                        isTyping = true;
                        //chatList.add(ChatModel(msg: _textEditingController!.text, chatIndex: 0));
                        chatProvider.addUsserMessage(msg: msg);
                        _textEditingController!.clear();
                        focusNode!.unfocus();
                      });
                      log('request has been sent ${modelsProvider.getCurrentModel} ${msg}');
                      await chatProvider.sendMessageAndGetAnswers(msg: msg, chosenModelId: modelsProvider.getCurrentModel);
                      /*chatList.addAll(await ApiServices.sendMessage(
                        message: _textEditingController!.text,
                        modelId: modelsProvider.getCurrentModel
                      ));*/ 
                      setState(() {
                        
                      });
                    } catch (e) {
                      log('error $e'); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: TextWidget(label: e.toString(),),
                        backgroundColor: Colors.red,
                        ),
                        );
                    }finally{
                      scrollListToEND();
                      isTyping = false;
                    }
                  }
}