import 'dart:convert';

import 'package:ask/colors.dart';
import 'package:ask/constants.dart';
import 'package:ask/models/chat_message_type.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class AskPage extends StatefulWidget {
  const AskPage({
    super.key,
  });

  @override
  State<AskPage> createState() => _AskPageState();
}

class _AskPageState extends State<AskPage> {
  bool isLoading = false;

  bool isdarkMode = false;
  final TextEditingController _textController = TextEditingController();

  final _ScrollController = ScrollController();

  final List<ChatMessage> _message = [
    ChatMessage(
        chatMessageType: ChatMessageType.bot,
        text: 'Hey there. I am Ask. Ask me anything')
  ];
  @override
  void initState() {
    super.initState();
  }

  Future<String> generateResponse(String prompt) async {
    const String apiKeyValue = apiKey;
    var url = Uri.https("api.openai.com", "/v1/completions");

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKeyValue'
        },
        body: jsonEncode({
          'model': 'text-davinci-003',
          'prompt': prompt,
          'temperature': 0.6,
          'top_p': 1,
          "max_tokens": 300,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0
        }));

    print('here is response ${response.body}');
    // decode
    Map<String, dynamic> newResponse = jsonDecode(response.body);
    return newResponse['choices'][0]['text'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: isdarkMode
                ? Icon(
                    Icons.dark_mode,
                    color: isdarkMode ? Colors.black : Colors.white,
                  )
                : Icon(
                    Icons.light_mode,
                    color: isdarkMode ? Colors.black : Colors.white,
                  ),
            onPressed: () {
              setState(() {
                isdarkMode = !isdarkMode;
                print(isdarkMode);
              });
            },
          )
        ],
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Ask OpenAI ChatGTP by @B4EVA',
            style: TextStyle(
              color: isdarkMode ? AskColors.backgroundColor : Colors.white,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: isdarkMode ? Colors.white : AskColors.backgroundColor,
      ),
      backgroundColor: isdarkMode ? Colors.white : AskColors.botBackgroundColor,
      body: Column(
        children: [
          // chat Body

          Expanded(
            child: _buildList(),
          ),
          Visibility(
            visible: isLoading,
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: [
              _buildInput(),
              _buildsubmitButton(),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Expanded(
      child: TextField(
        maxLines: 2,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          color: AskColors.whiteColor,
        ),
        controller: _textController,
        decoration: const InputDecoration(
          hintText: 'Ask Me something..',
          fillColor: AskColors.backgroundColor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildsubmitButton() {
    return Visibility(
        visible: !isLoading,
        child: Container(
          height: 48,
          color: AskColors.backgroundColor,
          child: IconButton(
            onPressed: () {
              isLoading = true;
              if (_textController.text.isNotEmpty) {
                setState(() {
                  _message.add(ChatMessage(
                      chatMessageType: ChatMessageType.user,
                      text: _textController.text.trim()));
                  isLoading = true;
                });
                var userInput = _textController.text;
                _textController.clear();
                Future.delayed(const Duration(milliseconds: 50))
                    .then((value) => _scrollDown());

                // bot result

                // var prompt = {
                //   "model": "gpt-3.5-turbo",
                //   "messages": userInput,
                // };

                generateResponse(userInput).then((value) {
                  setState(() {
                    isLoading = false;
                    _message.add(ChatMessage(
                        chatMessageType: ChatMessageType.bot, text: value));
                  });
                });
                _textController.clear();
                Future.delayed(const Duration(milliseconds: 50))
                    .then((value) => _scrollDown());
              }
            },
            icon: const Icon(Icons.send_rounded),
            color: const Color.fromRGBO(142, 142, 160, 1),
          ),
        ));
  }

  void _scrollDown() {
    _ScrollController.animateTo(_ScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  ListView _buildList() {
    return ListView.builder(
        controller: _ScrollController,
        itemCount: _message.length,
        itemBuilder: (context, index) {
          var message = _message[index];
          return ChatMessageWidget(
            chatMessageType: message.chatMessageType,
            text: message.text,
            isDark: isdarkMode,
          );
        });
  }
}

class ChatMessageWidget extends StatefulWidget {
  final String text;
  final ChatMessageType chatMessageType;
  final bool isDark;
  const ChatMessageWidget(
      {super.key,
      required this.chatMessageType,
      required this.text,
      required this.isDark});

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      color: widget.chatMessageType == ChatMessageType.bot
          ? AskColors.backgroundColor
          : AskColors.botBackgroundColor,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(
                      16,
                      163,
                      127,
                      1,
                    ),
                    child: Image.asset(
                      'assets/images/bot.png',
                      // scale: 1.5,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16),
                  // padding: const EdgeInsets.all(16),
                  child: const CircleAvatar(child: Icon(Icons.person)),
                ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(),
                    child: Text(
                      widget.text,
                      style: widget.isDark
                          ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.black,
                              )
                          : Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
