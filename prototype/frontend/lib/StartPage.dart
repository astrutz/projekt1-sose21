import 'package:flutter/material.dart';
import 'package:frontend/ChatPage.dart';

class StartPage extends StatelessWidget {
  TextEditingController textController;
  @override
  Widget build(BuildContext context) {
    textController = TextEditingController();
    return Scaffold(
      body: ListView(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: const EdgeInsets.all(2.0),
            margin: const EdgeInsets.only(left: 40.0),
            child: TextField(
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
              controller: textController,
            ),
          ),
          ElevatedButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ChatPage(textController.text);
                }),
              ),
            },
            child: Text('PoC1 - Chat'),
          ),
          ElevatedButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ChatPage(textController.text);
                }),
              ),
            },
            child: Text('PoC2 - Chat mit Bot'),
          ),
          ElevatedButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ChatPage(textController.text);
                }),
              ),
            },
            child: Text('PoC3 - Chat mit Bot und Challenges'),
          ),
        ],
      ),
    );
  }
}
