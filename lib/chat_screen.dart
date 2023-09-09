import 'dart:convert';


import 'package:chatgptmobileapp/api_key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatGPTScreen extends StatefulWidget {
  @override
  _ChatGPTScreenState createState() => _ChatGPTScreenState();
}

class _ChatGPTScreenState extends State<ChatGPTScreen> {
   Color optedcolor=Colors.black;
   double optedfontsize=20;
  final List<Message> _messages = [];

  final TextEditingController _textEditingController = TextEditingController();

  void savechatcustomization(Color color,double fontsize){

    setState(() {
      optedcolor=color;
      optedfontsize=fontsize;
    });
    Navigator.of(context).pop();


  }

  void chatcustomize()
  {

    showDialog(context: context, builder: (context)=>AlertDialog(title: Text('customize chat'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text("select color"),

            Row(children: [
              ElevatedButton(onPressed: (){optedcolor=Colors.red;}, child: Text('red')),
              Padding(
                padding: const EdgeInsets.only(left:14,right:14),
                child: ElevatedButton(onPressed: (){optedcolor=Colors.green;}, child: Text('green')),
              ),


            ],),

            Row(children: [
              ElevatedButton(onPressed: (){optedcolor=Colors.blue;}, child: Text('blue')),
              Padding(
                padding: const EdgeInsets.only(left:14),
                child: ElevatedButton(onPressed: (){optedcolor=Colors.black;}, child: Text('black')),
              )
            ],),



            Text("select fontsize"),
            Row(children: [ElevatedButton(onPressed: (){optedfontsize=12;}, child: Text('12')),
              Padding(
                padding: const EdgeInsets.only(left:14),
                child: ElevatedButton(onPressed: (){optedfontsize=15;;}, child: Text('15')),
              ),],),

            Row(children: [ ElevatedButton(onPressed: (){optedfontsize=18;;}, child: Text('18')),
        Padding(
          padding: const EdgeInsets.only(left:14),
          child: ElevatedButton(onPressed: (){optedfontsize=24;;}, child: Text('24')),
        ),],),

            Row(children: [
              ElevatedButton(onPressed: (){optedfontsize=30;}, child: Text('30'))
            ],)


          ],
        ),
      ),
      actions: [MaterialButton(onPressed: (){savechatcustomization(optedcolor,optedfontsize);},child: Text('save'),),
        MaterialButton(onPressed: (){Navigator.of(context).pop();},child: Text('cancel'),)



      ],
    ));
  }



  void onSendMessage() async {
    Message message = Message(text: _textEditingController.text, isMe: true);

    _textEditingController.clear();

    setState(() {
      _messages.insert(0, message);
    });

    String response = await sendMessageToChatGpt(message.text);

    Message chatGpt = Message(text: response, isMe: false);

    setState(() {
      _messages.insert(0, chatGpt);
    });
  }

  Future<String> sendMessageToChatGpt(String message) async {
    Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": message}
      ],
      "max_tokens": 500,
    };

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${APIKey.apiKey}",
      },
      body: json.encode(body),
    );

    print(response.body);

    Map<String, dynamic> parsedReponse = json.decode(response.body);

    String reply = parsedReponse['choices'][0]['message']['content'];

    return reply;
  }

  Widget _buildMessage(Message message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          crossAxisAlignment:
          message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.isMe ? 'You' : 'GPT',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(message.text,style: TextStyle(color: optedcolor,fontSize: optedfontsize),),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGPT'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(

              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          Row(children: [
            Padding(
              padding: const EdgeInsets.only(left:15,right:15),
              child: ElevatedButton(onPressed: chatcustomize, child: Text("Chat Customization"),style:ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green))),
            ),
              ElevatedButton(onPressed: (){_messages.clear() ;}, child: Text("Clear chat"),style:ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              )),


          ],),

          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Row(
              children: <Widget>[
                

                
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: onSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}