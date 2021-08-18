import 'dart:convert';

import 'Meal.dart';
import 'Meals.dart';
import 'WidgetHelper.dart';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class ChatPage extends StatefulWidget {
  final String name;

  ChatPage({Key key, this.name}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  IO.Socket socket;
  List<String> messages;
  List<String> senders;
  List<int> timestamps;
  List<Meal> meals;
  List<Meal> votes;
  double height, width;
  TextEditingController textController;
  ScrollController scrollController;

  @override
  void initState() {
    messages = List<String>();
    senders = List<String>();
    timestamps = List<int>();
    meals = List<Meal>();
    votes = List<Meal>();
    textController = TextEditingController();
    scrollController = ScrollController();
    socket = IO.io('https://projekt1-chat.herokuapp.com', OptionBuilder().setTransports(['websocket']).build());
    socket.onConnect((_) {
      print('Socket connected');
    });
    socket.on('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() => messages.add(data['message']));
      this.setState(() => senders.add(data['sender']));
      this.setState(() => timestamps.add(data['timestamp']));
      this.setState(() => meals.add(Meals.getMealByID(data['mealID'])));
      this.setState(() => votes.add(Meals.getMealByID(data['voteID'])));
      if (scrollController.position.maxScrollExtent > 0) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    });
    super.initState();
  }

  void _sendMessage() {
    if (textController.text.isNotEmpty) {
      socket.emit('send_message', json.encode({'message': textController.text, 'sender': widget.name, 'timestamp': DateTime.now().millisecondsSinceEpoch}));
      this.setState(() => messages.add(textController.text));
      this.setState(() => senders.add(null));
      this.setState(() => meals.add(null));
      this.setState(() => votes.add(null));
      this.setState(() => timestamps.add(DateTime.now().millisecondsSinceEpoch));
      textController.text = '';
      if (scrollController.position.maxScrollExtent > 0) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    }
  }

  void _sendMeal(Meal meal) {
    socket.emit('send_message',
        json.encode({'mealID': meal.getID, 'voteID': null, 'message': null, 'sender': widget.name, 'timestamp': DateTime.now().millisecondsSinceEpoch}));
    this.setState(() => messages.add(null));
    this.setState(() => meals.add(meal));
    this.setState(() => votes.add(null));
    this.setState(() => senders.add(null));
    this.setState(() => timestamps.add(DateTime.now().millisecondsSinceEpoch));
    if (scrollController.position.maxScrollExtent > 0) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  void _sendVote(Meal meal) {
    socket.emit('send_message',
        json.encode({'mealID': null, 'voteID': meal.getID, 'message': null, 'sender': widget.name, 'timestamp': DateTime.now().millisecondsSinceEpoch}));
    this.setState(() => messages.add(null));
    this.setState(() => meals.add(null));
    this.setState(() => votes.add(meal));
    this.setState(() => senders.add(widget.name));
    this.setState(() => timestamps.add(DateTime.now().millisecondsSinceEpoch));
    if (scrollController.position.maxScrollExtent > 0) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(77, 182, 172, 1.0),
        title: Text('WG-Gruppe'),
        actions: votes.any((element) => element != null)
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  tooltip: 'Abstimmung beenden',
                  onPressed: () {
                    print('tbd'); // TODO
                  },
                )
              ]
            : <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            WidgetHelper.buildDateChip(),
            WidgetHelper.buildMessageList(height, width, scrollController, senders, messages, timestamps, meals, votes, _sendVote),
            WidgetHelper.buildInputArea(_sendMeal, context, height, width, _sendMessage, textController),
          ],
        ),
      ),
      backgroundColor: Colors.grey[300],
    );
  }
}
