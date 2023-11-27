import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/pages/login/signupmethod.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';

class AssignDriver extends StatefulWidget {
  final String? fleetid;
  final int? i;
  const AssignDriver({Key? key, required this.fleetid, required this.i})
      : super(key: key);

  @override
  State<AssignDriver> createState() => _AssignDriverState();
}

class _AssignDriverState extends State<AssignDriver> {
  String isassigndriver = '';
  int? driverid;
  bool _isLoadingassigndriver = true;
  bool _showToast = false;

  @override
  void initState() {
    getdriverdata();
    isassigndriver = '';

    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

  getdriverdata() async {
    var val =
        await fleetDriverDetails(fleetid: widget.fleetid, isassigndriver: true);
    if (val == 'logout') {
      navigateLogout();
    } else {
      var val = await getVehicleInfo();
      if (val == 'logout') {
        navigateLogout();
      }
    }
    if (mounted) {
      setState(() {
        // if (_isLoadingassigndriver == true) {
        //   showToast();
        // }
        _isLoadingassigndriver = false;
      });
    }
  }

  showToast() {
    setState(() {
      _showToast = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showToast = false;
      });
    });
  }

  String fleetid = '';

  //navigate
  pop() {
    Navigator.pop(context, true);
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
                                    Navigator.pop(context, true);
                                  },
                                  child:
                                      Icon(Icons.arrow_back, color: textColor)))
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(
                                height: media.width * 0.025,
                              ),
                              SizedBox(
                                height: media.width * 0.35,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: media.width * 0.01,
                                      left: media.width * 0.01,
                                      bottom: media.width * 0.03),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: media.width * 0.3,
                                        width: media.width,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          // color: Colors.white,
                                          color: (isDarkTheme == true)
                                              ? Colors.black
                                              : topBar,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 5.0,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 35,
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.01),
                                                  height: media.width * 0.3,
                                                  decoration: BoxDecoration(
                                                    // color: Colors.white,
                                                    color: (isDarkTheme == true)
                                                        ? Colors.black
                                                        : topBar,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.grey,
                                                        offset: Offset(
                                                            0.0, 1.0), //(x,y)
                                                        blurRadius: 8.0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      (vehicledata[widget.i!][
                                                                  'driverDetail'] !=
                                                              null)
                                                          ? Container(
                                                              height:
                                                                  media.width *
                                                                      0.20,
                                                              width:
                                                                  media.width *
                                                                      0.20,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                        image:
                                                                            NetworkImage(
                                                                          vehicledata[widget.i!]['driverDetail']['data']['profile_picture']
                                                                              .toString(),
                                                                        ),
                                                                        fit: BoxFit
                                                                            .fill),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                              ),
                                                            )
                                                          : Container(),
                                                      (vehicledata[widget.i!][
                                                                  'driverDetail'] !=
                                                              null)
                                                          ? Text(
                                                              vehicledata[widget.i!]
                                                                              [
                                                                              'driverDetail']
                                                                          [
                                                                          'data']
                                                                      ['name']
                                                                  .toString(),
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    sixteen,
                                                                color:
                                                                    textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ))
                                                          : Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_no_driver'],
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    sixteen,
                                                                color:
                                                                    textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )),
                                                    ],
                                                  ),
                                                )),
                                            Expanded(
                                                flex: 65,
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        left:
                                                            media.width * 0.05,
                                                        right:
                                                            media.width * 0.03),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (vehicledata[
                                                                    widget.i!][
                                                                'driverDetail'] !=
                                                            null)
                                                          Text(
                                                            vehicledata[widget
                                                                            .i!]
                                                                        [
                                                                        'driverDetail']
                                                                    [
                                                                    'data']['mobile']
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color: textColor,
                                                            ),
                                                          ),
                                                        Text(
                                                          vehicledata[widget.i!]
                                                                  [
                                                                  'license_number']
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontSize:
                                                                media.width *
                                                                    fourteen,
                                                            color: textColor,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${vehicledata[widget.i!]['brand']},${vehicledata[widget.i!]['model']}',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontSize:
                                                                media.width *
                                                                    fourteen,
                                                            color: textColor,
                                                          ),
                                                        ),
                                                        Container(
                                                            height:
                                                                media.width *
                                                                    0.1,
                                                            width: media.width *
                                                                0.2,
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                      image:
                                                                          NetworkImage(
                                                                        vehicledata[widget.i!]['type_icon']
                                                                            .toString(),
                                                                      ),
                                                                      fit: BoxFit
                                                                          .cover),
                                                            )),
                                                      ],
                                                    ))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: media.width * 0.01,
                                    left: media.width * 0.01,
                                    bottom: media.width * 0.03),
                                child: Text(
                                  languages[choosenLanguage]
                                      ['text_assign_new_driver'],
                                  style: GoogleFonts.roboto(
                                    fontSize: media.width * eighteen,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                child: fleetdriverList.isNotEmpty
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                        isassigndriver =
                                                            i.toString();
                                                        driverid = fleetdriverList[
                                                                int.parse(
                                                                    isassigndriver)]
                                                            ['id'];
                                                      });
                                                    },
                                                    child: Container(
                                                      height: media.width * 0.3,
                                                      width: media.width,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        // color: Colors.white,
                                                        color: (isDarkTheme ==
                                                                true)
                                                            ? Colors.black
                                                            : topBar,
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Colors.grey,
                                                            offset: Offset(0.0,
                                                                1.0), //(x,y)
                                                            blurRadius: 5.0,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 35,
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .all(media
                                                                            .width *
                                                                        0.02),
                                                                height: media
                                                                        .width *
                                                                    0.3,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  // color: Colors
                                                                  //     .white,
                                                                  color: (isDarkTheme ==
                                                                          true)
                                                                      ? Colors
                                                                          .black
                                                                      : topBar,
                                                                  borderRadius: const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          10)),
                                                                  boxShadow: const [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey,
                                                                      offset: Offset(
                                                                          0.0,
                                                                          1.0), //(x,y)
                                                                      blurRadius:
                                                                          8.0,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    Container(
                                                                      height: media
                                                                              .width *
                                                                          0.20,
                                                                      width: media
                                                                              .width *
                                                                          0.20,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image: NetworkImage(
                                                                              fleetdriverList[i]['profile_picture'].toString(),
                                                                            ),
                                                                            fit: BoxFit.fill),
                                                                        borderRadius:
                                                                            const BorderRadius.all(Radius.circular(10)),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      fleetdriverList[i]
                                                                              [
                                                                              'name']
                                                                          .toString(),
                                                                      maxLines:
                                                                          1,
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                sixteen,
                                                                        color:
                                                                            textColor,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                          Expanded(
                                                              flex: 45,
                                                              child: Container(
                                                                  padding: EdgeInsets.only(
                                                                      left: media
                                                                              .width *
                                                                          0.05,
                                                                      right: media
                                                                              .width *
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
                                                                        fleetdriverList[i]['mobile']
                                                                            .toString(),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              media.width * fourteen,
                                                                          color:
                                                                              textColor,
                                                                        ),
                                                                      ),
                                                                      // ignore: unnecessary_null_comparison
                                                                      fleetdriverList[i]['car_number'].toString() ==
                                                                              'null'
                                                                          ? Container()
                                                                          : Text(
                                                                              fleetdriverList[i]['car_number'].toString(),
                                                                              style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor, letterSpacing: 1),
                                                                            ),
                                                                      fleetdriverList[i]['car_make_name'].toString() ==
                                                                              'null'
                                                                          ? Container()
                                                                          : Text(
                                                                              '${fleetdriverList[i]['car_make_name']},${fleetdriverList[i]['car_model_name']}',
                                                                              style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor, letterSpacing: 1),
                                                                            ),

                                                                      Container(
                                                                          height: media.width *
                                                                              0.1,
                                                                          width: media.width *
                                                                              0.2,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            image: DecorationImage(
                                                                                image: NetworkImage(
                                                                                  fleetdriverList[i]['vehicle_type_icon'].toString(),
                                                                                ),
                                                                                fit: BoxFit.cover),
                                                                          )),
                                                                    ],
                                                                  ))),
                                                          Expanded(
                                                            flex: 20,
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height:
                                                                  media.width *
                                                                      0.08,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color:
                                                                      textColor,
                                                                ),
                                                              ),
                                                              child: Container(
                                                                height: media
                                                                        .width *
                                                                    0.04,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: isassigndriver ==
                                                                          i
                                                                              .toString()
                                                                      ? Colors
                                                                          .green
                                                                      : (isDarkTheme ==
                                                                              true)
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .white,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      )
                                    : (_isLoadingassigndriver == false)
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                      fontSize:
                                                          media.width * sixteen,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textColor),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            ],
                                          )
                                        : Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(media.width * 0.02),
                        child: Button(
                          onTap: () async {
                            setState(() {
                              _isLoadingassigndriver = true;
                            });

                            var result =
                                await assignDriver(driverid, widget.fleetid);
                            if (result == 'true') {
                              var val = await getVehicleInfo();
                              if (val == 'logout') {
                                navigateLogout();
                              }

                              pop();
                            } else if (result == 'logout') {
                              navigateLogout();
                            } else {
                              setState(() {
                                _isLoadingassigndriver = false;
                              });
                              showToast();
                            }
                          },
                          text: languages[choosenLanguage]
                              ['text_assign_driver'],
                        ),
                      ),
                    ],
                  )),
              (_isLoadingassigndriver == true)
                  ? const Positioned(top: 0, child: Loading())
                  : Container(),
              (_showToast == true)
                  ? Positioned(
                      bottom: media.height * 0.2,
                      left: media.width * 0.2,
                      right: media.width * 0.2,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(media.width * 0.025),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: (isDarkTheme == true)
                                ? textColor.withOpacity(0.6)
                                : Colors.transparent.withOpacity(0.6)),
                        child: Text(
                          languages[choosenLanguage]['text_select_driver'],
                          style: GoogleFonts.roboto(
                              fontSize: media.width * twelve,
                              color: Colors.white),
                        ),
                      ))
                  : Container()
            ])));
  }
}
