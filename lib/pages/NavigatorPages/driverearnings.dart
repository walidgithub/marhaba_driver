import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/signupmethod.dart';
import 'package:tagxidriver/pages/noInternet/nointernet.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';

import 'package:tagxidriver/widgets/widgets.dart';

class DriverEarnings extends StatefulWidget {
  const DriverEarnings({Key? key}) : super(key: key);

  @override
  State<DriverEarnings> createState() => _DriverEarningsState();
}

class _DriverEarningsState extends State<DriverEarnings> {
  bool _isLoading = true;
  int _showEarning = 0;
  int _pickDate = 0;
  dynamic fromDate;
  dynamic toDate;
  dynamic _fromDate, _toDate;

  @override
  void initState() {
    getEarnings();
    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

//getting earnings data
  getEarnings() async {
    driverTodayEarnings.clear();
    var val = await driverTodayEarning();
    if (mounted) {
      if (val == 'logout') {
        navigateLogout();
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  _datePicker() async {
    DateTime? picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: (_pickDate == 2) ? fromDate : DateTime(2020),
        lastDate: DateTime.now());
    if (picker != null) {
      setState(() {
        if (_pickDate == 1) {
          fromDate = picker;
          _fromDate = picker.toString().split(" ")[0];
          toDate = null;
          _toDate = null;
        } else if (_pickDate == 2) {
          toDate = picker;
          _toDate = picker.toString().split(" ")[0];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(media.width * 0.05,
                  media.width * 0.05, media.width * 0.05, 0),
              height: media.height * 1,
              width: media.width * 1,
              color: page,
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
                          languages[choosenLanguage]['text_earnings'],
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
                              _showEarning = 0;
                              _isLoading = true;
                            });

                            var val = await driverTodayEarning();
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
                              width: media.width * 0.3,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: (_showEarning == 0)
                                      ? (isDarkTheme == true)
                                          ? Colors.white
                                          : const Color(0xff222222)
                                      : page),
                              child: Text(
                                languages[choosenLanguage]['text_today'],
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * fifteen,
                                    fontWeight: FontWeight.w600,
                                    color: (_showEarning == 0)
                                        ? (isDarkTheme == true)
                                            ? Colors.black
                                            : Colors.white
                                        : textColor),
                              )),
                        ),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              _showEarning = 1;
                              _isLoading = true;
                            });

                            var val = await driverWeeklyEarning();
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
                              width: media.width * 0.3,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: (_showEarning == 1)
                                      ? (isDarkTheme == true)
                                          ? Colors.white
                                          : const Color(0xff222222)
                                      : page),
                              child: Text(
                                languages[choosenLanguage]['text_weekly'],
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * fifteen,
                                    fontWeight: FontWeight.w600,
                                    color: (_showEarning == 1)
                                        ? (isDarkTheme == true)
                                            ? Colors.black
                                            : Colors.white
                                        : textColor),
                              )),
                        ),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              driverReportEarnings.clear();
                              _showEarning = 2;
                            });
                          },
                          child: Container(
                              height: media.width * 0.13,
                              alignment: Alignment.center,
                              width: media.width * 0.3,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: (_showEarning == 2)
                                      ? (isDarkTheme == true)
                                          ? Colors.white
                                          : const Color(0xff222222)
                                      : page),
                              child: Text(
                                languages[choosenLanguage]['text_report'],
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * fifteen,
                                    fontWeight: FontWeight.w600,
                                    color: (_showEarning == 2)
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
                    height: media.width * 0.05,
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: (driverTodayEarnings.isNotEmpty && _showEarning == 0)
                        ?
                        //current day earnings
                        Column(children: [
                            Text(
                              driverTodayEarnings['current_date'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * fifteen,
                                  color: (isDarkTheme == true)
                                      ? textColor.withOpacity(0.5)
                                      : hintColor),
                            ),
                            SizedBox(
                              height: media.width * 0.025,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  driverTodayEarnings['currency_symbol'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * eighteen,
                                      color: textColor),
                                ),
                                Text(
                                  driverTodayEarnings['total_earnings']
                                      .toStringAsFixed(2),
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * eighteen,
                                      color: textColor),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Container(
                              padding: EdgeInsets.all(media.width * 0.05),
                              width: media.width * 0.9,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: borderLines, width: 1.2)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: media.width * 0.17,
                                        alignment: Alignment.center,
                                        child: Text(
                                          languages[choosenLanguage]
                                              ['text_trips'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: (isDarkTheme == true)
                                                  ? textColor.withOpacity(0.5)
                                                  : hintColor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.015,
                                      ),
                                      Container(
                                        width: media.width * 0.17,
                                        alignment: Alignment.center,
                                        child: Text(
                                          driverTodayEarnings[
                                                  'total_trips_count']
                                              .toString(),
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: media.width * 0.1,
                                    color: borderLines,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        width: media.width * 0.17,
                                        alignment: Alignment.center,
                                        child: Text(
                                          languages[choosenLanguage]
                                              ['text_enable_wallet'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: (isDarkTheme == true)
                                                  ? textColor.withOpacity(0.5)
                                                  : hintColor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.015,
                                      ),
                                      Container(
                                        width: media.width * 0.17,
                                        alignment: Alignment.center,
                                        child: Text(
                                          driverTodayEarnings[
                                                  'total_wallet_trip_count']
                                              .toString(),
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: media.width * 0.1,
                                    color: borderLines,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        width: media.width * 0.17,
                                        alignment: Alignment.center,
                                        child: Text(
                                          languages[choosenLanguage]
                                              ['text_cash'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: (isDarkTheme == true)
                                                  ? textColor.withOpacity(0.5)
                                                  : hintColor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.015,
                                      ),
                                      Container(
                                        width: media.width * 0.17,
                                        alignment: Alignment.center,
                                        child: Text(
                                          driverTodayEarnings[
                                                  'total_cash_trip_count']
                                              .toString(),
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: media.width * 0.1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  languages[choosenLanguage]['text_tripkm'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * eighteen,
                                      color: textColor),
                                ),
                                Text(
                                  driverTodayEarnings['total_trip_kms']
                                      .toString(),
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * eighteen,
                                      color: textColor),
                                )
                              ],
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  languages[choosenLanguage]
                                      ['text_walletpayment'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * eighteen,
                                      color: textColor),
                                ),
                                Text(
                                  driverTodayEarnings['currency_symbol'] +
                                      driverTodayEarnings[
                                              'total_wallet_trip_amount']
                                          .toStringAsFixed(2),
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * eighteen,
                                      color: textColor),
                                )
                              ],
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  languages[choosenLanguage]
                                      ['text_cashpayment'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * eighteen,
                                      color: textColor),
                                ),
                                Text(
                                  driverTodayEarnings['currency_symbol'] +
                                      driverTodayEarnings[
                                              'total_cash_trip_amount']
                                          .toStringAsFixed(2),
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * eighteen,
                                      color: textColor),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Container(
                              height: 1,
                              width: media.width * 0.9,
                              color: borderLines,
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  languages[choosenLanguage]
                                      ['text_totalearnings'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * eighteen,
                                      color: buttonColor),
                                ),
                                Text(
                                  driverTodayEarnings['currency_symbol'] +
                                      driverTodayEarnings['total_earnings']
                                          .toStringAsFixed(2),
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * eighteen,
                                      color: buttonColor),
                                ),
                              ],
                            ),
                          ])
                        :
                        //current week earnings
                        (driverWeeklyEarnings.isNotEmpty && _showEarning == 1)
                            ? Column(children: [
                                Text(
                                  driverWeeklyEarnings['start_of_week'] +
                                      ' - ' +
                                      driverWeeklyEarnings['end_of_week'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * fifteen,
                                      color: (isDarkTheme == true)
                                          ? textColor.withOpacity(0.5)
                                          : hintColor),
                                ),
                                SizedBox(
                                  height: media.width * 0.025,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      driverWeeklyEarnings['currency_symbol'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * eighteen,
                                          color: textColor),
                                    ),
                                    Text(
                                      driverWeeklyEarnings['total_earnings']
                                          .toStringAsFixed(2),
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * eighteen,
                                          color: textColor),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                SizedBox(
                                  height: media.width * 0.5,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: weekDays
                                        .map((i, value) {
                                          List val = [];
                                          weekDays.forEach((i, value) {
                                            val.add(double.parse(
                                                weekDays[i].toString()));
                                          });
                                          val.sort();
                                          return MapEntry(
                                              i,
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    weekDays[i].toString(),
                                                    style: GoogleFonts.roboto(
                                                        fontSize: media.width *
                                                            twelve,
                                                        color: (isDarkTheme ==
                                                                true)
                                                            ? textColor
                                                                .withOpacity(
                                                                    0.5)
                                                            : hintColor),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.01,
                                                  ),
                                                  Container(
                                                    width: media.width * 0.1,
                                                    height: (val.last > 0)
                                                        ? (media.width * 0.35) /
                                                            (val.last /
                                                                double.parse(
                                                                    weekDays[i]
                                                                        .toString()))
                                                        : 1,
                                                    color: buttonColor,
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.01,
                                                  ),
                                                  Text(
                                                    i,
                                                    style: GoogleFonts.roboto(
                                                        fontSize: media.width *
                                                            twelve,
                                                        color: (isDarkTheme ==
                                                                true)
                                                            ? textColor
                                                                .withOpacity(
                                                                    0.5)
                                                            : hintColor),
                                                  )
                                                ],
                                              ));
                                        })
                                        .values
                                        .toList(),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Container(
                                  padding: EdgeInsets.all(media.width * 0.05),
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: borderLines, width: 1.2)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: media.width * 0.17,
                                            alignment: Alignment.center,
                                            child: Text(
                                              languages[choosenLanguage]
                                                  ['text_trips'],
                                              style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * sixteen,
                                                  color: (isDarkTheme == true)
                                                      ? textColor
                                                          .withOpacity(0.5)
                                                      : hintColor),
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.015,
                                          ),
                                          Container(
                                            width: media.width * 0.17,
                                            alignment: Alignment.center,
                                            child: Text(
                                              driverWeeklyEarnings[
                                                      'total_trips_count']
                                                  .toString(),
                                              style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * sixteen,
                                                  color: textColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 1,
                                        height: media.width * 0.1,
                                        color: borderLines,
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            width: media.width * 0.17,
                                            alignment: Alignment.center,
                                            child: Text(
                                              languages[choosenLanguage]
                                                  ['text_enable_wallet'],
                                              style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * sixteen,
                                                  color: (isDarkTheme == true)
                                                      ? textColor
                                                          .withOpacity(0.5)
                                                      : hintColor),
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.015,
                                          ),
                                          Container(
                                            width: media.width * 0.17,
                                            alignment: Alignment.center,
                                            child: Text(
                                              driverWeeklyEarnings[
                                                      'total_wallet_trip_count']
                                                  .toString(),
                                              style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * sixteen,
                                                  color: textColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 1,
                                        height: media.width * 0.1,
                                        color: borderLines,
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            width: media.width * 0.17,
                                            alignment: Alignment.center,
                                            child: Text(
                                              languages[choosenLanguage]
                                                  ['text_cash'],
                                              style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * sixteen,
                                                  color: (isDarkTheme == true)
                                                      ? textColor
                                                          .withOpacity(0.5)
                                                      : hintColor),
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.015,
                                          ),
                                          Container(
                                            width: media.width * 0.17,
                                            alignment: Alignment.center,
                                            child: Text(
                                              driverWeeklyEarnings[
                                                      'total_cash_trip_count']
                                                  .toString(),
                                              style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * sixteen,
                                                  color: textColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.1,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      languages[choosenLanguage]['text_tripkm'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * eighteen,
                                          color: textColor),
                                    ),
                                    Text(
                                      driverWeeklyEarnings['total_trip_kms']
                                          .toString(),
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * eighteen,
                                          color: textColor),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      languages[choosenLanguage]
                                          ['text_walletpayment'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * eighteen,
                                          color: textColor),
                                    ),
                                    Text(
                                      driverWeeklyEarnings['currency_symbol'] +
                                          driverWeeklyEarnings[
                                                  'total_wallet_trip_amount']
                                              .toStringAsFixed(2),
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * eighteen,
                                          color: textColor),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      languages[choosenLanguage]
                                          ['text_cashpayment'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * eighteen,
                                          color: textColor),
                                    ),
                                    Text(
                                      driverWeeklyEarnings['currency_symbol'] +
                                          driverWeeklyEarnings[
                                                  'total_cash_trip_amount']
                                              .toStringAsFixed(2),
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * eighteen,
                                          color: textColor),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Container(
                                  height: 1,
                                  width: media.width * 0.9,
                                  color: borderLines,
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      languages[choosenLanguage]
                                          ['text_totalearnings'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * eighteen,
                                          color: buttonColor),
                                    ),
                                    Text(
                                      driverWeeklyEarnings['currency_symbol'] +
                                          driverWeeklyEarnings['total_earnings']
                                              .toStringAsFixed(2),
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * eighteen,
                                          color: buttonColor),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                )
                              ])
                            :
                            //earning on specific choosen date
                            (_showEarning == 2)
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _pickDate = 1;
                                          });
                                          _datePicker();
                                        },
                                        child: Container(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: (isDarkTheme ==
                                                              true)
                                                          ? textColor
                                                              .withOpacity(0.5)
                                                          : underline,
                                                      width: 1.5))),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              (_fromDate == null)
                                                  ? Text(
                                                      languages[choosenLanguage]
                                                          ['text_fromDate'],
                                                      style: GoogleFonts.roboto(
                                                          color: textColor,
                                                          fontSize:
                                                              media.width *
                                                                  sixteen),
                                                    )
                                                  : Text(
                                                      _fromDate.toString(),
                                                      style: GoogleFonts.roboto(
                                                          color: textColor
                                                              .withOpacity(0.5),
                                                          fontSize:
                                                              media.width *
                                                                  sixteen),
                                                    ),
                                              Icon(Icons.date_range_outlined,
                                                  color: textColor)
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.1,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (_fromDate != null) {
                                            setState(() {
                                              _pickDate = 2;
                                            });
                                            _datePicker();
                                          }
                                        },
                                        child: Container(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: (isDarkTheme ==
                                                              true)
                                                          ? textColor
                                                              .withOpacity(0.5)
                                                          : underline,
                                                      width: 1.5))),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              (_toDate == null)
                                                  ? Text(
                                                      languages[choosenLanguage]
                                                          ['text_toDate'],
                                                      style: GoogleFonts.roboto(
                                                          color: textColor,
                                                          fontSize:
                                                              media.width *
                                                                  sixteen),
                                                    )
                                                  : Text(
                                                      _toDate.toString(),
                                                      style: GoogleFonts.roboto(
                                                          color: textColor
                                                              .withOpacity(0.5),
                                                          fontSize:
                                                              media.width *
                                                                  sixteen),
                                                    ),
                                              Icon(Icons.date_range_outlined,
                                                  color: textColor)
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.1,
                                      ),
                                      Button(
                                          onTap: () async {
                                            setState(() {
                                              driverReportEarnings.clear();
                                              _isLoading = true;
                                            });
                                            var val = await driverEarningReport(
                                                _fromDate, _toDate);
                                            if (val == 'logout') {
                                              navigateLogout();
                                            }
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          },
                                          width: media.width * 0.5,
                                          text: languages[choosenLanguage]
                                              ['text_confirm']),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      (driverReportEarnings.isNotEmpty)
                                          ? Column(
                                              children: [
                                                Text(
                                                  driverReportEarnings[
                                                          'from_date'] +
                                                      ' - ' +
                                                      driverReportEarnings[
                                                          'to_date'],
                                                  style: GoogleFonts.roboto(
                                                      fontSize:
                                                          media.width * fifteen,
                                                      color: (isDarkTheme ==
                                                              true)
                                                          ? textColor
                                                              .withOpacity(0.5)
                                                          : hintColor),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.025,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      driverReportEarnings[
                                                          'currency_symbol'],
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: textColor),
                                                    ),
                                                    Text(
                                                      driverReportEarnings[
                                                              'total_earnings']
                                                          .toStringAsFixed(2),
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: textColor),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.05),
                                                  width: media.width * 0.9,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: borderLines,
                                                          width: 1.2)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            width: media.width *
                                                                0.17,
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_trips'],
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color: (isDarkTheme ==
                                                                          true)
                                                                      ? textColor
                                                                          .withOpacity(
                                                                              0.5)
                                                                      : hintColor),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                media.width *
                                                                    0.015,
                                                          ),
                                                          Container(
                                                            width: media.width *
                                                                0.17,
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              driverReportEarnings[
                                                                      'total_trips_count']
                                                                  .toString(),
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color:
                                                                      textColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        height:
                                                            media.width * 0.1,
                                                        color: borderLines,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            width: media.width *
                                                                0.17,
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_enable_wallet'],
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color: (isDarkTheme ==
                                                                          true)
                                                                      ? textColor
                                                                          .withOpacity(
                                                                              0.5)
                                                                      : hintColor),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                media.width *
                                                                    0.015,
                                                          ),
                                                          Container(
                                                            width: media.width *
                                                                0.17,
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              driverReportEarnings[
                                                                      'total_wallet_trip_count']
                                                                  .toString(),
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color:
                                                                      textColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        height:
                                                            media.width * 0.1,
                                                        color: borderLines,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            width: media.width *
                                                                0.17,
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  ['text_cash'],
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color: (isDarkTheme ==
                                                                          true)
                                                                      ? textColor
                                                                          .withOpacity(
                                                                              0.5)
                                                                      : hintColor),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                media.width *
                                                                    0.015,
                                                          ),
                                                          Container(
                                                            width: media.width *
                                                                0.17,
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              driverReportEarnings[
                                                                      'total_cash_trip_count']
                                                                  .toString(),
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color:
                                                                      textColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.1,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      languages[choosenLanguage]
                                                          ['text_tripkm'],
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: textColor),
                                                    ),
                                                    Text(
                                                      driverReportEarnings[
                                                              'total_trip_kms']
                                                          .toString(),
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: textColor),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      languages[choosenLanguage]
                                                          [
                                                          'text_walletpayment'],
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: textColor),
                                                    ),
                                                    Text(
                                                      driverReportEarnings[
                                                              'currency_symbol'] +
                                                          driverReportEarnings[
                                                                  'total_wallet_trip_amount']
                                                              .toStringAsFixed(
                                                                  2),
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: textColor),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      languages[choosenLanguage]
                                                          ['text_cashpayment'],
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: textColor),
                                                    ),
                                                    Text(
                                                      driverReportEarnings[
                                                              'currency_symbol'] +
                                                          driverReportEarnings[
                                                                  'total_cash_trip_amount']
                                                              .toStringAsFixed(
                                                                  2),
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: textColor),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Container(
                                                  height: 1,
                                                  width: media.width * 0.9,
                                                  color: borderLines,
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      languages[choosenLanguage]
                                                          [
                                                          'text_totalearnings'],
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: buttonColor),
                                                    ),
                                                    Text(
                                                      driverReportEarnings[
                                                              'currency_symbol'] +
                                                          driverReportEarnings[
                                                                  'total_earnings']
                                                              .toStringAsFixed(
                                                                  2),
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: buttonColor),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      )
                                    ],
                                  )
                                : Container(),
                  ))
                ],
              ),
            ),

            //no internet
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(onTap: () {
                      setState(() {
                        internetTrue();
                      });
                    }))
                : Container(),
            //loader
            (_isLoading == true)
                ? const Positioned(child: Loading())
                : Container()
          ],
        ),
      ),
    );
  }
}
