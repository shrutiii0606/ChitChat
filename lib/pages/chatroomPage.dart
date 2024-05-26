import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Container(
              child: Column(
            children: [
              Expanded(
                child: Container(),
              ),
              Container(
                  child: Row(
                children: [
                  const Flexible(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter message",
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ))
                ],
              ))
            ],
          )),
        ));
  }
}
