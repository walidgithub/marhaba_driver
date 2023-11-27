import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/signupmethod.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //controller for chat text
  TextEditingController chatText = TextEditingController();

  //controller for scrolling chats
  ScrollController controller = ScrollController();
  bool _sendingMessage = false;
  @override
  void initState() {
    getMessage();
    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

  getMessage() async {
    var val = await getCurrentMessages();
    if (val == 'logout') {
      navigateLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Material(
        // rtl and ltr
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Scaffold(
            body: ValueListenableBuilder(
                valueListenable: valueNotifierHome.value,
                builder: (context, value, child) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.animateTo(controller.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease);
                  });
                  //api call for message seen
                  messageSeen();

                  return Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            media.width * 0.05,
                            MediaQuery.of(context).padding.top +
                                media.width * 0.05,
                            media.width * 0.05,
                            media.width * 0.05),
                        height: media.height * 1,
                        width: media.width * 1,
                        color: page,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: media.width * 0.9,
                                  height: media.width * 0.1,
                                  alignment: Alignment.center,
                                  child: Text(
                                    languages[choosenLanguage]
                                        ['text_chatwithuser'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * twenty,
                                        color: textColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Positioned(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Container(
                                      height: media.width * 0.1,
                                      width: media.width * 0.1,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                                color: (isDarkTheme == true)
                                                    ? textColor.withOpacity(0.3)
                                                    : Colors.black
                                                        .withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 2)
                                          ],
                                          color: page),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.arrow_back,
                                          color: textColor),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Expanded(
                                child: SingleChildScrollView(
                              controller: controller,
                              child: Column(
                                children: chatList
                                    .asMap()
                                    .map((i, value) {
                                      return MapEntry(
                                          i,
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: media.width * 0.025),
                                            width: media.width * 0.9,
                                            alignment:
                                                (chatList[i]['from_type'] == 2)
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                            child: Column(
                                              crossAxisAlignment: (chatList[i]
                                                          ['from_type'] ==
                                                      2)
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: media.width * 0.4,
                                                  padding: EdgeInsets.fromLTRB(
                                                      media.width * 0.04,
                                                      media.width * 0.02,
                                                      media.width * 0.04,
                                                      media.width * 0.02),
                                                  decoration: BoxDecoration(
                                                      borderRadius: (chatList[i][
                                                                  'from_type'] ==
                                                              2)
                                                          ? const BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(24),
                                                              bottomLeft: Radius
                                                                  .circular(24),
                                                              bottomRight: Radius
                                                                  .circular(24))
                                                          : const BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(24),
                                                              bottomLeft:
                                                                  Radius.circular(24),
                                                              bottomRight: Radius.circular(24)),
                                                      color: (chatList[i]['from_type'] == 2)
                                                          ? (isDarkTheme == true)
                                                              ? textColor
                                                              : const Color(0xff000000).withOpacity(0.15)
                                                          : (isDarkTheme == true)
                                                              ? textColor.withOpacity(0.3)
                                                              : const Color(0xff222222)),
                                                  child: Text(
                                                    chatList[i]['message'],
                                                    style: GoogleFonts.roboto(
                                                        fontSize: media.width *
                                                            fourteen,
                                                        color: (chatList[i][
                                                                    'from_type'] ==
                                                                2)
                                                            ? (isDarkTheme ==
                                                                    true)
                                                                ? Colors.black
                                                                : Colors.white
                                                            : Colors.white),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.015,
                                                ),
                                                Text(
                                                  chatList[i]
                                                      ['converted_created_at'],
                                                  style: TextStyle(
                                                      color: textColor),
                                                )
                                              ],
                                            ),
                                          ));
                                    })
                                    .values
                                    .toList(),
                              ),
                            )),
                            Container(
                              margin: EdgeInsets.only(top: media.width * 0.025),
                              padding: EdgeInsets.fromLTRB(
                                  media.width * 0.025,
                                  media.width * 0.01,
                                  media.width * 0.025,
                                  media.width * 0.01),
                              width: media.width * 0.9,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: borderLines, width: 1.2),
                                  color: page),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: media.width * 0.7,
                                    child: TextField(
                                      controller: chatText,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: languages[choosenLanguage]
                                              ['text_entermessage'],
                                          hintStyle: GoogleFonts.roboto(
                                              fontSize: media.width * twelve,
                                              color: (isDarkTheme == true)
                                                  ? textColor.withOpacity(0.5)
                                                  : hintColor)),
                                      style:
                                          GoogleFonts.roboto(color: textColor),
                                      minLines: 1,
                                      onChanged: (val) {},
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      setState(() {
                                        _sendingMessage = true;
                                      });

                                      //api call for send message
                                      var val =
                                          await sendMessage(chatText.text);
                                      if (val == 'logout') {
                                        navigateLogout();
                                      }
                                      chatText.clear();
                                      setState(() {
                                        _sendingMessage = false;
                                      });
                                    },
                                    child: SizedBox(
                                      child: RotatedBox(
                                          quarterTurns:
                                              (languageDirection == 'rtl')
                                                  ? 2
                                                  : 0,
                                          child: Image.asset(
                                            'assets/images/send.png',
                                            fit: BoxFit.contain,
                                            color: textColor,
                                            width: media.width * 0.075,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // loader
                      (_sendingMessage == true)
                          ? const Positioned(top: 0, child: Loading())
                          : Container()
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
