import 'dart:math';

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
            margin: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Trage deinen Namen ein',
              ),
              controller: textController,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () => {
                print(textController.text),
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ChatPage(name: (textController.text == '' ? 'Anonymer User #' + new Random().nextInt(10000).toString() : textController.text));
                  }),
                ),
              },
              child: Text('PoC1 - Chat'),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ChatPage(name: (textController.text == '' ? 'Anonymer User #' + new Random().nextInt(10000).toString() : textController.text));
                  }),
                ),
              },
              child: Text('PoC2 - Chat mit Bot'),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ChatPage(name: (textController.text == '' ? 'Anonymer User #' + new Random().nextInt(10000).toString() : textController.text));
                  }),
                ),
              },
              child: Text('PoC3 - Chat mit Bot und Challenges'),
            ),
          ),
        ],
      ),
    );
  }
}
