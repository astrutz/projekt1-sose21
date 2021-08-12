import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';

import 'Meal.dart';
import 'Meals.dart';

class WidgetHelper {
  static Widget buildDateChip() {
    return Bubble(
      alignment: Alignment.center,
      color: Color.fromRGBO(227, 237, 212, 1.0),
      child: Text('heute', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.0)),
    );
  }

  static Widget buildInputArea(
      Function sendMealCallback, BuildContext context, double height, double width, Function sendMessageFunction, TextEditingController textController) {
    return Container(
      height: height * 0.1,
      width: width,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildMealButton(sendMealCallback, context),
          buildChatInput(width, textController),
          buildSendButton(sendMessageFunction),
        ],
      ),
    );
  }

  static Widget buildMealButton(Function sendMealCallback, BuildContext context) {
    SimpleDialog dialog = buildMealDialog(context, sendMealCallback);
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

  static SimpleDialog buildMealDialog(BuildContext context, Function sendMealCallback) {
    List<Widget> dialogItems = [];
    for (Meal meal in Meals.getMeals()) {
      Widget dialogItem = buildMealDialogItem(context, sendMealCallback, meal);
      dialogItems.add(dialogItem);
    }
    return SimpleDialog(
      title: Text('Wähle ein Gericht aus'),
      children: dialogItems,
    );
  }

  static Widget buildMealDialogItem(BuildContext context, Function sendMealCallback, Meal meal) {
    return SimpleDialogOption(
      onPressed: () => {
        sendMealCallback(meal),
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

  static Widget buildChatInput(double width, TextEditingController textController) {
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

  static Widget buildSendButton(Function sendMessageFunction) {
    return FloatingActionButton(
      backgroundColor: Color.fromRGBO(77, 182, 172, 1.0),
      onPressed: () {
        sendMessageFunction();
      },
      child: Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  static Widget buildMessageList(
      double height, double width, ScrollController scrollController, List<String> senders, List<String> messages, List<int> timestamps, List<Meal> meals) {
    return Container(
      height: height * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index, senders, messages, timestamps, meals);
        },
      ),
    );
  }

  static Widget buildSingleMessage(int index, List<String> senders, List<String> messages, List<int> timestamps, List<Meal> meals) {
    if (messages[index] == null) {
      return buildMealMessage(senders[index], meals[index], timestamps[index]);
    } else {
      return buildTextMessage(senders[index], messages[index], timestamps[index]);
    }
  }

  static Widget buildMealMessage(String sender, Meal meal, int timestamp) {
    return Bubble(
      margin: BubbleEdges.only(top: 10, left: 5, right: 5),
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
          Column(children: [
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Text('Ich schlage vor: ${meal.getName}'),
            ),
            Image(
              image: AssetImage('images/${meal.getName}.jpg'),
            )
          ]),
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

  static Widget buildTextMessage(String sender, String message, int timestamp) {
    return Bubble(
      margin: BubbleEdges.only(top: 10, left: 5, right: 5),
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

  static String _getFormatDate(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String hour = date.hour < 10 ? '0' + date.hour.toString() : date.hour.toString();
    String minute = date.minute < 10 ? '0' + date.minute.toString() : date.minute.toString();
    return '$hour:$minute';
  }
}
