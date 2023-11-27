import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/get_started.dart';
import 'package:tagxidriver/pages/login/login.dart';
import 'package:tagxidriver/pages/login/otp_page.dart';
import 'package:tagxidriver/pages/noInternet/nointernet.dart';
import 'package:tagxidriver/translation/translation.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import '../../widgets/widgets.dart';

class SignInwithEmail extends StatefulWidget {
  const SignInwithEmail({Key? key}) : super(key: key);

  @override
  State<SignInwithEmail> createState() => _SignInwithEmailState();
}

class _SignInwithEmailState extends State<SignInwithEmail> {
  TextEditingController controller = TextEditingController();

  bool terms = true; //terms and conditions true or false
  bool _isLoading = true;
  bool validate = false;
  var verifyEmailError = '';
  var _error = '';

  @override
  void initState() {
    countryCode();
    super.initState();
  }

  countryCode() async {
    await getCountryCode();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //navigate
  navigate() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Otp()));
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
              color: page,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: media.width * 0.08,
                  right: media.width * 0.08),
              height: media.height * 1,
              width: media.width * 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: media.height * 0.195),
                  Text(
                    languages[choosenLanguage]['text_sign_up_email'],
                    style: GoogleFonts.roboto(
                        fontSize: media.width * twentysix,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  SizedBox(
                    height: media.height * 0.159,
                  ),
                  Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      height: 55,
                      width: media.width * 1 - (media.width * 0.08 * 2),
                      child: InputField(
                        text: languages[choosenLanguage]['text_email'],
                        onTap: (val) {
                          setState(() {
                            email = controller.text;
                          });
                        },
                        textController: controller,
                        color: (verifyEmailError == '') ? null : Colors.red,
                      )),
                  (_error != '')
                      ? Container(
                          width: media.width * 0.8,
                          margin: EdgeInsets.only(top: media.height * 0.02),
                          alignment: Alignment.center,
                          child: Text(
                            _error,
                            style: GoogleFonts.roboto(
                                fontSize: media.width * sixteen,
                                color: Colors.red),
                          ),
                        )
                      : Container(),
                  SizedBox(height: media.height * 0.05),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (terms == true) {
                              terms = false;
                            } else {
                              terms = true;
                            }
                          });
                        },
                        child: Container(
                            height: media.width * 0.08,
                            width: media.width * 0.08,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: buttonColor, width: 2),
                                shape: BoxShape.circle,
                                color: (terms == true) ? buttonColor : page),
                            child: Icon(Icons.done,
                                color: (isDarkTheme == true)
                                    ? Colors.black
                                    : Colors.white)),
                      ),
                      SizedBox(
                        width: media.width * 0.02,
                      ),

                      //terms and condition and privacy policy url
                      SizedBox(
                        width: media.width * 0.7,
                        child: Wrap(
                          direction: Axis.horizontal,
                          children: [
                            Text(
                              languages[choosenLanguage]['text_agree'] + ' ',
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor.withOpacity(0.7)),
                            ),
                            InkWell(
                              onTap: () {
                                openBrowser('${url}terms');
                              },
                              child: Text(
                                languages[choosenLanguage]['text_terms'],
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * sixteen,
                                    color: buttonColor),
                              ),
                            ),
                            Text(
                              ' ${languages[choosenLanguage]['text_and']} ',
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor.withOpacity(0.7)),
                            ),
                            InkWell(
                              onTap: () {
                                openBrowser('${url}privacy');
                              },
                              child: Text(
                                languages[choosenLanguage]['text_privacy'],
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * sixteen,
                                    color: buttonColor),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: media.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        size: media.width * eighteen,
                        color: textColor.withOpacity(0.7),
                      ),
                      SizedBox(width: media.width * 0.02),
                      Text(
                        languages[choosenLanguage]['text_continue_with'],
                        style: GoogleFonts.roboto(
                          color: textColor.withOpacity(0.7),
                          fontSize: media.width * sixteen,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        width: media.width * 0.01,
                      ),
                      InkWell(
                        onTap: () {
                          controller.clear();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()));
                        },
                        child: Text(
                          languages[choosenLanguage]['text_phone_number'],
                          style: GoogleFonts.roboto(
                              fontSize: media.width * sixteen,
                              fontWeight: FontWeight.w400,
                              color: loaderColor),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: media.height * 0.1,
                  ),
                  (controller.text.isNotEmpty)
                      ? Container(
                          width: media.width * 1,
                          alignment: Alignment.center,
                          child: Button(
                              onTap: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                String pattern =
                                    r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                RegExp regex = RegExp(pattern);
                                if (regex.hasMatch(controller.text)) {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  setState(() {
                                    verifyEmailError = '';
                                    _error = '';
                                    _isLoading = true;
                                  });

                                  phoneAuthCheck = true;
                                  await sendOTPtoEmail(email);
                                  value = 1;
                                  navigate();
                                } else {
                                  verifyEmailError = languages[choosenLanguage]
                                      ['text_email_validation'];
                                  _error = languages[choosenLanguage]
                                      ['text_email_validation'];
                                }

                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              text: languages[choosenLanguage]['text_login']))
                      : Container(),
                ],
              ),
            ),

            //No internet
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(onTap: () {
                      setState(() {
                        _isLoading = true;
                        internet = true;
                        countryCode();
                      });
                    }))
                : Container(),

            //loader
            (_isLoading == true)
                ? const Positioned(top: 0, child: Loading())
                : Container()
          ],
        ),
      ),
    );
  }
}
