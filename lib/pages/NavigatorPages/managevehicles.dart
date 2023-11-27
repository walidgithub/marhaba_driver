import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/pages/NavigatorPages/assigndriver.dart';
import 'package:tagxidriver/pages/NavigatorPages/fleetdocuments.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/signupmethod.dart';
import 'package:tagxidriver/pages/vehicleInformations/vehicle_type.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';
import 'package:tagxidriver/widgets/widgets.dart';

import '../vehicleInformations/service_area.dart';

class ManageVehicles extends StatefulWidget {
  const ManageVehicles({Key? key}) : super(key: key);

  @override
  State<ManageVehicles> createState() => _ManageVehiclesState();
}

class _ManageVehiclesState extends State<ManageVehicles> {
  bool _isLoading = true;
  String isclickmenu = '';
  String fleetid = '';

  @override
  void initState() {
    getvehicledata();
    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

  getvehicledata() async {
    isclickmenu = '';
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    var val = await getVehicleInfo();
    if (val == 'logout') {
      navigateLogout();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.popUntil(context, (route) => route.isFirst);

        return true;
      },
      child: Material(
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Stack(
            children: [
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
                          padding: EdgeInsets.only(bottom: media.width * 0.05),
                          width: media.width * 0.9,
                          alignment: Alignment.center,
                          child: Text(
                            languages[choosenLanguage]['text_manage_vehicle'],
                            style: GoogleFonts.roboto(
                                color: textColor,
                                fontSize: media.width * sixteen,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                            child: InkWell(
                                onTap: () {
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                  // Navigator.popUntil(
                                  //     context, (route) => route is VehicleColor);
                                },
                                child:
                                    Icon(Icons.arrow_back, color: textColor)))
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: vehicledata.isNotEmpty
                            ? Column(
                                children: [
                                  for (var i = 0; i < vehicledata.length; i++)
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
                                                    BorderRadius.circular(10.0),
                                                color: page,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(
                                                        0.0, 1.0), //(x,y)
                                                    blurRadius: 5.0,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 35,
                                                      child: Container(
                                                        height:
                                                            media.width * 0.3,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: page,
                                                          borderRadius:
                                                              (languageDirection ==
                                                                      'rtl')
                                                                  ? const BorderRadius
                                                                      .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              10),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10),
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              60),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              60),
                                                                    )
                                                                  : const BorderRadius
                                                                      .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              60),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              60),
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              10),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              10),
                                                                    ),
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
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                                flex: 5,
                                                                child:
                                                                    Container(
                                                                  width: media
                                                                          .width *
                                                                      0.2,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image: DecorationImage(
                                                                        image: NetworkImage(
                                                                          vehicledata[i]['type_icon']
                                                                              .toString(),
                                                                        ),
                                                                        fit: BoxFit.cover),
                                                                    borderRadius: (languageDirection ==
                                                                            'rtl')
                                                                        ? const BorderRadius
                                                                            .only(
                                                                            topLeft:
                                                                                Radius.circular(30),
                                                                          )
                                                                        : const BorderRadius
                                                                            .only(
                                                                            topRight:
                                                                                Radius.circular(30),
                                                                          ),
                                                                  ),
                                                                )),
                                                            Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                  vehicledata[i]
                                                                          [
                                                                          'license_number']
                                                                      .toString(),
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    color:
                                                                        textColor,
                                                                  ),
                                                                )),
                                                            Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                  vehicledata[i]
                                                                          [
                                                                          'brand']
                                                                      .toString(),
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    color:
                                                                        textColor,
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 57,
                                                      child: Stack(
                                                        children: [
                                                          vehicledata[i]['approve']
                                                                      .toString() ==
                                                                  '1'
                                                              ? Center(
                                                                  child:
                                                                      Container(
                                                                    decoration: const BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        image: DecorationImage(
                                                                            image: AssetImage(
                                                                                'assets/images/approved.png'),
                                                                            opacity:
                                                                                0.4,
                                                                            fit:
                                                                                BoxFit.contain)),
                                                                    height: media
                                                                            .width *
                                                                        0.15,
                                                                    width: media
                                                                            .width *
                                                                        0.15,
                                                                  ),
                                                                )
                                                              : Center(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      Container(
                                                                        decoration: const BoxDecoration(
                                                                            shape: BoxShape
                                                                                .circle,
                                                                            image: DecorationImage(
                                                                                image: AssetImage('assets/images/wait.png'),
                                                                                opacity: 0.4,
                                                                                fit: BoxFit.contain)),
                                                                        height: media.width *
                                                                            0.15,
                                                                        width: media.width *
                                                                            0.15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          Positioned(
                                                              left:
                                                                  media.width *
                                                                      0.05,
                                                              child: SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.27,
                                                                child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      vehicledata[i]['driverDetail'] !=
                                                                              null
                                                                          ? Text(
                                                                              vehicledata[i]['driverDetail']['data']['name'].toString(),
                                                                              style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor, fontWeight: FontWeight.bold))
                                                                          : Container(),
                                                                      vehicledata[i]['driverDetail'] !=
                                                                              null
                                                                          ? Text(
                                                                              vehicledata[i]['driverDetail']['data']['mobile'].toString(),
                                                                              style: GoogleFonts.roboto(
                                                                                fontSize: media.width * fourteen,
                                                                                color: textColor,
                                                                              ))
                                                                          : Container(),
                                                                      Text(
                                                                          vehicledata[i]['model']
                                                                              .toString(),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: media.width * fourteen,
                                                                              color: textColor,
                                                                              fontWeight: FontWeight.bold)),
                                                                      if (vehicledata[i]
                                                                              [
                                                                              'driverDetail'] ==
                                                                          null)
                                                                        Text(
                                                                            languages[choosenLanguage][
                                                                                'text_driver_not_assigned'],
                                                                            style: GoogleFonts.roboto(
                                                                                fontSize: media.width * sixteen,
                                                                                color: textColor,
                                                                                fontWeight: FontWeight.bold)),
                                                                      if (vehicledata[i]['driverDetail'] ==
                                                                              null &&
                                                                          vehicledata[i]['approve'].toString() ==
                                                                              '0')
                                                                        Container(
                                                                          // width: media.width *
                                                                          //     0.4,
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
                                                                    ]),
                                                              ))
                                                        ],
                                                      )),
                                                  Expanded(
                                                      flex: 8,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  if (isclickmenu ==
                                                                      i.toString()) {
                                                                    isclickmenu =
                                                                        '';
                                                                  } else {
                                                                    isclickmenu =
                                                                        i.toString();
                                                                  }
                                                                  fleetid = vehicledata[
                                                                      int.parse(
                                                                          isclickmenu)]['id'];
                                                                });
                                                              },
                                                              child: Icon(
                                                                Icons.more_vert,
                                                                color:
                                                                    textColor,
                                                                size: 30,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                          isclickmenu == i.toString()
                                              ? Positioned(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        height:
                                                            media.width * 0.3,
                                                        width:
                                                            media.width * 0.3,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          color: page,
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              offset: Offset(
                                                                  0.0,
                                                                  1.0), //(x,y)
                                                              blurRadius: 5.0,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          // crossAxisAlignment:
                                                          //     CrossAxisAlignment
                                                          //         .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            if (vehicledata[i][
                                                                        'approve']
                                                                    .toString() !=
                                                                '0')
                                                              MenuClass(
                                                                ontap:
                                                                    () async {
                                                                  var nav = await Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => AssignDriver(
                                                                                fleetid: fleetid,
                                                                                i: i,
                                                                              )));
                                                                  if (nav !=
                                                                      null) {
                                                                    if (nav) {
                                                                      isclickmenu =
                                                                          '';
                                                                      getvehicledata();
                                                                    }
                                                                  }
                                                                },
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_assign_driver'],
                                                              ),
                                                            MenuClass(
                                                              ontap: () async {
                                                                var nav = await Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                FleetDocuments(fleetid: fleetid)));
                                                                if (nav !=
                                                                    null) {
                                                                  if (nav) {
                                                                    setState(
                                                                        () {
                                                                      isclickmenu =
                                                                          '';
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                              text: languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_upload_doc'],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              )
                            : (_isLoading == false)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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

                    //add vehicles
                    Container(
                      padding: EdgeInsets.all(media.width * 0.05),
                      child: Button(
                          onTap: () {
                            myServiceId = userDetails['service_location_id'];
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const VehicleType()));
                          },
                          text: languages[choosenLanguage]['text_add_vehicle']),
                    ),
                  ],
                ),
              ),

              //loader
              (_isLoading == true)
                  ? const Positioned(top: 0, child: Loading())
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}

class MenuClass extends StatelessWidget {
  final String text;
  final void Function() ontap;
  const MenuClass({Key? key, required this.text, required this.ontap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Padding(
      padding:
          EdgeInsets.only(left: media.width * 0.03, top: media.width * 0.01),
      child: InkWell(
        onTap: ontap,
        child: SizedBox(
          width: media.width * 0.3,
          height: media.width * 0.08,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: media.width * fourteen,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
