import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/pages/NavigatorPages/adddriver.dart';
import 'package:tagxidriver/pages/login/signupmethod.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';

class DriverList extends StatefulWidget {
  const DriverList({Key? key}) : super(key: key);

  @override
  State<DriverList> createState() => _DriverListState();
}

class _DriverListState extends State<DriverList> {
  bool _isLoading = true;
  String isclickmenu = '';

  @override
  void initState() {
    getdriverdata();
    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

  getdriverdata() async {
    var val = await fleetDriverDetails();
    if (val == 'logout') {
      navigateLogout();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  driverdeletepopup(media, driverid) {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: (isDarkTheme == true)
            ? textColor.withOpacity(0.2)
            : Colors.transparent.withOpacity(0.6),
        builder: (context) {
          return AlertDialog(
            backgroundColor: (isDarkTheme == true) ? Colors.black : topBar,
            content: Container(
              width: media.width * 0.8,
              // color: Colors.white,
              color: (isDarkTheme == true) ? Colors.black : topBar,
              child: Text(
                languages[choosenLanguage]['text_delete_confirmation'],
                style: GoogleFonts.roboto(
                    fontSize: media.width * sixteen,
                    // color: textColor,
                    color: (isDarkTheme == true) ? Colors.white : textColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              Button(
                width: media.width * 0.2,
                height: media.width * 0.09,
                onTap: () {
                  Navigator.pop(context);
                },
                text: languages[choosenLanguage]['text_no'],
              ),
              Button(
                  width: media.width * 0.2,
                  height: media.width * 0.09,
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() {
                      _isLoading = true;
                    });
                    var val = await deletefleetdriver(driverid);
                    if (val == 'logout') {
                      navigateLogout();
                    }

                    getdriverdata();
                  },
                  text: languages[choosenLanguage]['text_yes']),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
        child: Directionality(
            textDirection: (languageDirection == 'rtl')
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Stack(children: [
              Container(
                  padding: EdgeInsets.fromLTRB(
                      media.width * 0.05,
                      MediaQuery.of(context).padding.top + media.width * 0.05,
                      media.width * 0.05,
                      0),
                  height: media.height * 1,
                  width: media.width * 1,
                  color: page,
                  //history details
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding:
                                EdgeInsets.only(bottom: media.width * 0.05),
                            width: media.width * 0.9,
                            alignment: Alignment.center,
                            child: Text(
                              languages[choosenLanguage]['text_manage_drivers'],
                              style: GoogleFonts.roboto(
                                  color: textColor,
                                  fontSize: media.width * sixteen,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child:
                                      Icon(Icons.arrow_back, color: textColor)))
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: fleetdriverList.isNotEmpty
                              ? Column(
                                  children: [
                                    for (var i = 0;
                                        i < fleetdriverList.length;
                                        i++)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: media.width * 0.01,
                                            left: media.width * 0.01,
                                            bottom: media.width * 0.03),
                                        child: Stack(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isclickmenu = '';
                                                });
                                              },
                                              child: Container(
                                                height: media.width * 0.3,
                                                width: media.width,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  // color: Colors.white,
                                                  color: (isDarkTheme == true)
                                                      ? Colors.black
                                                      : topBar,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.grey,
                                                      offset: Offset(
                                                          0.0, 1.0), //(x,y)
                                                      blurRadius: 5.0,
                                                    ),
                                                  ],
                                                ),
                                                child: Row(children: [
                                                  Expanded(
                                                      flex: 35,
                                                      child: Container(
                                                        height:
                                                            media.width * 0.3,
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: media
                                                                        .width *
                                                                    0.01,
                                                                right: media
                                                                        .width *
                                                                    0.01),
                                                        decoration:
                                                            BoxDecoration(
                                                          // color: Colors.white,
                                                          color: (isDarkTheme ==
                                                                  true)
                                                              ? Colors.black
                                                              : topBar,
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              offset: Offset(
                                                                  0.0,
                                                                  1.0), //(x,y)
                                                              blurRadius: 8.0,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Container(
                                                              height:
                                                                  media.width *
                                                                      0.24,
                                                              width:
                                                                  media.width *
                                                                      0.24,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                        image:
                                                                            NetworkImage(
                                                                          fleetdriverList[i]['profile_picture']
                                                                              .toString(),
                                                                        ),
                                                                        fit: BoxFit
                                                                            .cover),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                              ),
                                                            ),
                                                            Text(
                                                              fleetdriverList[i]
                                                                      ['name']
                                                                  .toString(),
                                                              maxLines: 1,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    sixteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    textColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 65,
                                                      child: Container(
                                                          padding: EdgeInsets.only(
                                                              left:
                                                                  media.width *
                                                                      0.05,
                                                              right:
                                                                  media.width *
                                                                      0.03),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  fleetdriverList[
                                                                              i]
                                                                          [
                                                                          'mobile']
                                                                      .toString(),
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    color:
                                                                        textColor,
                                                                  )),
                                                              if (fleetdriverList[
                                                                              i]
                                                                          [
                                                                          'car_number']
                                                                      .toString() ==
                                                                  'null')
                                                                Container(
                                                                    height: media
                                                                            .width *
                                                                        0.1,
                                                                    width: media
                                                                            .width *
                                                                        0.2,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image: DecorationImage(
                                                                          image: const AssetImage(
                                                                              'assets/images/disablecar.png'),
                                                                          colorFilter: ColorFilter.mode(
                                                                              Colors.white.withOpacity(0.2),
                                                                              BlendMode.dstATop),
                                                                          fit: BoxFit.contain),
                                                                    )),

                                                              // ignore: unnecessary_null_comparison
                                                              fleetdriverList[i]
                                                                              [
                                                                              'car_number']
                                                                          .toString() ==
                                                                      'null'
                                                                  ? fleetdriverList[i]
                                                                              [
                                                                              'approve'] ==
                                                                          false
                                                                      ? Container(
                                                                          // width:
                                                                          //     media.width * 0.4,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          padding:
                                                                              EdgeInsets.all(media.width * 0.01),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            // border: Border.all(
                                                                            //     color: Colors.yellow,
                                                                            //     width: 2),
                                                                            color:
                                                                                buttonColor,
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            languages[choosenLanguage]['text_waiting_approval'],
                                                                            style:
                                                                                GoogleFonts.roboto(
                                                                              fontSize: media.width * fourteen,
                                                                              color: (isDarkTheme == true) ? Colors.black : buttonText,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Text(
                                                                          languages[choosenLanguage]
                                                                              [
                                                                              'text_fleet_not_assigned'],
                                                                          style: GoogleFonts
                                                                              .roboto(
                                                                            fontSize:
                                                                                media.width * fourteen,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                textColor,
                                                                          ))
                                                                  : Text(
                                                                      fleetdriverList[i]
                                                                              [
                                                                              'car_number']
                                                                          .toString(),
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                fourteen,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            textColor,
                                                                      )),
                                                              fleetdriverList[i]
                                                                              [
                                                                              'car_make_name']
                                                                          .toString() ==
                                                                      'null'
                                                                  ? Container()
                                                                  : Text(
                                                                      '${fleetdriverList[i]['car_make_name']},${fleetdriverList[i]['car_model_name']}',
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                fourteen,
                                                                        color:
                                                                            textColor,
                                                                      )),
                                                              if (fleetdriverList[
                                                                          i][
                                                                      'vehicle_type_icon'] !=
                                                                  null)
                                                                Container(
                                                                    height:
                                                                        media.width *
                                                                            0.1,
                                                                    width: media
                                                                            .width *
                                                                        0.2,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image: DecorationImage(
                                                                          image: NetworkImage(
                                                                            fleetdriverList[i]['vehicle_type_icon'].toString(),
                                                                          ),
                                                                          fit: BoxFit.cover),
                                                                    )),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      driverdeletepopup(
                                                                          media,
                                                                          fleetdriverList[i]
                                                                              [
                                                                              'id']);
                                                                    },
                                                                    child: Text(
                                                                        languages[choosenLanguage]
                                                                            [
                                                                            'text_delete_driver'],
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              media.width * twelve,
                                                                          color:
                                                                              inputFieldSeparator,
                                                                        )),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ))),
                                                ]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    SizedBox(
                                      height: media.width * 0.02,
                                    ),
                                  ],
                                )
                              : (_isLoading == false)
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: media.width * 0.3,
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
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(media.width * 0.05),
                        child: Button(
                            onTap: () async {
                              var nav = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddDriver()));
                              if (nav != null) {
                                if (nav) {
                                  await getdriverdata();
                                }
                              }
                            },
                            text: languages[choosenLanguage]
                                ['text_add_driver']),
                      ),
                    ],
                  )),
              (_isLoading == true)
                  ? const Positioned(top: 0, child: Loading())
                  : Container(),
            ])));
  }
}
