import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/signupmethod.dart';
import 'package:tagxidriver/pages/noInternet/nointernet.dart';
import 'package:tagxidriver/pages/vehicleInformations/docs_onprocess.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';
import 'package:tagxidriver/widgets/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class Docs extends StatefulWidget {
  // const Docs({ Key? key }) : super(key: key);
  dynamic fromPage;

  // ignore: use_key_in_widget_constructors
  Docs({this.fromPage});

  @override
  State<Docs> createState() => _DocsState();
}

int docsId = 0;
int choosenDocs = 0;

class _DocsState extends State<Docs> {
  bool _loaded = false;

  @override
  void initState() {
    getDocs();
    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

//get needed docs
  getDocs() async {
    var val = await getDocumentsNeeded();
    if (mounted) {
      if (val == 'logout') {
        navigateLogout();
      }
      setState(() {
        _loaded = true;
      });
    }
  }

  //navigate
  pop() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
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
                    SizedBox(
                        width: media.width * 1,
                        child: (widget.fromPage != null)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: Icon(Icons.arrow_back,
                                          color: textColor)),
                                ],
                              )
                            : Container()),
                    SizedBox(
                      height: media.height * 0.04,
                    ),
                    SizedBox(
                        width: media.width * 1,
                        child: Text(
                          languages[choosenLanguage]['text_upload_docs'],
                          style: GoogleFonts.roboto(
                              fontSize: media.width * twenty,
                              color: textColor,
                              fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(height: 10),
                    (documentsNeeded.isNotEmpty)
                        ? Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: documentsNeeded
                                    .asMap()
                                    .map((i, value) {
                                      return MapEntry(
                                          i,
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: (isDarkTheme ==
                                                              true)
                                                          ? textColor
                                                              .withOpacity(0.4)
                                                          : underline,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: InkWell(
                                                onTap: () async {
                                                  docsId =
                                                      documentsNeeded[i]['id'];
                                                  choosenDocs = i;
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const UploadDocs()));

                                                  setState(() {});
                                                },
                                                child: (documentsNeeded[i]
                                                            ['is_uploaded'] ==
                                                        false)
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.6,
                                                                child: Text(
                                                                  (languages[choosenLanguage][documentsNeeded[i]['name']
                                                                              .toString()] !=
                                                                          null)
                                                                      ? languages[
                                                                          choosenLanguage][documentsNeeded[i]
                                                                              [
                                                                              'name']
                                                                          .toString()]
                                                                      : documentsNeeded[i]
                                                                              [
                                                                              'name']
                                                                          .toString(),
                                                                  style: GoogleFonts.roboto(
                                                                      color:
                                                                          textColor,
                                                                      fontSize:
                                                                          media.width *
                                                                              twenty,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.6,
                                                                child: Text(
                                                                  (languages[choosenLanguage][documentsNeeded[i]['document_status_string']
                                                                              .toString()] !=
                                                                          null)
                                                                      ? languages[
                                                                          choosenLanguage][documentsNeeded[i]
                                                                              [
                                                                              'document_status_string']
                                                                          .toString()]
                                                                      : documentsNeeded[i]
                                                                              [
                                                                              'document_status_string']
                                                                          .toString(),
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    color:
                                                                        notUploadedColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          RotatedBox(
                                                            quarterTurns:
                                                                (languageDirection ==
                                                                        'rtl')
                                                                    ? 2
                                                                    : 0,
                                                            child: Image.asset(
                                                              'assets/images/chevronLeft.png',
                                                              width:
                                                                  media.width *
                                                                      0.075,
                                                              color: textColor,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                height: media
                                                                        .width *
                                                                    0.12,
                                                                width: media
                                                                        .width *
                                                                    0.12,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    image: DecorationImage(
                                                                        image: NetworkImage(documentsNeeded[i]['driver_document']['data']
                                                                            [
                                                                            'document']),
                                                                        fit: BoxFit
                                                                            .cover)),
                                                                margin: EdgeInsets.only(
                                                                    bottom: media
                                                                            .width *
                                                                        0.02),
                                                              ),
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.01,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.57,
                                                                    child: Text(
                                                                      (languages[choosenLanguage][documentsNeeded[i]['name'].toString()] !=
                                                                              null)
                                                                          ? languages[choosenLanguage][documentsNeeded[i]['name']
                                                                              .toString()]
                                                                          : documentsNeeded[i]['name']
                                                                              .toString(),
                                                                      style: GoogleFonts.roboto(
                                                                          color:
                                                                              textColor,
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.57,
                                                                    child: Text(
                                                                      (languages[choosenLanguage][documentsNeeded[i]['document_status_string'].toString()] !=
                                                                              null)
                                                                          ? languages[choosenLanguage][documentsNeeded[i]['document_status_string']
                                                                              .toString()]
                                                                          : documentsNeeded[i]['document_status_string']
                                                                              .toString(),
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                twelve,
                                                                        color: (documentsNeeded[i]['driver_document']['data']['comment'] ==
                                                                                null)
                                                                            ? notUploadedColor
                                                                            : verifyDeclined,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  (documentsNeeded[i]['driver_document']['data'][
                                                                              'comment'] !=
                                                                          null)
                                                                      ? Container(
                                                                          width: media.width *
                                                                              0.57,
                                                                          padding: EdgeInsets.only(
                                                                              top: media.width *
                                                                                  0.025),
                                                                          child:
                                                                              Text(
                                                                            documentsNeeded[i]['driver_document']['data']['comment'],
                                                                            style:
                                                                                GoogleFonts.roboto(
                                                                              fontSize: media.width * twelve,
                                                                            ),
                                                                            maxLines:
                                                                                4,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ))
                                                                      : Container()
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          RotatedBox(
                                                            quarterTurns:
                                                                (languageDirection ==
                                                                        'rtl')
                                                                    ? 2
                                                                    : 0,
                                                            child: Image.asset(
                                                              'assets/images/chevronLeft.png',
                                                              width:
                                                                  media.width *
                                                                      0.075,
                                                              color: textColor,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                              )));
                                    })
                                    .values
                                    .toList(),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(height: media.height * 0.02),

                    //submit documents
                    (enableDocumentSubmit == true)
                        ? (documentsNeeded.isNotEmpty)
                            ? Button(
                                onTap: () async {
                                  if (widget.fromPage == '2') {
                                    setState(() {
                                      _loaded = false;
                                    });

                                    var val = await getUserDetails();
                                    if (val == 'logout') {
                                      navigateLogout();
                                    }
                                    pop();
                                  } else {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const DocsProcess()),
                                        (route) => false);
                                  }
                                },
                                text: languages[choosenLanguage]['text_submit'])
                            : Container()
                        : Container(),
                    SizedBox(
                      height: media.width * 0.05,
                    )
                  ],
                ),
              ),
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
              (_loaded == false)
                  ? const Positioned(top: 0, child: Loading())
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}

class UploadDocs extends StatefulWidget {
  const UploadDocs({Key? key}) : super(key: key);

  @override
  State<UploadDocs> createState() => _UploadDocsState();
}

String docIdNumber = '';
String date = '';
DateTime expDate = DateTime.now();
final ImagePicker _picker = ImagePicker();
dynamic imageFile;

class _UploadDocsState extends State<UploadDocs> {
  bool _uploadImage = false;

  TextEditingController idNumber = TextEditingController();

  DateTime current = DateTime.now();
  bool _loading = false;
  String _error = '';
  String _permission = '';

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

//date picker
  _datePicker() async {
    DateTime? picker = await showDatePicker(
        context: context,
        initialDate: current,
        firstDate: current,
        lastDate: DateTime(2100));
    if (picker != null) {
      setState(() {
        expDate = picker;
        date = picker.toString().split(" ")[0];
      });
    }
  }

//get gallery permission
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

//image pick from gallery
  imagePick() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);
      setState(() {
        imageFile = pickedFile?.path;
        _uploadImage = false;
      });
    } else {
      setState(() {
        _permission = 'noPhotos';
      });
    }
  }

//image pick from camera
  cameraPick() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      setState(() {
        imageFile = pickedFile?.path;
        _uploadImage = false;
      });
    } else {
      setState(() {
        _permission = 'noCamera';
      });
    }
  }

  //navigate
  pop() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    imageFile = null;
    date = '';
    super.initState();
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
              padding: EdgeInsets.only(
                  left: media.width * 0.08,
                  right: media.width * 0.08,
                  top: MediaQuery.of(context).padding.top + media.width * 0.05),
              height: media.height * 1,
              width: media.width * 1,
              color: page,
              child: Column(
                children: [
                  SizedBox(
                      width: media.width * 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.arrow_back, color: textColor)),
                        ],
                      )),
                  SizedBox(
                    height: media.height * 0.04,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _uploadImage = true;
                      });
                    },
                    child: Container(
                      height: media.width * 0.5,
                      width: media.width * 0.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: buttonColor, width: 1.2)),
                      child: (imageFile == null)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  languages[choosenLanguage]
                                      ['text_upload_docs'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * fifteen,
                                      fontWeight: FontWeight.w600,
                                      color: textColor),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Text(
                                  languages[choosenLanguage]['text_tapfordocs'],
                                  style: GoogleFonts.roboto(
                                    fontSize: media.width * ten,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )
                          : Image.file(
                              File(imageFile),
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  (documentsNeeded[choosenDocs]['has_expiry_date'] == true)
                      ? Container(
                          padding: EdgeInsets.only(top: media.height * 0.04),
                          child: InkWell(
                            onTap: () {
                              _datePicker();
                            },
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: (isDarkTheme == true)
                                              ? textColor.withOpacity(0.5)
                                              : underline,
                                          width: 1.5))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  (date != '')
                                      ? Text(
                                          date,
                                          style: GoogleFonts.roboto(
                                              color: textColor,
                                              fontSize: media.width * sixteen),
                                        )
                                      : Text(
                                          languages[choosenLanguage]
                                              ['text_expiry_date'],
                                          style: GoogleFonts.roboto(
                                              color: textColor.withOpacity(0.5),
                                              fontSize: media.width * sixteen),
                                        ),
                                  Icon(Icons.date_range_outlined,
                                      color: textColor)
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  (documentsNeeded[choosenDocs]['has_identify_number'] == true)
                      ? Container(
                          padding: EdgeInsets.only(top: media.height * 0.02),
                          child: InputField(
                            text: (languages[choosenLanguage][documentsNeeded
                                        .firstWhere(
                                            (element) =>
                                                element['id'] == docsId)[
                                            'identify_number_locale_key']
                                        .toString()] !=
                                    null)
                                ? languages[choosenLanguage][
                                    documentsNeeded[choosenDocs]
                                            ['identify_number_locale_key']
                                        .toString()]
                                : documentsNeeded[choosenDocs]
                                    ['identify_number_locale_key'],
                            textController: idNumber,
                            onTap: (val) {
                              setState(() {
                                docIdNumber = idNumber.text;
                              });
                            },
                          ),
                        )
                      : Container(),

                  //error
                  (_error == '')
                      ? Container()
                      : Container(
                          width: media.width * 0.9,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 20),
                          child: Text(
                            _error,
                            style: GoogleFonts.roboto(
                                fontSize: media.width * sixteen,
                                color: Colors.red),
                          )),
                  SizedBox(height: media.height * 0.04),
                  (imageFile != null &&
                          ((documentsNeeded[choosenDocs]
                                          ['has_identify_number'] ==
                                      true &&
                                  idNumber.text.isNotEmpty) ||
                              documentsNeeded[choosenDocs]
                                      ['has_identify_number'] ==
                                  false) &&
                          ((documentsNeeded[choosenDocs]['has_expiry_date'] ==
                                      true &&
                                  date != '') ||
                              documentsNeeded[choosenDocs]['has_expiry_date'] ==
                                  false))
                      ? Button(
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              _loading = true;
                              _error = '';
                            });
                            var result = await uploadDocs();

                            if (result == 'success') {
                              var val = await getDocumentsNeeded();
                              if (val == 'logout') {
                                navigateLogout();
                              }
                              pop();
                            } else if (result == 'logout') {
                              navigateLogout();
                            } else {
                              setState(() {
                                _error = result.toString();
                              });
                            }
                            setState(() {
                              _loading = false;
                            });
                          },
                          text: languages[choosenLanguage]['text_submit'])
                      : Container()
                ],
              ),
            ),

            //upload image popup
            (_uploadImage == true)
                ? Positioned(
                    bottom: 0,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _uploadImage = false;
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
                                              cameraPick();
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
                                                color: const Color(0xff666666)),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              imagePick();
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
                                                color: const Color(0xff666666)),
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

            //permission denied error
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
                                    _uploadImage = false;
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
                                            ? cameraPick()
                                            : imagePick();
                                        setState(() {
                                          _permission = '';
                                        });
                                      },
                                      child: Text(
                                        languages[choosenLanguage]['text_done'],
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
        ),
      ),
    );
  }
}
