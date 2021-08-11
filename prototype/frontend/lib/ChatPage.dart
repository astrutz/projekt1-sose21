import 'dart:convert';

import 'WidgetHelper.dart';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class ChatPage extends StatefulWidget {
  final String name;

  ChatPage({Key key, this.name}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  IO.Socket socket;
  List<String> messages;
  List<String> senders;
  List<int> timestamps;
  double height, width;
  TextEditingController textController;
  ScrollController scrollController;

  @override
  void initState() {
    messages = List<String>();
    senders = List<String>();
    timestamps = List<int>();
    textController = TextEditingController();
    scrollController = ScrollController();
    socket = IO.io(
        'https://projekt1-chat.herokuapp.com',
        OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
            .build());
    socket.onConnect((_) {
      print('Socket connected');
    });
    socket.on('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() => messages.add(data['message']));
      this.setState(() => senders.add(data['sender']));
      this.setState(() => timestamps.add(data['timestamp']));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    });
    super.initState();
  }

  void _sendMessage() {
    //Check if the textfield has text or not
    if (textController.text.isNotEmpty) {
      //Send the message as JSON data to send_message event
      //Add the message to the list
      socket.emit('send_message', json.encode({'message': textController.text, 'sender': widget.name, 'timestamp': DateTime.now().millisecondsSinceEpoch}));
      this.setState(() => messages.add(textController.text));
      this.setState(() => senders.add(null));
      this.setState(() => timestamps.add(DateTime.now().millisecondsSinceEpoch));
      textController.text = '';
      //Scrolldown the list to show the latest message
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    }
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
            WidgetHelper.buildDateChip(),
            WidgetHelper.buildMessageList(height, width, scrollController, senders, messages, timestamps),
            WidgetHelper.buildInputArea(height, width, _sendMessage, textController),
          ],
        ),
      ),
      backgroundColor: Colors.grey[300],
    );
  }
}
