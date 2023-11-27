import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/getstarted_phone_otp.dart';
import 'package:tagxidriver/pages/noInternet/nointernet.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';
import 'package:tagxidriver/widgets/widgets.dart';
import './login.dart';
import '../vehicleInformations/service_area.dart';

// ignore: must_be_immutable
class GetStarted extends StatefulWidget {
  dynamic from;
  GetStarted({this.from, Key? key}) : super(key: key);

  @override
  State<GetStarted> createState() => _GetStartedState();
}

String name = ''; //name of user
String email = ''; // email of user
dynamic proImageFile1;

class _GetStartedState extends State<GetStarted> {
  bool _loading = false;
  var verifyEmailError = '';

  TextEditingController emailText =
      TextEditingController(); //email textediting controller
  TextEditingController nameText =
      TextEditingController(); //name textediting controller
  TextEditingController phoneNoText =
      TextEditingController(); //phone num textediting controller

  ImagePicker picker = ImagePicker();
  bool _pickImage = false;
  String _permission = '';

  getGalleryPermission() async {
    dynamic status;
    if (platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.request();
        }

        /// use [Permissions.storage.status]
      } else {
        status = await Permission.photos.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.photos.request();
        }
      }
    } else {
      status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.photos.request();
      }
    }
    return status;
  }

//get camera permission
  getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.camera.request();
    }
    return status;
  }

//pick image from gallery
  pickImageFromGallery() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        proImageFile1 = pickedFile?.path;
        _pickImage = false;
      });
    } else {
      setState(() {
        _permission = 'noPhotos';
      });
    }
  }

//pick image from camera
  pickImageFromCamera() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      setState(() {
        proImageFile1 = pickedFile?.path;
        _pickImage = false;
      });
    } else {
      setState(() {
        _permission = 'noCamera';
      });
    }
  }

  //navigate
  navigate() {
    (widget.from == '1')
        ? Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ServiceArea()))
        : Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GetStartedPhoneOtp(from: '1')));
  }

  @override
  void initState() {
    proImageFile1 = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Scaffold(
        body: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(
                    left: media.width * 0.08,
                    right: media.width * 0.08,
                    top: media.width * 0.05 +
                        MediaQuery.of(context).padding.top),
                height: media.height * 1,
                width: media.width * 1,
                color: page,
                child: Column(
                  children: [
                    Container(

                        // height: media.height * 0.12,
                        width: media.width * 1,
                        color: page,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child:
                                    Icon(Icons.arrow_back, color: textColor)),
                          ],
                        )),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: media.height * 0.04,
                          ),
                          SizedBox(
                            width: media.width * 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  languages[choosenLanguage]
                                      ['text_get_started'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * twentyeight,
                                      fontWeight: FontWeight.bold,
                                      color: textColor),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: media.height * 0.012,
                          ),
                          Text(
                            languages[choosenLanguage]['text_fill_form'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * sixteen,
                                color: textColor.withOpacity(0.3)),
                          ),
                          SizedBox(height: media.height * 0.04),

                          Center(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _pickImage = true;
                                });
                              },
                              child: proImageFile1 != null
                                  ? Container(
                                      height: media.width * 0.4,
                                      width: media.width * 0.4,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: backgroundColor,
                                          image: DecorationImage(
                                              image: FileImage(
                                                  File(proImageFile1)),
                                              fit: BoxFit.cover)),
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      height: media.width * 0.4,
                                      width: media.width * 0.4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: backgroundColor,
                                      ),
                                      child: Text(
                                        languages[choosenLanguage]
                                            ['text_add_photo'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * fourteen,
                                            color: (isDarkTheme == true)
                                                ? Colors.black
                                                : textColor),
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: media.height * 0.04),

                          // name input field
                          InputField(
                            icon: Icons.person_outline_rounded,
                            text: languages[choosenLanguage]['text_name'],
                            onTap: (val) {
                              setState(() {
                                name = nameText.text;
                              });
                            },
                            textController: nameText,
                          ),
                          SizedBox(
                            height: media.height * 0.012,
                          ),
                          // email input field
                          (widget.from == '1')
                              ? InputField(
                                  icon: Icons.email_outlined,
                                  text: languages[choosenLanguage]
                                      ['text_email'],
                                  onTap: (val) {
                                    setState(() {
                                      email = emailText.text;
                                    });
                                  },
                                  textController: emailText,
                                  color: (verifyEmailError == '')
                                      ? null
                                      : Colors.red,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: (isDarkTheme == true)
                                                  ? textColor.withOpacity(0.6)
                                                  : underline))),
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.email_outlined,
                                          size: media.width * twentyfour,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        email,
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: textColor,
                                            letterSpacing: 2),
                                      )
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: media.height * 0.012,
                          ),
                          (widget.from == '1')
                              ? Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: (isDarkTheme == true)
                                                  ? textColor.withOpacity(0.6)
                                                  : underline))),
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              countries[phcode]['dial_code'],
                                              style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * sixteen,
                                                  color: textColor),
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Icon(Icons.keyboard_arrow_down,
                                                color: textColor)
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        phnumber,
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: textColor,
                                            letterSpacing: 2),
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  height: 55,
                                  width: media.width * 1 -
                                      (media.width * 0.08 * 2),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: (isDarkTheme == true)
                                                  ? textColor.withOpacity(0.6)
                                                  : underline))),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (countries.isNotEmpty) {
                                            //dialod box for select country for dial code
                                            await showDialog(
                                                context: context,
                                                barrierColor: (isDarkTheme ==
                                                        true)
                                                    ? textColor.withOpacity(0.3)
                                                    : Colors.black
                                                        .withOpacity(0.5),
                                                builder: (context) {
                                                  var searchVal = '';
                                                  return AlertDialog(
                                                    backgroundColor: page,
                                                    insetPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    content: StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                      return Container(
                                                        width:
                                                            media.width * 0.9,
                                                        color: page,
                                                        child: Directionality(
                                                          textDirection:
                                                              (languageDirection ==
                                                                      'rtl')
                                                                  ? TextDirection
                                                                      .rtl
                                                                  : TextDirection
                                                                      .ltr,
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20),
                                                                height: 40,
                                                                width: media
                                                                        .width *
                                                                    0.9,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1.5)),
                                                                child:
                                                                    TextField(
                                                                  decoration: InputDecoration(
                                                                      contentPadding: (languageDirection ==
                                                                              'rtl')
                                                                          ? EdgeInsets.only(
                                                                              bottom: media.width *
                                                                                  0.035)
                                                                          : EdgeInsets.only(
                                                                              bottom: media.width *
                                                                                  0.04),
                                                                      border: InputBorder
                                                                          .none,
                                                                      hintText:
                                                                          languages[choosenLanguage]
                                                                              [
                                                                              'text_search'],
                                                                      hintStyle: GoogleFonts.roboto(
                                                                          color:
                                                                              textColor.withOpacity(0.4),
                                                                          fontSize: media.width * sixteen)),
                                                                  style: GoogleFonts
                                                                      .roboto(
                                                                          color:
                                                                              textColor),
                                                                  onChanged:
                                                                      (val) {
                                                                    setState(
                                                                        () {
                                                                      searchVal =
                                                                          val;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 20),
                                                              Expanded(
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    children: countries
                                                                        .asMap()
                                                                        .map((i, value) {
                                                                          return MapEntry(
                                                                              i,
                                                                              SizedBox(
                                                                                width: media.width * 0.9,
                                                                                child: (searchVal == '' && countries[i]['flag'] != null)
                                                                                    ? InkWell(
                                                                                        onTap: () {
                                                                                          setState(() {
                                                                                            phcode = i;
                                                                                          });
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Container(
                                                                                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                          color: page,
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Row(
                                                                                                children: [
                                                                                                  Image.network(countries[i]['flag']),
                                                                                                  SizedBox(
                                                                                                    width: media.width * 0.02,
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                      width: media.width * 0.4,
                                                                                                      child: Text(
                                                                                                        countries[i]['name'],
                                                                                                        style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: textColor),
                                                                                                      )),
                                                                                                ],
                                                                                              ),
                                                                                              Text(
                                                                                                countries[i]['dial_code'],
                                                                                                style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: textColor),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ))
                                                                                    : (countries[i]['flag'] != null && countries[i]['name'].toLowerCase().contains(searchVal.toLowerCase()))
                                                                                        ? InkWell(
                                                                                            onTap: () {
                                                                                              setState(() {
                                                                                                phcode = i;
                                                                                              });
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Container(
                                                                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                              color: page,
                                                                                              child: Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                children: [
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      Image.network(countries[i]['flag']),
                                                                                                      SizedBox(
                                                                                                        width: media.width * 0.02,
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                          width: media.width * 0.4,
                                                                                                          child: Text(
                                                                                                            countries[i]['name'],
                                                                                                            style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: textColor),
                                                                                                          )),
                                                                                                    ],
                                                                                                  ),
                                                                                                  Text(
                                                                                                    countries[i]['dial_code'],
                                                                                                    style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: textColor),
                                                                                                  )
                                                                                                ],
                                                                                              ),
                                                                                            ))
                                                                                        : Container(),
                                                                              ));
                                                                        })
                                                                        .values
                                                                        .toList(),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  );
                                                });
                                          } else {
                                            getCountryCode();
                                          }
                                          setState(() {});
                                        },
                                        child: Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Image.network(
                                                  countries[phcode]['flag']),
                                              SizedBox(
                                                width: media.width * 0.02,
                                              ),
                                              Text(
                                                countries[phcode]['dial_code']
                                                    .toString(),
                                                style: GoogleFonts.roboto(
                                                    fontSize:
                                                        media.width * sixteen,
                                                    color: textColor),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Icon(Icons.keyboard_arrow_down,
                                                  color: textColor)
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 1,
                                        height: media.width * 0.0693,
                                        color: buttonColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        width: media.width * 0.5,
                                        child: TextFormField(
                                          controller: phoneNoText,
                                          onChanged: (val) {
                                            setState(() {
                                              phnumber = phoneNoText.text;
                                            });
                                            if (phoneNoText.text.length ==
                                                countries[phcode]
                                                    ['dial_max_length']) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            }
                                          },
                                          maxLength: countries[phcode]
                                              ['dial_max_length'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor,
                                              letterSpacing: 1),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: languages[choosenLanguage]
                                                ['text_phone_number'],
                                            counterText: '',
                                            hintStyle: GoogleFonts.roboto(
                                                fontSize: media.width * sixteen,
                                                color:
                                                    textColor.withOpacity(0.7)),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                          //email already exist error
                          (verifyEmailError != '')
                              ? Container(
                                  margin:
                                      EdgeInsets.only(top: media.height * 0.03),
                                  alignment: Alignment.center,
                                  width: media.width * 0.8,
                                  child: Text(
                                    verifyEmailError,
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: Colors.red),
                                  ),
                                )
                              : Container(),

                          SizedBox(
                            height: media.height * 0.065,
                          ),
                          (widget.from == '1')
                              ? (nameText.text.isNotEmpty &&
                                      emailText.text.isNotEmpty)
                                  ? Container(
                                      width: media.width * 1,
                                      alignment: Alignment.center,
                                      child: Button(
                                          onTap: () async {
                                            String pattern =
                                                r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])*$";
                                            RegExp regex = RegExp(pattern);
                                            if (regex
                                                .hasMatch(emailText.text)) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              setState(() {
                                                verifyEmailError = '';
                                                _loading = true;
                                              });
                                              var result =
                                                  await validateEmail(email);
                                              setState(() {
                                                _loading = false;
                                              });
                                              if (result == 'success') {
                                                setState(() {
                                                  verifyEmailError = '';
                                                });
                                                navigate();
                                              } else {
                                                setState(() {
                                                  verifyEmailError =
                                                      result.toString();
                                                });
                                                debugPrint('failed');
                                              }
                                            } else {
                                              setState(() {
                                                verifyEmailError = languages[
                                                        choosenLanguage]
                                                    ['text_email_validation'];
                                              });
                                            }
                                          },
                                          text: languages[choosenLanguage]
                                              ['text_next']))
                                  : Container()
                              : (nameText.text.isNotEmpty &&
                                      phoneNoText.text.length >=
                                          countries[phcode]['dial_min_length'])
                                  ? Container(
                                      width:
                                          media.width * 1 - media.width * 0.08,
                                      alignment: Alignment.center,
                                      child: Button(
                                        onTap: () async {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          setState(() {
                                            _loading = true;
                                          });
                                          var val = await otpCall();
                                          if (val.value == true) {
                                            phoneAuthCheck = true;
                                            await phoneAuth(countries[phcode]
                                                    ['dial_code'] +
                                                phnumber);
                                            value = 0;
                                            navigate();
                                          } else {
                                            phoneAuthCheck = false;
                                            navigate();
                                          }
                                          setState(() {
                                            _loading = false;
                                          });
                                        },
                                        text: languages[choosenLanguage]
                                            ['text_next'],
                                      ),
                                    )
                                  : Container(),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

              //image pick

              (_pickImage == true)
                  ? Positioned(
                      bottom: 0,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _pickImage = false;
                          });
                        },
                        child: Container(
                          height: media.height * 1,
                          width: media.width * 1,
                          color: Colors.transparent.withOpacity(0.6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.all(media.width * 0.05),
                                width: media.width * 1,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        topRight: Radius.circular(25)),
                                    border: Border.all(
                                      color: borderLines,
                                      width: 1.2,
                                    ),
                                    color: page),
                                child: Column(
                                  children: [
                                    Container(
                                      height: media.width * 0.02,
                                      width: media.width * 0.15,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            media.width * 0.01),
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(
                                      height: media.width * 0.05,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                pickImageFromCamera();
                                              },
                                              child: Container(
                                                  height: media.width * 0.171,
                                                  width: media.width * 0.171,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: borderLines,
                                                          width: 1.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  child: Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: media.width * 0.064,
                                                    color: textColor,
                                                  )),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.01,
                                            ),
                                            Text(
                                              languages[choosenLanguage]
                                                  ['text_camera'],
                                              style: GoogleFonts.roboto(
                                                  fontSize: media.width * ten,
                                                  color:
                                                      const Color(0xff666666)),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                pickImageFromGallery();
                                              },
                                              child: Container(
                                                  height: media.width * 0.171,
                                                  width: media.width * 0.171,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: borderLines,
                                                          width: 1.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  child: Icon(
                                                    Icons.image_outlined,
                                                    size: media.width * 0.064,
                                                    color: textColor,
                                                  )),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.01,
                                            ),
                                            Text(
                                              languages[choosenLanguage]
                                                  ['text_gallery'],
                                              style: GoogleFonts.roboto(
                                                  fontSize: media.width * ten,
                                                  color:
                                                      const Color(0xff666666)),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  : Container(),

              //permission denied popup
              (_permission != '')
                  ? Positioned(
                      child: Container(
                      height: media.height * 1,
                      width: media.width * 1,
                      color: Colors.transparent.withOpacity(0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: media.width * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _permission = '';
                                      _pickImage = false;
                                    });
                                  },
                                  child: Container(
                                    height: media.width * 0.1,
                                    width: media.width * 0.1,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle, color: page),
                                    child: const Icon(Icons.cancel_outlined),
                                  ),
                                ),
                              ],
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
                                color: page,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 2.0,
                                      spreadRadius: 2.0,
                                      color: Colors.black.withOpacity(0.2))
                                ]),
                            child: Column(
                              children: [
                                SizedBox(
                                    width: media.width * 0.8,
                                    child: Text(
                                      (_permission == 'noPhotos')
                                          ? languages[choosenLanguage]
                                              ['text_open_photos_setting']
                                          : languages[choosenLanguage]
                                              ['text_open_camera_setting'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * sixteen,
                                          color: textColor,
                                          fontWeight: FontWeight.w600),
                                    )),
                                SizedBox(height: media.width * 0.05),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                        onTap: () async {
                                          await openAppSettings();
                                        },
                                        child: Text(
                                          languages[choosenLanguage]
                                              ['text_open_settings'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: buttonColor,
                                              fontWeight: FontWeight.w600),
                                        )),
                                    InkWell(
                                        onTap: () async {
                                          (_permission == 'noCamera')
                                              ? pickImageFromCamera()
                                              : pickImageFromGallery();
                                          setState(() {
                                            _permission = '';
                                          });
                                        },
                                        child: Text(
                                          languages[choosenLanguage]
                                              ['text_done'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: buttonColor,
                                              fontWeight: FontWeight.w600),
                                        ))
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ))
                  : Container(),

              //internet not connected
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
                  ? const Positioned(top: 0, child: Loading())
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
