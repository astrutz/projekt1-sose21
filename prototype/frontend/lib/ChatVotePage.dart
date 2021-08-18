import 'dart:convert';

import 'package:bubble/bubble.dart';

import 'Meal.dart';
import 'Meals.dart';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class ChatVotePage extends StatefulWidget {
  final String name;

  ChatVotePage({Key key, this.name}) : super(key: key);

  @override
  ChatVotePageState createState() => ChatVotePageState();
}

class ChatVotePageState extends State<ChatVotePage> {
  IO.Socket socket;
  List<String> messages;
  List<String> senders;
  List<int> timestamps;
  List<Meal> meals;
  List<Meal> votes;
  List<Meal> finalVotes;
  double height, width;
  TextEditingController textController;
  ScrollController scrollController;
  bool alreadyVoted;

  @override
  void initState() {
    messages = List<String>();
    senders = List<String>();
    timestamps = List<int>();
    meals = List<Meal>();
    votes = List<Meal>();
    finalVotes = List<Meal>();
    textController = TextEditingController();
    scrollController = ScrollController();
    socket = IO.io('https://projekt1-chat.herokuapp.com', OptionBuilder().setTransports(['websocket']).build());
    socket.onConnect((_) {
      print('Socket connected');
    });
    socket.on('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      if (data['endVote'] == null) {
        print('New message');
        print(jsonData);
        if (data['finalVote'] != null) {
          this.setState(() => messages.add(null));
          this.setState(() => meals.add(null));
          this.setState(() => votes.add(null));
          this.setState(() => timestamps.add(DateTime.now().millisecondsSinceEpoch));
          this.setState(() => senders.add(null));
          this.setState(() => finalVotes.add(Meals.getMealByID((data['finalVote'] as int))));
          this.setState(() => alreadyVoted = false);
        } else {
          this.setState(() => messages.add(data['message']));
          this.setState(() => senders.add(data['sender']));
          this.setState(() => timestamps.add(data['timestamp']));
          this.setState(() => meals.add(Meals.getMealByID(data['mealID'])));
          this.setState(() => votes.add(Meals.getMealByID(data['voteID'])));
          this.setState(() => finalVotes.add(null));
        }
      }
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
      this.setState(() => finalVotes.add(null));
      this.setState(() => timestamps.add(DateTime.now().millisecondsSinceEpoch));
      this.setState(() => textController.text = '');
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
    this.setState(() => finalVotes.add(null));
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
    this.setState(() => finalVotes.add(null));
    this.setState(() => senders.add(widget.name));
    this.setState(() => timestamps.add(DateTime.now().millisecondsSinceEpoch));
    if (scrollController.position.maxScrollExtent > 0) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
    this.setState(() => alreadyVoted = true);
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
                    socket.emit('send_message', json.encode({'endVote': true}));
                  },
                )
              ]
            : <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildDateChip(),
            buildMessageList(),
            buildInputArea(context),
          ],
        ),
      ),
      backgroundColor: Colors.grey[300],
    );
  }

  // ------------------------------------------------------------------

  Widget buildDateChip() {
    return Bubble(
      alignment: Alignment.center,
      margin: BubbleEdges.only(top: 10),
      color: Color.fromRGBO(227, 237, 212, 1.0),
      child: Text('heute', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.0)),
    );
  }

  Widget buildInputArea(BuildContext context) {
    return Container(
      height: height * 0.1,
      width: width,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildMealButton(context),
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  Widget buildMealButton(BuildContext context) {
    SimpleDialog dialog = buildMealDialog(context);
    return Container(
      color: Color.fromRGBO(77, 182, 172, 1.0),
      padding: EdgeInsets.all(2),
      child: IconButton(
        icon: const Icon(Icons.fastfood),
        onPressed: () => {showDialog<void>(context: context, builder: (context) => dialog)},
        color: Colors.white,
      ),
    );
  }

  SimpleDialog buildMealDialog(BuildContext context) {
    List<Widget> dialogItems = [];
    for (Meal meal in Meals.getMeals()) {
      Widget dialogItem = buildMealDialogItem(context, meal);
      dialogItems.add(dialogItem);
    }
    return SimpleDialog(
      title: Text('Wähle ein Gericht aus'),
      children: dialogItems,
    );
  }

  Widget buildMealDialogItem(BuildContext context, Meal meal) {
    return SimpleDialogOption(
      onPressed: () => {
        _sendMeal(meal),
        Navigator.pop(context, 'user01@gmail.com'),
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('images/${meal.getName}.jpg'),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.getName, style: TextStyle(fontSize: 16.0)),
                Text('Zubereitungsdauer: ${meal.getDurationInMinutes} Minuten'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width * 0.7,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(left: 10.0, right: 10),
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromRGBO(77, 182, 172, 1.0),
            ),
          ),
        ),
        cursorColor: Color.fromRGBO(77, 182, 172, 1.0),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Color.fromRGBO(77, 182, 172, 1.0),
      onPressed: () {
        _sendMessage();
      },
      child: Icon(
        Icons.send,
        size: 30,
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

  Widget buildSingleMessage(int index) {
    if (messages[index] == null && votes[index] == null && finalVotes[index] == null) {
      print('Case Meal');
      return buildMealMessage(senders[index], meals[index], timestamps[index]);
    } else if (meals[index] == null && votes[index] == null && finalVotes[index] == null) {
      print('Case Text');
      return buildTextMessage(senders[index], messages[index], timestamps[index]);
    } else if (meals[index] == null && messages[index] == null && finalVotes[index] == null) {
      print('Case Vote');
      return buildVoteMessage(senders[index], votes[index]);
    } else if (finalVotes[index] != null) {
      print('Case FinalVote');
      return buildFinalVoteMessage(finalVotes[index]);
    } else {
      throw Error();
    }
  }

  Widget buildMealMessage(String sender, Meal meal, int timestamp) {
    return Bubble(
      margin: BubbleEdges.only(bottom: 10, left: 5, right: 5),
      alignment: sender == null ? Alignment.topRight : Alignment.topLeft,
      nip: sender == null ? BubbleNip.rightTop : BubbleNip.leftTop,
      child: Column(
        children: [
          sender == null
              ? SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Text(
                    sender,
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Text('Wie wäre es mit ${meal.getName}?'),
              ),
              Image(
                image: AssetImage('images/${meal.getName}.jpg'),
              ),
              if (_sendVote != null)
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(77, 182, 172, 1.0))),
                    onPressed: alreadyVoted == true
                        ? null
                        : () => {
                              _sendVote(meal),
                            },
                    child: Text('Abstimmen'),
                  ),
                )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Text(
              _getFormatDate(timestamp),
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget buildTextMessage(String sender, String message, int timestamp) {
    return Bubble(
      margin: BubbleEdges.only(bottom: 10, left: 5, right: 5),
      alignment: sender == null ? Alignment.topRight : Alignment.topLeft,
      nip: sender == null ? BubbleNip.rightTop : BubbleNip.leftTop,
      child: Column(
        children: [
          sender == null
              ? SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Text(
                    sender,
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
          Text(message),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Text(
              _getFormatDate(timestamp),
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget buildVoteMessage(String sender, Meal vote) {
    return Bubble(
      alignment: Alignment.center,
      margin: BubbleEdges.only(bottom: 10),
      color: Color.fromRGBO(227, 237, 212, 1.0),
      child: Text('$sender stimmt ab für ${vote.getName}', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.0)),
    );
  }

  Widget buildFinalVoteMessage(Meal finalVote) {
    return Bubble(
      alignment: Alignment.center,
      margin: BubbleEdges.only(bottom: 10),
      color: Color.fromRGBO(227, 237, 212, 1.0),
      child: Text('Es wurde sich für ${finalVote.getName} entschieden.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
    );
  }

  String _getFormatDate(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String hour = date.hour < 10 ? '0' + date.hour.toString() : date.hour.toString();
    String minute = date.minute < 10 ? '0' + date.minute.toString() : date.minute.toString();
    return '$hour:$minute';
  }
}
