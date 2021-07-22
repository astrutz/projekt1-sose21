import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  IO.Socket socket;
  List<String> messages;
  List<String> senders;
  double height, width;
  TextEditingController textController;
  ScrollController scrollController;

  @override
  void initState() {
    messages = List<String>();
    senders = List<String>();
    textController = TextEditingController();
    scrollController = ScrollController();
    socket = IO.io(
        'https://projekt1-chat.herokuapp.com',
        OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
            .build());
    socket.onConnect((_) {
      print('connected');
    });
    socket.on('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() => messages.add(data['message']));
      this.setState(() => senders.add(data['sender']));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    });
    super.initState();
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: senders[index] == null ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: senders[index] == null ? const EdgeInsets.only(bottom: 20.0, left: 20.0) : const EdgeInsets.only(bottom: 20.0, right: 20.0),
        decoration: BoxDecoration(
          color: senders[index] == null ? Colors.deepPurple : Colors.grey,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          messages[index],
          style: senders[index] == null ? TextStyle(color: Colors.white, fontSize: 15.0) : TextStyle(color: Colors.black, fontSize: 15.0),
        ),
      ),
    );
  }

  Widget buildMessageList() {
    return Container(
      height: height * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width * 0.7,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(left: 40.0),
      child: TextField(
        decoration: InputDecoration.collapsed(
          hintText: 'Send a message...',
        ),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () {
        //Check if the textfield has text or not
        if (textController.text.isNotEmpty) {
          //Send the message as JSON data to send_message event
          //Add the message to the list
          socket.emit('send_message', json.encode({'message': textController.text, 'sender': 'Me'}));
          this.setState(() => messages.add(textController.text));
          this.setState(() => senders.add(null));
          textController.text = '';
          //Scrolldown the list to show the latest message
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      },
      child: Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      height: height * 0.1,
      width: width,
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: height * 0.1),
            buildMessageList(),
            buildInputArea(),
          ],
        ),
      ),
    );
  }
}
