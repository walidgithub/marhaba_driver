import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/pages/NavigatorPages/about.dart';
import 'package:tagxidriver/pages/NavigatorPages/bankdetails.dart';
import 'package:tagxidriver/pages/NavigatorPages/driverdetails.dart';
import 'package:tagxidriver/pages/NavigatorPages/driverearnings.dart';
import 'package:tagxidriver/pages/NavigatorPages/editprofile.dart';
import 'package:tagxidriver/pages/NavigatorPages/faq.dart';
import 'package:tagxidriver/pages/NavigatorPages/history.dart';
import 'package:tagxidriver/pages/NavigatorPages/makecomplaint.dart';
import 'package:tagxidriver/pages/NavigatorPages/myroutebookings.dart';
import 'package:tagxidriver/pages/NavigatorPages/referral.dart';
import 'package:tagxidriver/pages/NavigatorPages/selectlanguage.dart';
import 'package:tagxidriver/pages/NavigatorPages/sos.dart';
import 'package:tagxidriver/pages/NavigatorPages/updatevehicle.dart';
import 'package:tagxidriver/pages/NavigatorPages/walletpage.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/signupmethod.dart';
import 'package:tagxidriver/pages/onTripPage/map_page.dart';
import 'package:tagxidriver/pages/vehicleInformations/upload_docs.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';
import 'package:tagxidriver/widgets/widgets.dart';

import '../NavigatorPages/fleetdetails.dart';
import '../NavigatorPages/managevehicles.dart';
import '../NavigatorPages/notification.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);
  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  bool _isLoading = false;
  String _error = '';

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

  themefun() {
    if (isDarkTheme == true) {
      isDarkTheme = false;
      page = Colors.black;
      textColor = Colors.white;
      buttonColor = Colors.white;
      loaderColor = Colors.white;
      buttonText = Colors.black;
    } else {
      isDarkTheme = true;
      page = Colors.white;
      textColor = Colors.black;
      buttonColor = theme;
      loaderColor = theme;
      buttonText = const Color(0xffFFFFFF);
    }
    darktheme();

    pref.setBool('isDarkTheme', isDarkTheme);
    valueNotifierHome.incrementNotifier();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: valueNotifierHome.value,
        builder: (context, value, child) {
          return Stack(
            children: [
              Directionality(
                textDirection: (languageDirection == 'rtl')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: media.width * 1,
                  height: media.height * 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: media.width * 0.8,
                        child: Directionality(
                          textDirection: (languageDirection == 'rtl')
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: Drawer(
                              backgroundColor: page,
                              child: SizedBox(
                                width: media.width * 0.7,
                                child: SingleChildScrollView(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: media.width * 0.05 +
                                              MediaQuery.of(context)
                                                  .padding
                                                  .top,
                                        ),
                                        SizedBox(
                                          width: media.width * 0.7,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: media.width * 0.2,
                                                width: media.width * 0.2,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey,
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            userDetails[
                                                                    'profile_picture']
                                                                .toString()),
                                                        fit: BoxFit.cover)),
                                              ),
                                              SizedBox(
                                                width: media.width * 0.025,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: media.width * 0.45,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              media.width * 0.3,
                                                          child: Text(
                                                            userDetails['name'],
                                                            style: GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    eighteen,
                                                                color:
                                                                    textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        //edit profile
                                                        InkWell(
                                                          onTap: () async {
                                                            var val = await Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const EditProfile()));
                                                            if (val != null) {
                                                              if (val) {
                                                                setState(() {});
                                                              }
                                                            }
                                                          },
                                                          child: Icon(
                                                            Icons.edit,
                                                            size: media.width *
                                                                eighteen,
                                                            color: textColor,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.01,
                                                  ),
                                                  SizedBox(
                                                    width: media.width * 0.45,
                                                    child: Text(
                                                      userDetails['email'],
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  fourteen,
                                                          color: textColor),
                                                      maxLines: 1,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        ValueListenableBuilder(
                                            valueListenable:
                                                valueNotifierNotification.value,
                                            builder: (context, value, child) {
                                              return Container(
                                                padding: EdgeInsets.only(
                                                    top: media.width * 0.02),
                                                width: media.width * 0.7,
                                                child: Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: () async {
                                                        themefun();
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets
                                                                .all(media
                                                                        .width *
                                                                    0.025),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  isDarkTheme
                                                                      ? Icons
                                                                          .brightness_4_outlined
                                                                      : Icons
                                                                          .brightness_3_rounded,
                                                                  size: media
                                                                          .width *
                                                                      0.075,
                                                                  color:
                                                                      textColor,
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.025,
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.35,
                                                                  child: Text(
                                                                    languages[
                                                                            choosenLanguage]
                                                                        [
                                                                        'text_select_theme'],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                sixteen,
                                                                        color:
                                                                            textColor),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Switch(
                                                              value:
                                                                  isDarkTheme,
                                                              onChanged:
                                                                  (toggle) async {
                                                                themefun();
                                                              }),
                                                        ],
                                                      ),
                                                    ),

                                                    //my route bookings
                                                    userDetails['role'] !=
                                                                'owner' &&
                                                            userDetails[
                                                                    'enable_my_route_booking_feature'] ==
                                                                "1"
                                                        ? InkWell(
                                                            onTap: () async {
                                                              var nav = await Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const MyRouteBooking()));
                                                              if (nav != null) {
                                                                if (nav) {
                                                                  setState(
                                                                      () {});
                                                                }
                                                              }
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .all(media
                                                                              .width *
                                                                          0.025),
                                                                  child: Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/images/myroute.png',
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        width: media.width *
                                                                            0.075,
                                                                        color:
                                                                            textColor,
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.025,
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.45,
                                                                        child:
                                                                            Text(
                                                                          languages[choosenLanguage]
                                                                              [
                                                                              'text_my_route'],
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: media.width * sixteen,
                                                                              color: textColor),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),

                                                                // SizedBox(width: media.width*0.05,),
                                                                if (userDetails[
                                                                        'my_route_address'] !=
                                                                    null)
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        _isLoading =
                                                                            true;
                                                                      });
                                                                      var dist = calculateDistance(
                                                                          center
                                                                              .latitude,
                                                                          center
                                                                              .longitude,
                                                                          double.parse(userDetails['my_route_lat']
                                                                              .toString()),
                                                                          double.parse(
                                                                              userDetails['my_route_lng'].toString()));

                                                                      if (dist >
                                                                              5000.0 ||
                                                                          userDetails['enable_my_route_booking'] ==
                                                                              "1") {
                                                                        var val = await enableMyRouteBookings(
                                                                            center.latitude,
                                                                            center.longitude);
                                                                        if (val ==
                                                                            'logout') {
                                                                          navigateLogout();
                                                                        } else if (val !=
                                                                            'success') {
                                                                          setState(
                                                                              () {
                                                                            _error =
                                                                                val;
                                                                          });
                                                                        }
                                                                      } else {
                                                                        _error =
                                                                            languages[choosenLanguage]['text_myroute_warning'];
                                                                      }

                                                                      setState(
                                                                          () {
                                                                        _isLoading =
                                                                            false;
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding: EdgeInsets.only(
                                                                          left: media.width *
                                                                              0.005,
                                                                          right:
                                                                              media.width * 0.005),
                                                                      height: media
                                                                              .width *
                                                                          0.05,
                                                                      width: media
                                                                              .width *
                                                                          0.1,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(media.width *
                                                                                0.025),
                                                                        color: (userDetails['enable_my_route_booking'] ==
                                                                                1)
                                                                            ? Colors.green.withOpacity(0.4)
                                                                            : Colors.grey.withOpacity(0.6),
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment: (userDetails['enable_my_route_booking'] ==
                                                                                1)
                                                                            ? MainAxisAlignment.end
                                                                            : MainAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                media.width * 0.045,
                                                                            width:
                                                                                media.width * 0.045,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: (userDetails['enable_my_route_booking'] == 1) ? Colors.green : Colors.grey,
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                              ],
                                                            ),
                                                          )
                                                        : Container(),
                                                    //notification
                                                    if (userDetails['role'] ==
                                                        'driver')
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const NotificationPage()));
                                                          setState(() {
                                                            userDetails[
                                                                'notifications_count'] = 0;
                                                          });
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/images/notification.png',
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    width: media
                                                                            .width *
                                                                        0.075,
                                                                    color:
                                                                        textColor,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.49,
                                                                    child: Text(
                                                                      languages[choosenLanguage]
                                                                              [
                                                                              'text_notification']
                                                                          .toString(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            (userDetails[
                                                                        'notifications_count'] ==
                                                                    0)
                                                                ? Container()
                                                                : Container(
                                                                    height: 20,
                                                                    width: 20,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color:
                                                                          buttonColor,
                                                                    ),
                                                                    child: Text(
                                                                      userDetails[
                                                                              'notifications_count']
                                                                          .toString(),
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              fourteen,
                                                                          color:
                                                                              buttonText),
                                                                    ),
                                                                  )
                                                          ],
                                                        ),
                                                      ),
                                                    //history
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const History()));
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            media.width *
                                                                0.025),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                              'assets/images/history.png',
                                                              fit: BoxFit
                                                                  .contain,
                                                              width:
                                                                  media.width *
                                                                      0.075,
                                                              color: textColor,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.55,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_enable_history'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    //wallet
                                                    userDetails['owner_id'] ==
                                                                null &&
                                                            userDetails[
                                                                    'show_wallet_feature_on_mobile_app'] ==
                                                                "1"
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const WalletPage()));
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                      'assets/images/walletImage.png',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      width: media
                                                                              .width *
                                                                          0.075,
                                                                      color:
                                                                          textColor),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.55,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_enable_wallet'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),

                                                    //referral
                                                    userDetails['owner_id'] ==
                                                                null &&
                                                            userDetails[
                                                                    'role'] ==
                                                                'driver'
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const ReferralPage()));
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                      'assets/images/referral.png',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      width: media
                                                                              .width *
                                                                          0.075,
                                                                      color:
                                                                          textColor),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.55,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_enable_referal'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),

                                                    //manage vehicle

                                                    userDetails['role'] ==
                                                            'owner'
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const ManageVehicles()));
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                      'assets/images/updateVehicleInfo.png',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      width: media
                                                                              .width *
                                                                          0.075,
                                                                      color:
                                                                          textColor),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.55,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_manage_vehicle'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),

                                                    //manage Driver

                                                    userDetails['role'] ==
                                                            'owner'
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const DriverList()));
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/images/managedriver.png',
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    width: media
                                                                            .width *
                                                                        0.075,
                                                                    color:
                                                                        textColor,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.55,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_manage_drivers'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    //update vehicles

                                                    userDetails['owner_id'] ==
                                                                null &&
                                                            userDetails[
                                                                    'role'] ==
                                                                'driver'
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const UpdateVehicle()));
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                      'assets/images/updateVehicleInfo.png',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      width: media
                                                                              .width *
                                                                          0.075,
                                                                      color:
                                                                          textColor),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.55,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_updateVehicle'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    //fleet details
                                                    userDetails['owner_id'] !=
                                                                null &&
                                                            userDetails[
                                                                    'role'] ==
                                                                'driver'
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const FleetDetails()));
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                      'assets/images/updateVehicleInfo.png',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      width: media
                                                                              .width *
                                                                          0.075,
                                                                      color:
                                                                          textColor),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.55,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_fleet_details'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    //earnings
                                                    userDetails['owner_id'] ==
                                                            null
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const DriverEarnings()));
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/images/Earnings.png',
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    width: media
                                                                            .width *
                                                                        0.075,
                                                                    color:
                                                                        textColor,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.55,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_earnings'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),

                                                    //documents
                                                    InkWell(
                                                      onTap: () async {
                                                        var nav = await Navigator
                                                            .push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Docs(
                                                                              fromPage: '2',
                                                                            )));
                                                        if (nav) {
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            media.width *
                                                                0.025),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                                'assets/images/manageDocuments.png',
                                                                fit: BoxFit
                                                                    .contain,
                                                                width: media
                                                                        .width *
                                                                    0.075,
                                                                color:
                                                                    textColor),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.55,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_manage_docs'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    //faq
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const Faq()));
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            media.width *
                                                                0.025),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                                'assets/images/faq.png',
                                                                fit: BoxFit
                                                                    .contain,
                                                                width: media
                                                                        .width *
                                                                    0.075,
                                                                color:
                                                                    textColor),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.55,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_faq'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    //sos
                                                    userDetails['role'] !=
                                                            'owner'
                                                        ? InkWell(
                                                            onTap: () async {
                                                              var nav = await Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const Sos()));

                                                              if (nav) {
                                                                setState(() {});
                                                              }
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                      'assets/images/sos.png',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      width: media
                                                                              .width *
                                                                          0.075,
                                                                      color:
                                                                          textColor),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.55,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_sos'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),

                                                    //language
                                                    InkWell(
                                                      onTap: () async {
                                                        var nav = await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const SelectLanguage()));
                                                        if (nav) {
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            media.width *
                                                                0.025),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                              'assets/images/changeLanguage.png',
                                                              fit: BoxFit
                                                                  .contain,
                                                              width:
                                                                  media.width *
                                                                      0.075,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.55,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_change_language'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    //bank details
                                                    userDetails['owner_id'] ==
                                                                null &&
                                                            userDetails[
                                                                    'show_bank_info_feature_on_mobile_app'] ==
                                                                "1"
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const BankDetails()));
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .account_balance,
                                                                      size: media
                                                                              .width *
                                                                          0.075,
                                                                      color:
                                                                          textColor),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.55,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_updateBank'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    //make complaints
                                                    InkWell(
                                                      onTap: () async {
                                                        var nav = await Navigator
                                                            .push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            MakeComplaint(
                                                                              fromPage: 0,
                                                                            )));
                                                        if (nav) {
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            media.width *
                                                                0.025),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                                'assets/images/makecomplaint.png',
                                                                fit: BoxFit
                                                                    .contain,
                                                                width: media
                                                                        .width *
                                                                    0.075,
                                                                color:
                                                                    textColor),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.55,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_make_complaints'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    //about
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const About()));
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            media.width *
                                                                0.025),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .info_outline,
                                                              size:
                                                                  media.width *
                                                                      0.075,
                                                              color: textColor,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.55,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_about'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    //delete account
                                                    userDetails['owner_id'] ==
                                                            null
                                                        ? InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                deleteAccount =
                                                                    true;
                                                              });
                                                              valueNotifierHome
                                                                  .incrementNotifier();
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.025),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .delete_forever,
                                                                      size: media
                                                                              .width *
                                                                          0.075,
                                                                      color:
                                                                          textColor),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.55,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_delete_account'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),

                                                    //logout
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          logout = true;
                                                        });
                                                        valueNotifierHome
                                                            .incrementNotifier();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            media.width *
                                                                0.025),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                                'assets/images/logout.png',
                                                                fit: BoxFit
                                                                    .contain,
                                                                width: media
                                                                        .width *
                                                                    0.075,
                                                                color:
                                                                    textColor),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.55,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_logout'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            })
                                      ]),
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              (_error != '')
                  ? Positioned(
                      top: 0,
                      child: Container(
                        height: media.height * 1,
                        width: media.width * 1,
                        // color: Colors.transparent.withOpacity(0.6),
                        color: (isDarkTheme == true)
                            ? textColor.withOpacity(0.2)
                            : Colors.transparent.withOpacity(0.6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(media.width * 0.05),
                              width: media.width * 0.9,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: page),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: media.width * 0.8,
                                    child: Text(
                                      _error.toString(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * sixteen,
                                          color: textColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    height: media.width * 0.05,
                                  ),
                                  Button(
                                      onTap: () async {
                                        setState(() {
                                          _error = '';
                                        });
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_ok'])
                                ],
                              ),
                            )
                          ],
                        ),
                      ))
                  : Container(),
              if (_isLoading == true) const Positioned(child: Loading())
            ],
          );
        });
  }
}
