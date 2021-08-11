import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';

class WidgetHelper {
  static Widget buildDateChip() {
    return Bubble(
      alignment: Alignment.center,
      color: Color.fromRGBO(227, 237, 212, 1.0),
      child: Text('heute', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.0)),
    );
  }

  static Widget buildInputArea(double height, double width, Function sendMessageFunction, TextEditingController textController) {
    return Container(
      height: height * 0.1,
      width: width,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildMealButton(),
          buildChatInput(width, textController),
          buildSendButton(sendMessageFunction),
        ],
      ),
    );
  }

  static Widget buildMealButton() {
    return Container(
      color: Color.fromRGBO(77, 182, 172, 1.0),
      padding: EdgeInsets.all(2),
      child: IconButton(
        icon: const Icon(Icons.fastfood),
        onPressed: () => {print('aaa')},
        color: Colors.white,
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
      double height, double width, ScrollController scrollController, List<String> senders, List<String> messages, List<int> timestamps) {
    return Container(
      height: height * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index, senders, messages, timestamps);
        },
      ),
    );
  }

  static Widget buildSingleMessage(int index, List<String> senders, List<String> messages, List<int> timestamps) {
    return Bubble(
      margin: BubbleEdges.only(top: 10, left: 5, right: 5),
      alignment: senders[index] == null ? Alignment.topRight : Alignment.topLeft,
      nip: senders[index] == null ? BubbleNip.rightTop : BubbleNip.leftTop,
      child: Column(
        children: [
          senders[index] == null
              ? SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Text(
                    senders[index],
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
          Text(messages[index]),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Text(
              _getFormatDate(timestamps[index]),
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
