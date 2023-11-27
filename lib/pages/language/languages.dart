import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';
import '../../functions/functions.dart';
import '../../widgets/widgets.dart';
import '../login/signupmethod.dart';

class Languages extends StatefulWidget {
  const Languages({Key? key}) : super(key: key);

  @override
  State<Languages> createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  bool _isLoading = false;

  @override
  void initState() {
    choosenLanguage = 'en';
    languageDirection = 'ltr';
    super.initState();
  }

  navigate() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SignupMethod()));
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
                  media.width * 0.05, media.width * 0.05, media.width * 0.05),
              height: media.height * 1,
              width: media.width * 1,
              color: page,
              child: Column(
                children: [
                  Container(
                    height:
                        media.width * 0.11 + MediaQuery.of(context).padding.top,
                    width: media.width * 1,
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    color: page,
                    child: Stack(
                      children: [
                        Container(
                          height: media.width * 0.11,
                          width: media.width * 1,
                          alignment: Alignment.center,
                          child: Text(
                            (choosenLanguage.isEmpty)
                                ? 'Choose Language'
                                : languages[choosenLanguage]
                                    ['text_choose_language'],
                            style: GoogleFonts.roboto(
                                color: textColor,
                                fontSize: media.width * sixteen,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  SizedBox(
                    width: media.width * 0.9,
                    height: media.height * 0.16,
                    child: Image.asset(
                      'assets/images/selectLanguage.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.1,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: languages
                            .map(
                              (i, value) => MapEntry(
                                i,
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      choosenLanguage = i;
                                      if (choosenLanguage == 'ar' ||
                                          choosenLanguage == 'ur' ||
                                          choosenLanguage == 'iw') {
                                        languageDirection = 'rtl';
                                      } else {
                                        languageDirection = 'ltr';
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(media.width * 0.025),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          languagesCode
                                              .firstWhere(
                                                  (e) => e['code'] == i)['name']
                                              .toString(),
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor),
                                        ),
                                        Container(
                                          height: media.width * 0.05,
                                          width: media.width * 0.05,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: (isDarkTheme == true)
                                                      ? textColor
                                                      : const Color(0xff222222),
                                                  width: 1.2)),
                                          alignment: Alignment.center,
                                          child: (choosenLanguage == i)
                                              ? Container(
                                                  height: media.width * 0.03,
                                                  width: media.width * 0.03,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          (isDarkTheme == true)
                                                              ? textColor
                                                              : const Color(
                                                                  0xff222222)),
                                                )
                                              : Container(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .values
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  (choosenLanguage != '')
                      ? Button(
                          onTap: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            // await getlangid();
                            //saving language settings in local
                            pref.setString(
                                'languageDirection', languageDirection);
                            pref.setString('choosenLanguage', choosenLanguage);
                            setState(() {
                              _isLoading = false;
                            });
                            navigate();
                          },
                          text: languages[choosenLanguage]['text_confirm'])
                      : Container(),
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
    );
  }
}
