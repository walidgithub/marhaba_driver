import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';

class FleetDetails extends StatefulWidget {
  const FleetDetails({Key? key}) : super(key: key);

  @override
  State<FleetDetails> createState() => _FleetDetailsState();
}

class _FleetDetailsState extends State<FleetDetails> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.fromLTRB(media.width * 0.05, media.width * 0.05,
              media.width * 0.05, media.width * 0.05),
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
                    child: SizedBox(
                      width: media.width * 0.7,
                      child: Text(
                        languages[choosenLanguage]['text_fleet_details'],
                        style: GoogleFonts.roboto(
                            fontSize: media.width * twenty,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                        textAlign: TextAlign.center,
                      ),
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
              Expanded(
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: (userDetails['vehicle_type_id'] != null)
                          ? Container(
                              width: media.width * 0.9,
                              padding: EdgeInsets.all(media.width * 0.025),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 2,
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.3)
                                            : Colors.black.withOpacity(0.2),
                                        spreadRadius: 2),
                                  ],
                                  color: page),
                              child: Column(
                                children: [
                                  Text(
                                    languages[choosenLanguage]['text_type'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.5)
                                            : hintColor),
                                  ),
                                  SizedBox(
                                    height: media.width * 0.025,
                                  ),
                                  userDetails['vehicle_type_name'] != null
                                      ? Text(
                                          userDetails['vehicle_type_name'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        )
                                      : const Text(''),
                                  SizedBox(
                                    height: media.width * 0.05,
                                  ),
                                  Text(
                                    languages[choosenLanguage]['text_make'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.5)
                                            : hintColor),
                                  ),
                                  SizedBox(
                                    height: media.width * 0.025,
                                  ),
                                  userDetails['car_make_name'] != null
                                      ? Text(
                                          userDetails['car_make_name'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        )
                                      : const Text(''),
                                  SizedBox(
                                    height: media.width * 0.05,
                                  ),
                                  Text(
                                    languages[choosenLanguage]['text_model'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.5)
                                            : hintColor),
                                  ),
                                  SizedBox(
                                    height: media.width * 0.025,
                                  ),
                                  userDetails['car_model_name'] != null
                                      ? Text(
                                          userDetails['car_model_name'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        )
                                      : const Text(''),
                                  SizedBox(
                                    height: media.width * 0.05,
                                  ),
                                  Text(
                                    languages[choosenLanguage]['text_number'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.5)
                                            : hintColor),
                                  ),
                                  SizedBox(
                                    height: media.width * 0.025,
                                  ),
                                  userDetails['car_number'] != null
                                      ? Text(
                                          userDetails['car_number'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        )
                                      : const Text(''),
                                  SizedBox(
                                    height: media.width * 0.05,
                                  ),
                                  Text(
                                    languages[choosenLanguage]['text_color'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.5)
                                            : hintColor),
                                  ),
                                  SizedBox(
                                    height: media.width * 0.025,
                                  ),
                                  userDetails['car_color'] != null
                                      ? Text(
                                          userDetails['car_color'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        )
                                      : const Text(''),
                                  SizedBox(
                                    height: media.width * 0.05,
                                  ),
                                ],
                              ),
                            )
                          : Column(
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
                                        ['text_no_fleet_assigned'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        fontWeight: FontWeight.bold,
                                        color: textColor),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ))),
            ],
          ),
        ),
      ),
    );
  }
}
