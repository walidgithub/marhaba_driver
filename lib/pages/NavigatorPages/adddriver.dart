import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/pages/login/signupmethod.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';

class AddDriver extends StatefulWidget {
  const AddDriver({Key? key}) : super(key: key);

  @override
  State<AddDriver> createState() => _AddDriverState();
}

class _AddDriverState extends State<AddDriver> {
  var verifyEmailError = '';
  var error = '';
  bool _loading = true;
  bool _showToast = false;

  TextEditingController name =
      TextEditingController(); //name textediting controller
  TextEditingController email =
      TextEditingController(); //name textediting controller
  TextEditingController mobile =
      TextEditingController(); //name textediting controller
  TextEditingController address =
      TextEditingController(); //name textediting controller

  //navigate
  pop() {
    Navigator.pop(context);
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

  countryCode() async {
    await getCountryCode();
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  showToast() async {
    setState(() {
      _showToast = true;
    });
    var val = await fleetDriverDetails();
    if (val == 'logout') {
      navigateLogout();
    }
    Future.delayed(const Duration(seconds: 1), () async {
      setState(() {
        _showToast = false;
        Navigator.pop(context, true);
      });
      // await fleetDriverDetails();
    });
  }

  @override
  void initState() {
    countryCode();
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
                (countries.isNotEmpty)
                    ? Container(
                        padding: EdgeInsets.fromLTRB(
                            media.width * 0.05,
                            MediaQuery.of(context).padding.top +
                                media.width * 0.05,
                            media.width * 0.05,
                            0),
                        height: media.height * 1,
                        width: media.width * 1,
                        color: page,
                        //history details
                        child: Column(children: [
                          Stack(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.only(bottom: media.width * 0.05),
                                width: media.width * 0.9,
                                alignment: Alignment.center,
                                child: Text(
                                  languages[choosenLanguage]['text_add_driver'],
                                  style: GoogleFonts.roboto(
                                      color: textColor,
                                      fontSize: media.width * sixteen,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Positioned(
                                  child: InkWell(
                                      onTap: () async {
                                        var val = await fleetDriverDetails();
                                        if (val == 'logout') {
                                          navigateLogout();
                                        }

                                        pop();
                                      },
                                      child: Icon(Icons.arrow_back,
                                          color: textColor)))
                            ],
                          ),
                          Expanded(
                              child: Column(
                            children: [
                              InputField(
                                icon: Icons.person_outline_rounded,
                                text: languages[choosenLanguage]['text_name'],
                                onTap: (val) {
                                  setState(() {});
                                },
                                textController: name,
                              ),
                              SizedBox(
                                height: media.height * 0.012,
                              ),
                              // name input field

                              InputField(
                                icon: Icons.email_outlined,
                                text: languages[choosenLanguage]['text_email'],
                                onTap: (val) {
                                  setState(() {});
                                },
                                textController: email,
                                color: (verifyEmailError == '')
                                    ? null
                                    : Colors.red,
                              ),
                              SizedBox(
                                height: media.height * 0.012,
                              ),
                              Container(
                                padding: const EdgeInsets.only(bottom: 5),
                                height: 55,
                                width:
                                    media.width * 1 - (media.width * 0.08 * 2),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: (isDarkTheme == true)
                                      ? textColor.withOpacity(0.4)
                                      : underline,
                                ))),
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
                                                      const EdgeInsets.all(10),
                                                  content: StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                    return Container(
                                                      width: media.width * 0.9,
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
                                                                      left: 20,
                                                                      right:
                                                                          20),
                                                              height: 40,
                                                              width:
                                                                  media.width *
                                                                      0.9,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width:
                                                                          1.5)),
                                                              child: TextField(
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
                                                                    hintText: languages[choosenLanguage][
                                                                        'text_search'],
                                                                    hintStyle: GoogleFonts.roboto(
                                                                        color: textColor.withOpacity(
                                                                            0.4),
                                                                        fontSize:
                                                                            media.width * sixteen)),
                                                                style: GoogleFonts
                                                                    .roboto(
                                                                        color:
                                                                            textColor),
                                                                onChanged:
                                                                    (val) {
                                                                  setState(() {
                                                                    searchVal =
                                                                        val;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.01),
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
                                                                              child: countries.isEmpty
                                                                                  ? Container()
                                                                                  : (searchVal == '' && countries[i]['flag'] != null)
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
                                    SizedBox(
                                      width: media.width * 0.01,
                                    ),
                                    Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      width: media.width * 0.5,
                                      child: TextFormField(
                                        controller: mobile,
                                        onChanged: (val) {
                                          setState(() {});
                                          if (mobile.text.length ==
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
                              SizedBox(
                                height: media.height * 0.012,
                              ),
                              InputField(
                                icon: Icons.home_outlined,
                                text: languages[choosenLanguage]
                                    ['text_address'],
                                onTap: (val) {
                                  setState(() {});
                                },
                                textController: address,
                              ),
                            ],
                          )),
                          (error != '')
                              ? Container(
                                  margin: EdgeInsets.only(
                                      top: media.height * 0.03,
                                      bottom: media.height * 0.03),
                                  alignment: Alignment.center,
                                  width: media.width * 0.8,
                                  child: Text(
                                    error,
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: Colors.red),
                                  ),
                                )
                              : Container(),
                          (name.text.isNotEmpty &&
                                  email.text.isNotEmpty &&
                                  address.text.isNotEmpty &&
                                  mobile.text.isNotEmpty)
                              ? Container(
                                  padding: EdgeInsets.all(media.width * 0.05),
                                  width: media.width * 1,
                                  alignment: Alignment.center,
                                  child: Button(
                                      onTap: () async {
                                        String pattern =
                                            r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])*$";
                                        RegExp regex = RegExp(pattern);
                                        if (regex.hasMatch(email.text)) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          setState(() {
                                            verifyEmailError = '';
                                            error = '';
                                            _loading = true;
                                          });
                                          var result = await validateEmail(
                                              email.text.toString());

                                          if (result == 'success') {
                                            setState(() {
                                              verifyEmailError = '';
                                            });
                                            Map<String, dynamic> map = {
                                              'name': name.text.toString(),
                                              'email': email.text.toString(),
                                              'mobile': mobile.text.toString(),
                                              'address':
                                                  address.text.toString(),
                                            };
                                            var val = await fleetDriver(map);
                                            if (val == 'true') {
                                              showToast();
                                              serviceLocations.clear();
                                            } else if (val == 'logout') {
                                              navigateLogout();
                                            } else {
                                              error = val.toString();
                                            }
                                          } else {
                                            setState(() {
                                              verifyEmailError =
                                                  result.toString();
                                              error = result.toString();
                                            });
                                            debugPrint('failed');
                                          }
                                          setState(() {
                                            _loading = false;
                                          });
                                        } else {
                                          setState(() {
                                            verifyEmailError =
                                                languages[choosenLanguage]
                                                    ['text_email_validation'];
                                            error = languages[choosenLanguage]
                                                ['text_email_validation'];
                                          });
                                        }
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_next']))
                              : Container(),
                        ]),
                      )
                    : Container(
                        height: media.height * 1,
                        width: media.width * 1,
                        color: page,
                      ),
                (_loading == true)
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
                            languages[choosenLanguage]['text_driver_added'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: Colors.white),
                          ),
                        ))
                    : Container()
              ],
            )));
  }
}
