import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/pages/vehicleInformations/service_area.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';
import 'package:tagxidriver/widgets/widgets.dart';

class UpdateVehicle extends StatefulWidget {
  const UpdateVehicle({Key? key}) : super(key: key);

  @override
  State<UpdateVehicle> createState() => _UpdateVehicleState();
}

class _UpdateVehicleState extends State<UpdateVehicle> {
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
                        languages[choosenLanguage]['text_updateVehicle'],
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
                      child: Container(
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
                            userDetails['vehicle_types'] == []
                                ? Text(
                                    userDetails['vehicle_type_name'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: textColor,
                                        fontWeight: FontWeight.w600),
                                  )
                                : Container(),
                            if (userDetails['vehicle_types'] != [])
                              for (var i = 0;
                                  i <=
                                      userDetails['driverVehicleType']['data']
                                              .length -
                                          1;
                                  i++)
                                Text(
                                  '${userDetails['driverVehicleType']['data'][i]['vehicletype_name']}',
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * sixteen,
                                      color: textColor,
                                      fontWeight: FontWeight.w600),
                                ),
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
                            Text(
                              userDetails['car_make_name'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
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
                            Text(
                              userDetails['car_model_name'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
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
                            Text(
                              userDetails['car_number'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
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
                            Text(
                              userDetails['car_color'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                          ],
                        ),
                      ))),

              //navigate to pick service page
              Button(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ServiceArea()));
                  },
                  text: languages[choosenLanguage]['text_edit'])
            ],
          ),
        ),
      ),
    );
  }
}
