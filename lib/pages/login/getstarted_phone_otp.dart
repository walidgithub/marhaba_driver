import 'package:flutter/material.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/login.dart';
import 'package:tagxidriver/pages/onTripPage/map_page.dart';
import 'package:tagxidriver/pages/noInternet/nointernet.dart';
import 'package:tagxidriver/pages/vehicleInformations/docs_onprocess.dart';
import 'package:tagxidriver/pages/vehicleInformations/referral_code.dart';
import 'package:tagxidriver/pages/vehicleInformations/service_area.dart';
import 'package:tagxidriver/pages/vehicleInformations/upload_docs.dart';
import 'package:tagxidriver/translation/translation.dart';
import 'package:tagxidriver/widgets/widgets.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// ignore: must_be_immutable
class GetStartedPhoneOtp extends StatefulWidget {
  dynamic from;
  GetStartedPhoneOtp({this.from, Key? key}) : super(key: key);

  @override
  State<GetStartedPhoneOtp> createState() => _GetStartedPhoneOtpState();
}

class _GetStartedPhoneOtpState extends State<GetStartedPhoneOtp> {
  String otpNumber = ''; //otp number
  List otpText = []; //otp number as list for 6 boxes
  List otpPattern = [1, 2, 3, 4, 5, 6]; //list to create number of input box
  var resendTime = 60; //otp resend time
  late Timer timer; //timer for resend time
  String _error =
      ''; //otp error string to show if error occurs in otp validation
  TextEditingController otpController =
      TextEditingController(); //otp textediting controller
  TextEditingController first = TextEditingController();
  TextEditingController second = TextEditingController();
  TextEditingController third = TextEditingController();
  TextEditingController fourth = TextEditingController();
  TextEditingController fifth = TextEditingController();
  TextEditingController sixth = TextEditingController();
  bool _loading = false; //loading screen showing
  @override
  void initState() {
    _loading = false;
    timers();
    otpFalse();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel;
    super.dispose();
  }

//navigate
  navigate(verify) {
    if (verify == true) {
      if (userDetails['uploaded_document'] == false) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Docs()), (route) => false);
      } else if (userDetails['uploaded_document'] == true &&
          userDetails['approve'] == false) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const DocsProcess(),
            ),
            (route) => false);
      } else if (userDetails['uploaded_document'] == true &&
          userDetails['approve'] == true) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Maps()),
            (route) => false);
      }
    } else if (verify == false) {
      if (ischeckownerordriver == 'driver') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const ServiceArea()));
      } else if (ischeckownerordriver == 'owner') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Referral()),
            (route) => false);
      }
    } else {
      _error = verify.toString();
      setState(() {
        _loading = false;
      });
    }
  }

//otp is false
  otpFalse() async {
    if (phoneAuthCheck == false) {
      if (widget.from == '1') {
        _loading = true;
        otpController.text = '123456';
        otpNumber = otpController.text;
        var verify = await verifyUser(phnumber);

        navigate(verify);
      } else {
        _loading = true;
        otpController.text = '123456';
        otpNumber = otpController.text;
        var verify = await verifyUser(phnumber);

        var val = await registerOwner();
        if (val == 'true') {
          navigate(verify);
          serviceLocations.clear();
        } else {
          _loading = false;
          otpController.clear();
          _error = val.toString();
        }
      }
    }
  }

//auto verify otp

  verifyOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      // Sign the user in (or link) with the credential
      await FirebaseAuth.instance.signInWithCredential(credentials);

      var verify = await verifyUser(phnumber);
      credentials = null;
      navigate(verify);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-verification-code') {
        setState(() {
          otpController.clear();
          otpNumber = '';
          _error = languages[choosenLanguage]['text_otp_error'];
        });
      }
    }
  }

// running resend otp timer
  timers() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTime != 0) {
        if (mounted) {
          setState(() {
            resendTime--;
          });
        }
      } else {
        timer.cancel();
      }
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
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              if (credentials != null) {
                _loading = true;
                verifyOtp();
              }
              return Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: media.width * 0.08,
                        right: media.width * 0.08,
                        top: media.width * 0.05 +
                            MediaQuery.of(context).padding.top),
                    color: page,
                    height: media.height * 1,
                    width: media.width * 1,
                    child: Column(
                      children: [
                        Container(
                            width: media.width * 1,
                            color: page,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(Icons.arrow_back,
                                        color: textColor)),
                              ],
                            )),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: media.height * 0.04,
                              ),
                              SizedBox(
                                width: media.width * 1,
                                child: Text(
                                  languages[choosenLanguage]
                                      ['text_phone_verify'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * twentyeight,
                                      fontWeight: FontWeight.bold,
                                      color: textColor),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                languages[choosenLanguage]['text_enter_otp'],
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * sixteen,
                                    color: textColor.withOpacity(0.3)),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                countries[phcode]['dial_code'] + phnumber,
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * sixteen,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                              ),
                              SizedBox(height: media.height * 0.1),
                              Container(
                                height: media.width * 0.15,
                                width: media.width * 0.9,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: page,
                                    border: Border.all(
                                        color: borderLines, width: 1.2)),
                                child: TextField(
                                  controller: otpController,
                                  autofocus:
                                      (phoneAuthCheck == false) ? false : true,
                                  onChanged: (val) {
                                    setState(() {
                                      otpNumber = val;
                                    });
                                    if (val.length == 6) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    }
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      counterText: '',
                                      hintText: languages[choosenLanguage]
                                          ['text_enter_otp_login'],
                                      hintStyle: TextStyle(
                                          color: textColor.withOpacity(0.4))),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    fontSize: media.width * twenty,
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLength: 6,
                                  keyboardType: TextInputType.number,
                                ),
                              ),

                              // show error on otp
                              (_error != '')
                                  ? Container(
                                      width: media.width * 0.8,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(
                                          top: media.height * 0.02),
                                      child: Text(
                                        _error,
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: Colors.red),
                                      ),
                                    )
                                  : Container(),

                              SizedBox(
                                height: media.height * 0.05,
                              ),

                              (widget.from == '1')
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: Button(
                                        onTap: () async {
                                          if (otpNumber.length == 6) {
                                            timer.cancel();
                                            setState(() {
                                              _loading = true;
                                              _error = '';
                                            });
                                            //firebase code send false
                                            if (phoneAuthCheck == false) {
                                              var verify =
                                                  await verifyUser(phnumber);

                                              navigate(verify);
                                            } else {
                                              // firebase code send true
                                              try {
                                                PhoneAuthCredential credential =
                                                    PhoneAuthProvider
                                                        .credential(
                                                            verificationId:
                                                                verId,
                                                            smsCode: otpNumber);

                                                // Sign the user in (or link) with the credential
                                                await FirebaseAuth.instance
                                                    .signInWithCredential(
                                                        credential);

                                                var verify =
                                                    await verifyUser(phnumber);
                                                navigate(verify);
                                              } on FirebaseAuthException catch (error) {
                                                if (error.code ==
                                                    'invalid-verification-code') {
                                                  setState(() {
                                                    otpController.clear();
                                                    otpNumber = '';
                                                    _error = languages[
                                                            choosenLanguage]
                                                        ['text_otp_error'];
                                                    _loading = false;
                                                  });
                                                }
                                              }
                                            }
                                          } else if (phoneAuthCheck == true &&
                                              resendTime == 0 &&
                                              otpNumber.length != 6) {
                                            setState(() {
                                              setState(() {
                                                resendTime = 60;
                                              });
                                              timers();
                                            });
                                            phoneAuth(countries[phcode]
                                                    ['dial_code'] +
                                                phnumber);
                                          }
                                        },
                                        borcolor: (resendTime != 0 &&
                                                otpNumber.length != 6)
                                            ? underline
                                            : null,
                                        text: (otpNumber.length == 6)
                                            ? languages[choosenLanguage]
                                                ['text_verify']
                                            : (resendTime == 0)
                                                ? languages[choosenLanguage]
                                                    ['text_resend_code']
                                                : languages[choosenLanguage]
                                                        ['text_resend_code'] +
                                                    ' ' +
                                                    resendTime.toString(),
                                        color: (resendTime != 0 &&
                                                otpNumber.length != 6)
                                            ? (isDarkTheme == true)
                                                ? textColor.withOpacity(0.3)
                                                : underline
                                            : null,
                                      ),
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      child: Button(
                                        onTap: () async {
                                          if (otpNumber.length == 6) {
                                            timer.cancel();
                                            setState(() {
                                              _loading = true;
                                              _error = '';
                                            });
                                            //firebase code send false
                                            if (phoneAuthCheck == false) {
                                              var verify =
                                                  await verifyUser(phnumber);

                                              navigate(verify);
                                            } else {
                                              // firebase code send true
                                              try {
                                                PhoneAuthCredential credential =
                                                    PhoneAuthProvider
                                                        .credential(
                                                            verificationId:
                                                                verId,
                                                            smsCode: otpNumber);

                                                // Sign the user in (or link) with the credential
                                                await FirebaseAuth.instance
                                                    .signInWithCredential(
                                                        credential);

                                                var verify =
                                                    await verifyUser(phnumber);
                                                // navigate(verify);

                                                var val = await registerOwner();
                                                if (val == 'true') {
                                                  navigate(verify);
                                                  serviceLocations.clear();
                                                } else {
                                                  _loading = false;
                                                  otpController.clear();
                                                  _error = val.toString();
                                                }
                                              } on FirebaseAuthException catch (error) {
                                                if (error.code ==
                                                    'invalid-verification-code') {
                                                  setState(() {
                                                    otpController.clear();
                                                    otpNumber = '';
                                                    _error = languages[
                                                            choosenLanguage]
                                                        ['text_otp_error'];
                                                    _loading = false;
                                                  });
                                                }
                                              }
                                            }
                                          } else if (phoneAuthCheck == true &&
                                              resendTime == 0 &&
                                              otpNumber.length != 6) {
                                            setState(() {
                                              setState(() {
                                                resendTime = 60;
                                              });
                                              timers();
                                            });
                                            phoneAuth(countries[phcode]
                                                    ['dial_code'] +
                                                phnumber);
                                          }
                                        },
                                        borcolor: (resendTime != 0 &&
                                                otpNumber.length != 6)
                                            ? underline
                                            : null,
                                        text: (otpNumber.length == 6)
                                            ? languages[choosenLanguage]
                                                ['text_verify']
                                            : (resendTime == 0)
                                                ? languages[choosenLanguage]
                                                    ['text_resend_code']
                                                : languages[choosenLanguage]
                                                        ['text_resend_code'] +
                                                    ' ' +
                                                    resendTime.toString(),
                                        color: (resendTime != 0 &&
                                                otpNumber.length != 6)
                                            ? (isDarkTheme == true)
                                                ? textColor.withOpacity(0.3)
                                                : underline
                                            : null,
                                      ),
                                    )
                            ],
                          ),
                        )
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
                  (_loading == true)
                      ? Positioned(
                          top: 0,
                          child: SizedBox(
                            height: media.height * 1,
                            width: media.width * 1,
                            child: const Loading(),
                          ))
                      : Container()
                ],
              );
            }),
      ),
    );
  }
}
