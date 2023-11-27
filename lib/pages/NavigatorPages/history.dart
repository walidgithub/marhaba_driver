import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/pages/NavigatorPages/historydetails.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/signupmethod.dart';
import 'package:tagxidriver/pages/noInternet/nointernet.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

dynamic selectedHistory;

class _HistoryState extends State<History> {
  int _showHistory = 1;
  bool _isLoading = true;
  dynamic isCompleted;

  @override
  void initState() {
    _isLoading = true;
    _getHistory();
    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

//get history
  _getHistory() async {
    setState(() {
      myHistoryPage.clear();
      myHistory.clear();
    });
    var val = await getHistory('is_completed=1');
    if (mounted) {
      if (val == 'logout') {
        navigateLogout();
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
        child: Directionality(
      textDirection:
          (languageDirection == 'rtl') ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(
        children: [
          Container(
            height: media.height * 1,
            width: media.width * 1,
            color: page,
            padding: EdgeInsets.fromLTRB(
                media.width * 0.05, media.width * 0.05, media.width * 0.05, 0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: media.width * 0.05),
                      width: media.width * 1,
                      alignment: Alignment.center,
                      child: Text(
                        languages[choosenLanguage]['text_enable_history'],
                        style: GoogleFonts.roboto(
                            fontSize: media.width * twenty,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                      ),
                    ),
                    Positioned(
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back, color: textColor)))
                  ],
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  height: media.width * 0.13,
                  width: media.width * 0.9,
                  decoration: BoxDecoration(
                      color: page,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 2,
                            spreadRadius: 2,
                            color: (isDarkTheme == true)
                                ? textColor.withOpacity(0.3)
                                : Colors.black.withOpacity(0.2))
                      ]),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          setState(() {
                            myHistory.clear();
                            myHistoryPage.clear();
                            _showHistory = 1;
                            _isLoading = true;
                          });

                          var val = await getHistory('is_completed=1');
                          if (val == 'logout') {
                            navigateLogout();
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        child: Container(
                            height: media.width * 0.13,
                            alignment: Alignment.center,
                            width: media.width * 0.45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: (_showHistory == 1)
                                    ? (isDarkTheme == true)
                                        ? Colors.white
                                        : const Color(0xff222222)
                                    : page),
                            child: Text(
                              languages[choosenLanguage]['text_completed'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * fifteen,
                                  fontWeight: FontWeight.w600,
                                  color: (_showHistory == 1)
                                      ? (isDarkTheme == true)
                                          ? Colors.black
                                          : Colors.white
                                      : textColor),
                            )),
                      ),
                      InkWell(
                        onTap: () async {
                          setState(() {
                            myHistory.clear();
                            myHistoryPage.clear();
                            _showHistory = 2;
                            _isLoading = true;
                          });

                          var val = await getHistory('is_cancelled=1');
                          if (val == 'logout') {
                            navigateLogout();
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        child: Container(
                            height: media.width * 0.13,
                            alignment: Alignment.center,
                            width: media.width * 0.45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: (_showHistory == 2)
                                    ? (isDarkTheme == true)
                                        ? Colors.white
                                        : const Color(0xff222222)
                                    : page),
                            child: Text(
                              languages[choosenLanguage]['text_cancelled'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * fifteen,
                                  fontWeight: FontWeight.w600,
                                  color: (_showHistory == 2)
                                      ? (isDarkTheme == true)
                                          ? Colors.black
                                          : Colors.white
                                      : textColor),
                            )),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.1,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      (myHistory.isNotEmpty)
                          ? Column(
                              children: myHistory
                                  .asMap()
                                  .map((i, value) {
                                    return MapEntry(
                                        i,
                                        (_showHistory == 1)
                                            ?
                                            //completed rides
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    myHistory[i]['accepted_at'],
                                                    style: GoogleFonts.roboto(
                                                        fontSize: media.width *
                                                            sixteen,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: textColor),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      selectedHistory = i;
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const HistoryDetails()));
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.025,
                                                          bottom: media.width *
                                                              0.05,
                                                          left: media.width *
                                                              0.015,
                                                          right: media.width *
                                                              0.015),
                                                      width: media.width * 0.85,
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              media.width *
                                                                  0.025,
                                                              media.width *
                                                                  0.05,
                                                              media.width *
                                                                  0.025,
                                                              media.width *
                                                                  0.05),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          color: page,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                blurRadius: 2,
                                                                spreadRadius: 2,
                                                                color: (isDarkTheme ==
                                                                        true)
                                                                    ? textColor
                                                                        .withOpacity(
                                                                            0.3)
                                                                    : Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.2))
                                                          ]),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            myHistory[i][
                                                                'request_number'],
                                                            style: GoogleFonts.roboto(
                                                                color:
                                                                    textColor,
                                                                fontSize: media
                                                                        .width *
                                                                    sixteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                media.width *
                                                                    0.02,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                height: media
                                                                        .width *
                                                                    0.16,
                                                                width: media
                                                                        .width *
                                                                    0.16,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    image: DecorationImage(
                                                                        image: NetworkImage(userDetails['role'] ==
                                                                                'owner'
                                                                            ? myHistory[i]['driverDetail']['data'][
                                                                                'profile_picture']
                                                                            : myHistory[i]['userDetail']['data'][
                                                                                'profile_picture']),
                                                                        fit: BoxFit
                                                                            .cover)),
                                                              ),
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.02,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.3,
                                                                    child: Text(
                                                                      userDetails['role'] ==
                                                                              'owner'
                                                                          ? myHistory[i]['driverDetail']['data']
                                                                              [
                                                                              'name']
                                                                          : myHistory[i]['userDetail']['data']
                                                                              [
                                                                              'name'],
                                                                      style: GoogleFonts.roboto(
                                                                          color:
                                                                              textColor,
                                                                          fontSize: media.width *
                                                                              eighteen,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.01,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.06,
                                                                        child: (myHistory[i]['payment_opt'] ==
                                                                                '1')
                                                                            ? Image.asset(
                                                                                'assets/images/cash.png',
                                                                                fit: BoxFit.contain,
                                                                              )
                                                                            : (myHistory[i]['payment_opt'] == '2')
                                                                                ? Image.asset(
                                                                                    'assets/images/wallet.png',
                                                                                    fit: BoxFit.contain,
                                                                                  )
                                                                                : (myHistory[i]['payment_opt'] == '0')
                                                                                    ? Image.asset(
                                                                                        'assets/images/card.png',
                                                                                        fit: BoxFit.contain,
                                                                                      )
                                                                                    : Container(),
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.01,
                                                                      ),
                                                                      Text(
                                                                        (myHistory[i]['payment_opt'] ==
                                                                                '1')
                                                                            ? languages[choosenLanguage]['text_cash']
                                                                            : (myHistory[i]['payment_opt'] == '2')
                                                                                ? languages[choosenLanguage]['text_wallet']
                                                                                : (myHistory[i]['payment_opt'] == '0')
                                                                                    ? languages[choosenLanguage]['text_card']
                                                                                    : '',
                                                                        style: GoogleFonts.roboto(
                                                                            color:
                                                                                textColor,
                                                                            fontSize: media.width *
                                                                                twelve,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              Expanded(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Column(
                                                                      children: [
                                                                        Text(
                                                                          myHistory[i]['requestBill']['data']['requested_currency_symbol'] +
                                                                              ' ' +
                                                                              myHistory[i]['requestBill']['data']['total_amount'].toString(),
                                                                          style: GoogleFonts.roboto(
                                                                              color: textColor,
                                                                              fontSize: media.width * sixteen,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              media.width * 0.01,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              (myHistory[i]['total_time'] < 50) ? myHistory[i]['total_distance'] + myHistory[i]['unit'] + ' - ' + myHistory[i]['total_time'].toString() + ' mins' : myHistory[i]['total_distance'] + myHistory[i]['unit'] + ' - ' + (myHistory[i]['total_time'] / 60).round().toString() + ' hr',
                                                                              style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                media.width *
                                                                    0.05,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                height: media
                                                                        .width *
                                                                    0.05,
                                                                width: media
                                                                        .width *
                                                                    0.05,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: const Color(
                                                                            0xffFF0000)
                                                                        .withOpacity(
                                                                            0.3)),
                                                                child:
                                                                    Container(
                                                                  height: media
                                                                          .width *
                                                                      0.025,
                                                                  width: media
                                                                          .width *
                                                                      0.025,
                                                                  decoration: const BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Color(
                                                                          0xffFF0000)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.05,
                                                              ),
                                                              SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.5,
                                                                  child: Text(
                                                                    myHistory[i]
                                                                        [
                                                                        'pick_address'],
                                                                    style: GoogleFonts.roboto(
                                                                        color:
                                                                            textColor,
                                                                        fontSize:
                                                                            media.width *
                                                                                twelve),
                                                                  )),
                                                              Expanded(
                                                                  child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    '${myHistory[i]['trip_start_time'].toString().split(' ').toList()[2]} ${myHistory[i]['accepted_at'].toString().split(' ').toList()[3]}',
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                twelve,
                                                                        color: const Color(
                                                                            0xff898989)),
                                                                    textDirection:
                                                                        TextDirection
                                                                            .ltr,
                                                                  )
                                                                ],
                                                              ))
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                media.width *
                                                                    0.05,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                height: media
                                                                        .width *
                                                                    0.05,
                                                                width: media
                                                                        .width *
                                                                    0.05,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: const Color(
                                                                            0xff319900)
                                                                        .withOpacity(
                                                                            0.3)),
                                                                child:
                                                                    Container(
                                                                  height: media
                                                                          .width *
                                                                      0.025,
                                                                  width: media
                                                                          .width *
                                                                      0.025,
                                                                  decoration: const BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Color(
                                                                          0xff319900)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.05,
                                                              ),
                                                              SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.5,
                                                                  child: Text(
                                                                    myHistory[i]
                                                                        [
                                                                        'drop_address'],
                                                                    style: GoogleFonts.roboto(
                                                                        color:
                                                                            textColor,
                                                                        fontSize:
                                                                            media.width *
                                                                                twelve),
                                                                  )),
                                                              Expanded(
                                                                  child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    '${myHistory[i]['completed_at'].toString().split(' ').toList()[2]} ${myHistory[i]['completed_at'].toString().split(' ').toList()[3]}',
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                twelve,
                                                                        color: const Color(
                                                                            0xff898989)),
                                                                    textDirection:
                                                                        TextDirection
                                                                            .ltr,
                                                                  )
                                                                ],
                                                              ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : (_showHistory == 2)
                                                ?
                                                //cancelled rides
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        myHistory[i]
                                                            ['updated_at'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    sixteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    textColor),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            top: media.width *
                                                                0.025,
                                                            bottom:
                                                                media.width *
                                                                    0.05,
                                                            left: media.width *
                                                                0.015,
                                                            right: media.width *
                                                                0.015),
                                                        width:
                                                            media.width * 0.85,
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                media.width *
                                                                    0.025,
                                                                media.width *
                                                                    0.05,
                                                                media.width *
                                                                    0.025,
                                                                media.width *
                                                                    0.05),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            color: page,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  blurRadius: 2,
                                                                  spreadRadius:
                                                                      2,
                                                                  color: (isDarkTheme ==
                                                                          true)
                                                                      ? textColor
                                                                          .withOpacity(
                                                                              0.3)
                                                                      : Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.2))
                                                            ]),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              myHistory[i][
                                                                  'request_number'],
                                                              style: GoogleFonts.roboto(
                                                                  color:
                                                                      textColor,
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.02,
                                                            ),
                                                            (myHistory[i]['userDetail'] !=
                                                                        null &&
                                                                    userDetails[
                                                                            'role'] !=
                                                                        'owner')
                                                                ? Container(
                                                                    padding: EdgeInsets.only(
                                                                        bottom: media.width *
                                                                            0.05),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.16,
                                                                          width:
                                                                              media.width * 0.16,
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              image: DecorationImage(image: NetworkImage(myHistory[i]['userDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              media.width * 0.02,
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: media.width * 0.3,
                                                                              child: Text(
                                                                                myHistory[i]['userDetail']['data']['name'],
                                                                                style: GoogleFonts.roboto(fontSize: media.width * eighteen, fontWeight: FontWeight.w600, color: textColor),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  const Icon(
                                                                                    Icons.cancel,
                                                                                    color: Color(0xffFF0000),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: media.width * 0.01,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : (myHistory[i]['driverDetail'] !=
                                                                            null &&
                                                                        userDetails['role'] ==
                                                                            'owner')
                                                                    ? Container(
                                                                        padding:
                                                                            EdgeInsets.only(bottom: media.width * 0.05),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              height: media.width * 0.16,
                                                                              width: media.width * 0.16,
                                                                              decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(myHistory[i]['driverDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                            ),
                                                                            SizedBox(
                                                                              width: media.width * 0.02,
                                                                            ),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                SizedBox(
                                                                                  width: media.width * 0.3,
                                                                                  child: Text(
                                                                                    myHistory[i]['driverDetail']['data']['name'],
                                                                                    style: GoogleFonts.roboto(fontSize: media.width * eighteen, fontWeight: FontWeight.w600),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Expanded(
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  Column(
                                                                                    children: [
                                                                                      const Icon(
                                                                                        Icons.cancel,
                                                                                        color: Color(0xffFF0000),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: media.width * 0.01,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : Container(),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  height: media
                                                                          .width *
                                                                      0.05,
                                                                  width: media
                                                                          .width *
                                                                      0.05,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration: BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: const Color(
                                                                              0xffFF0000)
                                                                          .withOpacity(
                                                                              0.3)),
                                                                  child:
                                                                      Container(
                                                                    height: media
                                                                            .width *
                                                                        0.025,
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                    decoration: const BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Color(
                                                                            0xffFF0000)),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.05,
                                                                ),
                                                                SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.7,
                                                                    child: Text(
                                                                      myHistory[
                                                                              i]
                                                                          [
                                                                          'pick_address'],
                                                                      style: GoogleFonts.roboto(
                                                                          color:
                                                                              textColor,
                                                                          fontSize:
                                                                              media.width * twelve),
                                                                    )),
                                                              ],
                                                            ),
                                                            (myHistory[i][
                                                                        'drop_address'] !=
                                                                    null)
                                                                ? Container(
                                                                    padding: EdgeInsets.only(
                                                                        top: media.width *
                                                                            0.05),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.05,
                                                                          width:
                                                                              media.width * 0.05,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: const Color(0xff319900).withOpacity(0.3)),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                media.width * 0.025,
                                                                            width:
                                                                                media.width * 0.025,
                                                                            decoration:
                                                                                const BoxDecoration(shape: BoxShape.circle, color: Color(0xff319900)),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              media.width * 0.05,
                                                                        ),
                                                                        SizedBox(
                                                                            width: media.width *
                                                                                0.7,
                                                                            child:
                                                                                Text(
                                                                              myHistory[i]['drop_address'],
                                                                              style: GoogleFonts.roboto(color: textColor, fontSize: media.width * twelve),
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container());
                                  })
                                  .values
                                  .toList(),
                            )
                          : (_isLoading == false)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: media.width * 0.05,
                                    ),
                                    Container(
                                      height: media.width * 0.7,
                                      width: media.width * 0.7,
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/nodatafound.gif'),
                                              fit: BoxFit.contain)),
                                    ),
                                    SizedBox(
                                      height: media.width * 0.02,
                                    ),
                                    SizedBox(
                                      width: media.width * 0.9,
                                      child: Text(
                                        languages[choosenLanguage]
                                            ['text_noDataFound'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            fontWeight: FontWeight.bold,
                                            color: textColor),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                )
                              : Container(),
                      //load more button
                      (myHistoryPage['pagination'] != null)
                          ? (myHistoryPage['pagination']['current_page'] <
                                  myHistoryPage['pagination']['total_pages'])
                              ? InkWell(
                                  onTap: () async {
                                    dynamic val;
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    if (_showHistory == 0) {
                                      val = await getHistoryPages(
                                          'is_later=1&page=${myHistoryPage['pagination']['current_page'] + 1}');
                                    } else if (_showHistory == 1) {
                                      val = await getHistoryPages(
                                          'is_completed=1&page=${myHistoryPage['pagination']['current_page'] + 1}');
                                    } else if (_showHistory == 2) {
                                      val = await getHistoryPages(
                                          'is_cancelled=1&page=${myHistoryPage['pagination']['current_page'] + 1}');
                                    }
                                    if (val == 'logout') {
                                      navigateLogout();
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(media.width * 0.025),
                                    margin: EdgeInsets.only(
                                        bottom: media.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: page,
                                        border: Border.all(
                                            color: borderLines, width: 1.2)),
                                    child: Text(
                                      languages[choosenLanguage]
                                          ['text_loadmore'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * sixteen,
                                          color: textColor),
                                    ),
                                  ),
                                )
                              : Container()
                          : Container()
                    ],
                  ),
                ))
              ],
            ),
          ),

          //no internet
          (internet == false)
              ? Positioned(
                  top: 0,
                  child: NoInternet(
                    onTap: () {
                      setState(() {
                        internetTrue();
                      });
                    },
                  ))
              : Container(),

          //loader
          (_isLoading == true)
              ? const Positioned(top: 0, child: Loading())
              : Container()
        ],
      ),
    ));
  }
}
