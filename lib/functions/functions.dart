import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geolocs;
import 'package:location/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tagxidriver/pages/NavigatorPages/editprofile.dart';
import 'package:tagxidriver/pages/NavigatorPages/history.dart';
import 'package:tagxidriver/pages/NavigatorPages/makecomplaint.dart';
import 'package:tagxidriver/pages/login/get_started.dart';
import 'package:tagxidriver/pages/login/login.dart';
import 'package:tagxidriver/pages/login/otp_page.dart';
import 'package:tagxidriver/pages/onTripPage/droplocation.dart';
import 'package:tagxidriver/pages/onTripPage/invoice.dart';
import 'package:tagxidriver/pages/onTripPage/map_page.dart';
import 'package:tagxidriver/pages/onTripPage/review_page.dart';
import 'package:tagxidriver/pages/vehicleInformations/referral_code.dart';
import 'package:tagxidriver/pages/vehicleInformations/service_area.dart';
import 'package:tagxidriver/pages/vehicleInformations/upload_docs.dart';
import 'package:tagxidriver/pages/vehicleInformations/vehicle_color.dart';
import 'package:tagxidriver/pages/vehicleInformations/vehicle_make.dart';
import 'package:tagxidriver/pages/vehicleInformations/vehicle_model.dart';
import 'package:tagxidriver/pages/vehicleInformations/vehicle_number.dart';
import 'package:tagxidriver/pages/vehicleInformations/vehicle_type.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tagxidriver/pages/vehicleInformations/vehicle_year.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/NavigatorPages/fleetdocuments.dart';
import '../pages/login/ownerregister.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'geohash.dart';

//languages code
dynamic phcode;
dynamic platform;
dynamic pref;
String isActive = '';
double duration = 0.0;
AudioCache audioPlayer = AudioCache();
AudioPlayer audioPlayers = AudioPlayer();
String audio = 'audio/notification_sound.mp3';
bool internet = true;
dynamic centerCheck;
List tripStops = [];

String ischeckownerordriver = '';

//base url
String url = 'https://taxi.hostk.com/';
String mapkey = 'AIzaSyC9sBlFf7ThU407w6iYhW4i4HmGHP7dkLY';
String mapStyle = '';

getDetailsOfDevice() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    internet = false;
  } else {
    internet = true;
  }
  try {
    pref = await SharedPreferences.getInstance();
    if (pref.containsKey('isDarkTheme')) {
      isDarkTheme = pref.getBool('isDarkTheme');
    }
    await darktheme();
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

darktheme() async {
  if (isDarkTheme == true) {
    page = Colors.black;
    textColor = Colors.white;
    buttonColor = Colors.white;
    loaderColor = Colors.white;
    buttonText = Colors.black;
  } else {
    page = Colors.white;
    textColor = Colors.black;
    buttonColor = theme;
    loaderColor = theme;
    buttonText = const Color(0xffFFFFFF);
  }
  if (isDarkTheme == true) {
    rootBundle.loadString('assets/dark.json').then((value) {
      mapStyle = value;
    });
  } else {
    rootBundle.loadString('assets/map_style.json').then((value) {
      mapStyle = value;
    });
  }

  if (isDarkTheme == true) {
    await rootBundle.loadString('assets/dark.json').then((value) {
      mapStyle = value;
    });
  } else {
    await rootBundle.loadString('assets/map_style.json').then((value) {
      mapStyle = value;
    });
  }
}

//validate email already exist

validateEmail(email) async {
  dynamic result;
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/driver/validate-mobile'), body: {
      'email': email,
      "role": userDetails.isNotEmpty
          ? userDetails['role'].toString()
          : ischeckownerordriver
    });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//lang
getlangid() async {
  dynamic result;
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/user/update-my-lang'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
    }, body: {
      'lang': choosenLanguage,
    });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//language code
var choosenLanguage = '';
var languageDirection = '';

List languagesCode = [
  {'name': 'Amharic', 'code': 'am'},
  {'name': 'Arabic', 'code': 'ar'},
  {'name': 'Basque', 'code': 'eu'},
  {'name': 'Bengali', 'code': 'bn'},
  {'name': 'English (UK)', 'code': 'en-GB'},
  {'name': 'Portuguese (Brazil)', 'code': 'pt-BR'},
  {'name': 'Bulgarian', 'code': 'bg'},
  {'name': 'Catalan', 'code': 'ca'},
  {'name': 'Cherokee', 'code': 'chr'},
  {'name': 'Croatian', 'code': 'hr'},
  {'name': 'Czech', 'code': 'cs'},
  {'name': 'Danish', 'code': 'da'},
  {'name': 'Dutch', 'code': 'nl'},
  {'name': 'English (US)', 'code': 'en'},
  {'name': 'Estonian', 'code': 'et'},
  {'name': 'Filipino', 'code': 'fil'},
  {'name': 'Finnish', 'code': 'fi'},
  {'name': 'French', 'code': 'fr'},
  {'name': 'German', 'code': 'de'},
  {'name': 'Greek', 'code': 'el'},
  {'name': 'Gujarati', 'code': 'gu'},
  {'name': 'Hebrew', 'code': 'iw'},
  {'name': 'Hindi', 'code': 'hi'},
  {'name': 'Hungarian', 'code': 'hu'},
  {'name': 'Icelandic', 'code': 'is'},
  {'name': 'Indonesian', 'code': 'id'},
  {'name': 'Italian', 'code': 'it'},
  {'name': 'Japanese', 'code': 'ja'},
  {'name': 'Kannada', 'code': 'kn'},
  {'name': 'Korean', 'code': 'ko'},
  {'name': 'Latvian', 'code': 'lv'},
  {'name': 'Lithuanian', 'code': 'lt'},
  {'name': 'Malay', 'code': 'ms'},
  {'name': 'Malayalam', 'code': 'ml'},
  {'name': 'Marathi', 'code': 'mr'},
  {'name': 'Norwegian', 'code': 'no'},
  {'name': 'Polish', 'code': 'pl'},
  {
    'name': 'Portuguese (Portugal)',
    'code': 'pt' //pt-PT
  },
  {'name': 'Romanian', 'code': 'ro'},
  {'name': 'Russian', 'code': 'ru'},
  {'name': 'Serbian', 'code': 'sr'},
  {
    'name': 'Chinese (PRC)',
    'code': 'zh' //zh-CN
  },
  {'name': 'Slovak', 'code': 'sk'},
  {'name': 'Slovenian', 'code': 'sl'},
  {'name': 'Spanish', 'code': 'es'},
  {'name': 'Swahili', 'code': 'sw'},
  {'name': 'Swedish', 'code': 'sv'},
  {'name': 'Tamil', 'code': 'ta'},
  {'name': 'Telugu', 'code': 'te'},
  {'name': 'Thai', 'code': 'th'},
  {'name': 'Chinese (Taiwan)', 'code': 'zh-TW'},
  {'name': 'Turkish', 'code': 'tr'},
  {'name': 'Urdu', 'code': 'ur'},
  {'name': 'Ukrainian', 'code': 'uk'},
  {'name': 'Vietnamese', 'code': 'vi'},
  {'name': 'Welsh', 'code': 'cy'},
];

//upload docs

uploadDocs() async {
  dynamic result;
  try {
    var response = http.MultipartRequest(
        'POST', Uri.parse('${url}api/v1/driver/upload/documents'));
    response.headers
        .addAll({'Authorization': 'Bearer ${bearerToken[0].token}'});
    response.files
        .add(await http.MultipartFile.fromPath('document', imageFile));
    if (documentsNeeded[choosenDocs]['has_expiry_date'] == true) {
      response.fields['expiry_date'] = expDate.toString().substring(0, 19);
    }

    if (documentsNeeded[choosenDocs]['has_identify_number'] == true) {
      response.fields['identify_number'] = docIdNumber;
    }

    response.fields['document_id'] = docsId.toString();

    var request = await response.send();

    var respon = await http.Response.fromStream(request);

    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      result = val['message'];
    } else if (request.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else if (respon.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(respon.body);
      result = val['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

uploadFleetDocs(fleetid) async {
  dynamic result;
  try {
    var response = http.MultipartRequest(
        'POST', Uri.parse('${url}api/v1/driver/upload/documents'));
    response.headers
        .addAll({'Authorization': 'Bearer ${bearerToken[0].token}'});

    response.files
        .add(await http.MultipartFile.fromPath('document', fleetimageFile));

    if (fleetdocumentsNeeded[fleetchoosenDocs]['has_expiry_date'] == true) {
      response.fields['expiry_date'] = fleetexpDate.toString().substring(0, 19);
    }

    if (fleetdocumentsNeeded[fleetchoosenDocs]['has_identify_number'] == true) {
      response.fields['identify_number'] = fleetdocIdNumber;
    }

    response.fields['fleet_id'] = fleetid.toString();

    response.fields['document_id'] = fleetdocsId.toString();
    var request = await response.send();
    var respon = await http.Response.fromStream(request);

    final val = jsonDecode(respon.body);

    if (request.statusCode == 200) {
      result = val['message'];
    } else if (request.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else if (request.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(respon.body);
      result = val['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//getting country code

List countries = [];
getCountryCode() async {
  dynamic result;
  try {
    final response = await http.get(Uri.parse('${url}api/v1/countries'));

    if (response.statusCode == 200) {
      countries = jsonDecode(response.body)['data'];
      phcode =
          (countries.where((element) => element['default'] == true).isNotEmpty)
              ? countries.indexWhere((element) => element['default'] == true)
              : 0;
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'error';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//login firebase

String userUid = '';
var verId = '';
int? resendTokenId;
bool phoneAuthCheck = false;
dynamic credentials;

phoneAuth(String phone) async {
  try {
    credentials = null;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        credentials = credential;
        valueNotifierHome.incrementNotifier();
      },
      forceResendingToken: resendTokenId,
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          debugPrint('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        verId = verificationId;
        resendTokenId = resendToken;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//Email
sendOTPtoEmail(String email) async {
  dynamic result;
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/send-mail-otp'), body: {'email': email});
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

dynamic otpval;

emailVerify(String email, otpNumber) async {
  try {
    var response = await http.post(Uri.parse('${url}api/v1/validate-email-otp'),
        body: {"email": email, "otp": otpNumber});
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        // print(otpval);
        otpval = 'success';
      } else {
        debugPrint(response.body);
        otpval = 'failed';
      }
    }
    return otpval;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//get local bearer token
String lastNotification = '';

getLocalData() async {
  dynamic result;
  bearerToken.clear;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    internet = false;
  } else {
    internet = true;
  }
  try {
    if (pref.containsKey('lastNotification')) {
      lastNotification = pref.getString('lastNotification');
    }
    if (pref.containsKey('autoAddress')) {
      var val = pref.getString('autoAddress');
      storedAutoAddress = jsonDecode(val);
    }
    if (pref.containsKey('choosenLanguage')) {
      choosenLanguage = pref.getString('choosenLanguage');
      languageDirection = pref.getString('languageDirection');

      if (choosenLanguage.isNotEmpty) {
        if (pref.containsKey('Bearer')) {
          var tokens = pref.getString('Bearer');
          if (tokens != null) {
            bearerToken.add(BearerClass(type: 'Bearer', token: tokens));

            var responce = await getUserDetails();
            if (responce == true) {
              if (userDetails['role'] != 'owner' &&
                  platform == TargetPlatform.android) {
                platforms.invokeMethod('login');
              }
              result = '3';
            } else if (responce == false) {
              result = '2';
            }
          } else {
            result = '2';
          }
        } else {
          result = '2';
        }
      } else {
        result = '1';
      }
    } else {
      result = '1';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//get service locations

List serviceLocations = [];

getServiceLocation() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse('${url}api/v1/servicelocation'),
    );

    if (response.statusCode == 200) {
      serviceLocations = jsonDecode(response.body)['data'];
      res = 'success';
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }
  return res;
}

//get vehicle type

List vehicleType = [];

getvehicleType() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse('${url}api/v1/types/$myServiceId'),
    );

    if (response.statusCode == 200) {
      vehicleType = jsonDecode(response.body)['data'];
      res = 'success';
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      res = 'no internet';
      internet = false;
    }
  }

  return res;
}

//get vehicle make

List vehicleMake = [];

getVehicleMake() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse('${url}api/v1/common/car/makes?vehicle_type=$myVehicleIconFor'),
    );

    if (response.statusCode == 200) {
      vehicleMake = jsonDecode(response.body)['data'];
      res = 'success';
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }
  return res;
}

//get vehicle model

List vehicleModel = [];

getVehicleModel() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse('${url}api/v1/common/car/models/${vehicleMakeId.toString()}'),
    );

    if (response.statusCode == 200) {
      vehicleModel = jsonDecode(response.body)['data'];
      res = 'success';
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }
  return res;
}

//register driver

List<BearerClass> bearerToken = <BearerClass>[];
List<String> vehicletypelist = [];

registerDriver() async {
  bearerToken.clear();
  dynamic result;
  int i = 0;
  if (phnumber[0] == '0') {
    String finalStr = phnumber.substring(0, i) + phnumber.substring(i + 1);
    phnumber = finalStr;
  }
  // print(phnumber);

  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    final response = http.MultipartRequest(
        'POST', Uri.parse('${url}api/v1/driver/register'));

    response.headers.addAll({'Content-Type': 'application/json'});
    if (proImageFile1 != null) {
      response.files.add(
          await http.MultipartFile.fromPath('profile_picture', proImageFile1));
    }
    response.fields.addAll({
      "name": name,
      "mobile": phnumber,
      "email": email,
      "device_token": fcm,
      "country": countries[phcode]['code'],
      "service_location_id": myServiceId.toString(),
      "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
      "vehicle_types": jsonEncode(vehicletypelist),
      "vehicle_type": myVehicleId.toString(),
      "car_make": vehicleMakeId.toString(),
      "car_model": vehicleModelId.toString(),
      "car_color": vehicleColor,
      "car_number": vehicleNumber,
      "vehicle_year": modelYear,
      'lang': choosenLanguage,
      'email_confirmed': (value == 0) ? 'true' : 'false'
    });

    var request = await response.send();
    var respon = await http.Response.fromStream(request);

    if (request.statusCode == 200) {
      var jsonVal = jsonDecode(respon.body);
      if (ischeckownerordriver == 'driver' &&
          platform == TargetPlatform.android) {
        platforms.invokeMethod('login');
      }
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      pref.setString('Bearer', bearerToken[0].token);
      await getUserDetails();
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'driver_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'driver_bundle_id': package.packageName.toString()});
      }
      result = 'true';
    } else if (respon.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(respon.body);
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

addDriver() async {
  dynamic result;
  try {
    final response = await http.post(Uri.parse('${url}api/v1/owner/add-fleet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${bearerToken[0].token}',
        },
        body: jsonEncode({
          "vehicle_type": vehicletypelist[0].toString(),
          "car_make": vehicleMakeId,
          "car_model": vehicleModelId,
          "car_color": vehicleColor,
          "car_number": vehicleNumber,
        }));

    if (response.statusCode == 200) {
      result = 'true';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//request notification
List notificationHistory = [];
Map<String, dynamic> notificationHistoryPage = {};

getnotificationHistory() async {
  dynamic result;

  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/get-notification'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      notificationHistory = jsonDecode(response.body)['data'];
      notificationHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

getNotificationPages(id) async {
  dynamic result;

  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/get-notification?$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body)['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        notificationHistory.add(element);
      });
      notificationHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//delete notification
deleteNotification(id) async {
  dynamic result;

  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/delete-notification/$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

sharewalletfun({mobile, role, amount}) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/wallet/transfer-money-from-wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${bearerToken[0].token}',
        },
        body: jsonEncode({'mobile': mobile, 'role': role, 'amount': amount}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//register owner

registerOwner() async {
  bearerToken.clear();
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    final response =
        http.MultipartRequest('POST', Uri.parse('${url}api/v1/owner/register'));
    response.headers.addAll({'Content-Type': 'application/json'});
    if (proImageFile1 != null) {
      response.files.add(
          await http.MultipartFile.fromPath('profile_picture', proImageFile1));
    }
    response.fields.addAll({
      "name": ownerName,
      "mobile": phnumber,
      "email": email,
      "address": companyAddress,
      "postal_code": postalCode,
      "city": city,
      "tax_number": taxNumber,
      "company_name": companyName,
      "device_token": fcm,
      "country": countries[phcode]['code'],
      "service_location_id": ownerServiceLocation,
      "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
      'lang': choosenLanguage,
      'email_confirmed': (value == 0) ? 'false' : 'true'
    });

    var request = await response.send();
    var respon = await http.Response.fromStream(request);

    if (respon.statusCode == 200) {
      var jsonVal = jsonDecode(respon.body);

      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      pref.setString('Bearer', bearerToken[0].token);
      await getUserDetails();
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'driver_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'driver_bundle_id': package.packageName.toString()});
      }
      result = 'true';
    } else if (respon.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(respon.body);
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

List fleetdriverList = [];
fleetDriverDetails({fleetid, bool? isassigndriver}) async {
  dynamic result;
  fleetdriverList.clear();
  try {
    var response = await http.get(
      Uri.parse(isassigndriver == true
          ? '${url}api/v1/owner/list-drivers?fleet_id=$fleetid'
          : '${url}api/v1/owner/list-drivers'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      fleetdriverList = jsonDecode(response.body)['data'];
      result = true;
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

assignDriver(driverid, fleet) async {
  dynamic result;
  try {
    final response =
        await http.post(Uri.parse('${url}api/v1/owner/assign-driver/$fleet'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'driver_id': driverid}));

    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);

      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      pref.setString('Bearer', bearerToken[0].token);
      result = 'true';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

fleetDriver(Map<String, dynamic> map) async {
  dynamic result;
  try {
    final response =
        await http.post(Uri.parse('${url}api/v1/owner/add-drivers'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode(map));

    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);

      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      pref.setString('Bearer', bearerToken[0].token);
      result = 'true';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//update referral code

updateReferral() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/update/driver/referral'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({"refferal_code": referralCode}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'true';
      } else {
        debugPrint(response.body);
        result = 'false';
      }
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'false';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//get documents needed

List documentsNeeded = [];
bool enableDocumentSubmit = false;

getDocumentsNeeded() async {
  dynamic result;
  try {
    final response = await http
        .get(Uri.parse('${url}api/v1/driver/documents/needed'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      documentsNeeded = jsonDecode(response.body)['data'];
      enableDocumentSubmit = jsonDecode(response.body)['enable_submit_button'];

      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

List fleetdocumentsNeeded = [];
bool enablefleetDocumentSubmit = false;

getFleetDocumentsNeeded(fleetid) async {
  dynamic result;
  try {
    final response = await http.get(
        Uri.parse(
            '${url}api/v1/owner/fleet/documents/needed?fleet_id=$fleetid'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        });
    if (response.statusCode == 200) {
      fleetdocumentsNeeded = jsonDecode(response.body)['data'];
      enablefleetDocumentSubmit =
          jsonDecode(response.body)['enable_submit_button'];
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}
//call firebase otp

otpCall() async {
  dynamic result;
  try {
    var otp = await FirebaseDatabase.instance.ref().child('call_FB_OTP').get();
    result = otp;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no Internet';
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

// verify user already exist

verifyUser(String number) async {
  dynamic val;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/driver/validate-mobile-for-login'),
        body: (value == 0)
            ? {"mobile": number, "role": ischeckownerordriver}
            : {"email": email, "role": ischeckownerordriver});

    if (response.statusCode == 200) {
      val = jsonDecode(response.body)['success'];
      if (val == true) {
        var check = await driverLogin();
        if (check == true) {
          var uCheck = await getUserDetails();
          val = uCheck;
        } else {
          val = check;
        }
      } else {
        val = false;
      }
    } else {
      debugPrint(response.body);
      val = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      val = 'no internet';
      internet = false;
    }
  }

  return val;
}

//driver login
driverLogin() async {
  bearerToken.clear();
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/driver/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: (value == 0)
            ? jsonEncode({
                "mobile": phnumber,
                'device_token': fcm,
                "login_by":
                    (platform == TargetPlatform.android) ? 'android' : 'ios',
                "role": ischeckownerordriver,
              })
            : jsonEncode({
                "email": email,
                "otp": otpNumber,
                'device_token': fcm,
                "login_by":
                    (platform == TargetPlatform.android) ? 'android' : 'ios',
                "role": ischeckownerordriver,
              }));
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      if (ischeckownerordriver == 'driver' &&
          platform == TargetPlatform.android) {
        platforms.invokeMethod('login');
      }
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'driver_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'driver_bundle_id': package.packageName.toString()});
      }
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

Map<String, dynamic> userDetails = {};
bool isBackground = false;
bool screenOn = false;
dynamic _version;
bool updateAvailable = false;
dynamic package;

checkVersion() async {
  package = await PackageInfo.fromPlatform();
  try {
    if (platform == TargetPlatform.android) {
      _version = await FirebaseDatabase.instance
          .ref()
          .child('driver_android_version')
          .get();
    } else {
      _version = await FirebaseDatabase.instance
          .ref()
          .child('driver_ios_version')
          .get();
    }
    if (_version.value != null) {
      var version = _version.value.toString().split('.');
      var packages = package.version.toString().split('.');

      for (var i = 0; i < version.length || i < packages.length; i++) {
        if (i < version.length && i < packages.length) {
          if (int.parse(packages[i]) < int.parse(version[i])) {
            updateAvailable = true;
            valueNotifierHome.incrementNotifier();

            break;
          } else if (int.parse(packages[i]) > int.parse(version[i])) {
            updateAvailable = false;

            break;
          }
        } else if (i >= version.length && i < packages.length) {
          updateAvailable = false;

          break;
        } else if (i < version.length && i >= packages.length) {
          updateAvailable = true;
          valueNotifierHome.incrementNotifier();

          break;
        }
      }
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

//user current state
getUserDetails() async {
  dynamic result;

  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${bearerToken[0].token}'
      },
    );
    if (response.statusCode == 200) {
      userDetails = jsonDecode(response.body)['data'];
      if (userDetails['notifications_count'] != 0 &&
          userDetails['notifications_count'] != null) {
        valueNotifierNotification.incrementNotifier();
      }
      if (userDetails['role'] != 'owner') {
        if (userDetails['sos']['data'] != null) {
          sosData = userDetails['sos']['data'];
        }

        if (userDetails['onTripRequest'] != null) {
          driverReq = userDetails['onTripRequest']['data'];

          if (payby == 0 && driverReq['is_paid'] == 1) {
            payby = 1;
            // audioPlayer.play(audio);
          }

          if (driverReq['is_driver_arrived'] == 1 &&
              driverReq['is_trip_start'] == 0 &&
              arrivedTimer == null &&
              driverReq['is_rental'] != true) {
            waitingBeforeStart();
          }
          if (driverReq['is_completed'] == 0 &&
              driverReq['is_trip_start'] == 1 &&
              rideTimer == null &&
              driverReq['is_rental'] != true) {
            waitingAfterStart();
          }

          if (driverReq['accepted_at'] != null) {
            getCurrentMessages();
          }
          tripStops =
              userDetails['onTripRequest']['data']['requestStops']['data'];
          valueNotifierHome.incrementNotifier();
        } else if (userDetails['metaRequest'] != null) {
          driverReject = false;
          userReject = false;
          driverReq = userDetails['metaRequest']['data'];
          tripStops =
              userDetails['metaRequest']['data']['requestStops']['data'];

          if (duration == 0 || duration == 0.0) {
            if (isBackground == true && platform == TargetPlatform.android) {
              platforms.invokeMethod('awakeapp');
            }
            duration = double.parse(
                userDetails['trip_accept_reject_duration_for_driver']
                    .toString());
            sound();
          }
          streamEnd(driverReq['id']);

          valueNotifierHome.incrementNotifier();
        } else {
          duration = 0;

          chatList.clear();
          driverReq = {};
          tripStops.clear();

          valueNotifierHome.incrementNotifier();
        }

        if (userDetails['active'] == false) {
          isActive = 'false';
        } else {
          if (screenOn == false) {
            if (platform == TargetPlatform.android) {
              platforms.invokeMethod('keepon');
            }
            screenOn = true;
          }
          isActive = 'true';
        }
      }
      result = true;
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }

  return result;
}

class BearerClass {
  final String type;
  final String token;
  BearerClass({required this.type, required this.token});

  BearerClass.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        token = json['token'];

  Map<String, dynamic> toJson() => {'type': type, 'token': token};
}

Map<String, dynamic> driverReq = {};
bool userReject = false;

class ValueNotifying {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifying valueNotifier = ValueNotifying();

class ValueNotifyingHome {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

class ValueNotifyingNotification {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifying valueNotifierHome = ValueNotifying();
ValueNotifying valueNotifiercheck = ValueNotifying();
ValueNotifyingNotification valueNotifierNotification =
    ValueNotifyingNotification();

//driver online offline status
driverStatus() async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/driver/online-offline'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      userDetails = jsonDecode(response.body)['data'];
      result = true;
      if (userDetails['active'] == false) {
        if (screenOn == true) {
          if (platform == TargetPlatform.android) {
            platforms.invokeMethod('keepoff');
            screenOn = false;
          }
        }
        userInactive();
      } else {
        if (screenOn == false) {
          if (platform == TargetPlatform.android) {
            platforms.invokeMethod('keepon');
            screenOn = true;
          }
        }
        userActive();
      }
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

const platforms = MethodChannel('flutter.app/awake');

//update driver location in firebase

Location location = Location();

currentPositionUpdate() async {
  geolocs.LocationPermission permission;
  GeoHasher geo = GeoHasher();

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (userDetails.isNotEmpty && userDetails['role'] == 'driver') {
      serviceEnabled =
          await geolocs.GeolocatorPlatform.instance.isLocationServiceEnabled();
      permission = await geolocs.GeolocatorPlatform.instance.checkPermission();

      if (userDetails['active'] == true &&
          serviceEnabled == true &&
          permission != geolocs.LocationPermission.denied &&
          permission != geolocs.LocationPermission.deniedForever) {
        if (driverReq.isEmpty) {
          if (requestStreamStart == null ||
              requestStreamStart?.isPaused == true) {
            streamRequest();
          }
        } else if (driverReq.isNotEmpty && driverReq['accepted_at'] != null) {
          if (rideStreamStart == null ||
              rideStreamStart?.isPaused == true ||
              rideStreamChanges == null ||
              rideStreamChanges?.isPaused == true) {
            streamRide();
          }
        }

        if (positionStream == null || positionStream!.isPaused) {
          positionStreamData();
        }

        final firebase = FirebaseDatabase.instance.ref();

        try {
          firebase.child('drivers/driver_${userDetails['id']}').update({
            'bearing': heading,
            'date': DateTime.now().toString(),
            'id': userDetails['id'],
            'g': geo.encode(double.parse(center.longitude.toString()),
                double.parse(center.latitude.toString())),
            'is_active': userDetails['active'] == true ? 1 : 0,
            'is_available': userDetails['available'],
            'l': {'0': center.latitude, '1': center.longitude},
            'mobile': userDetails['mobile'],
            'name': userDetails['name'],
            'updated_at': ServerValue.timestamp,
            'vehicle_number': userDetails['car_number'],
            'vehicle_type_name': userDetails['car_make_name'],
            'vehicle_type_icon': userDetails['vehicle_type_icon_for'],
            'vehicle_type': userDetails['vehicle_type_id'],
            'vehicle_types': userDetails['vehicle_types'],
            'ownerid': userDetails['owner_id'],
            'service_location_id': userDetails['service_location_id']
          });
          if (driverReq.isNotEmpty) {
            if (driverReq['accepted_at'] != null &&
                driverReq['is_completed'] == 0) {
              requestDetailsUpdate(
                  double.parse(heading.toString()),
                  double.parse(center.latitude.toString()),
                  double.parse(center.longitude.toString()));
            }
          }
          valueNotifierHome.incrementNotifier();
        } catch (e) {
          if (e is SocketException) {
            internet = false;
            valueNotifierHome.incrementNotifier();
          }
        }
      } else if (userDetails['active'] == false &&
          serviceEnabled == true &&
          permission != geolocs.LocationPermission.denied &&
          permission != geolocs.LocationPermission.deniedForever) {
        if (positionStream == null || positionStream!.isPaused) {
          positionStreamData();
        }
      } else if (serviceEnabled == false && userDetails['active'] == true) {
        await driverStatus();
        await geolocs.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocs.LocationAccuracy.low);
        // await location.requestService();
      }
      if (userDetails['role'] == 'driver') {
        var driverState = await FirebaseDatabase.instance
            .ref('drivers/driver_${userDetails['id']}')
            .get();
        if (driverState.child('approve').value == 0 &&
            userDetails['approve'] == true) {
          await getUserDetails();
          if (userDetails['active'] == true) {
            await driverStatus();
          }
          valueNotifierHome.incrementNotifier();
          // audioPlayer.play(audio);
        } else if (driverState.child('approve').value == 1 &&
            userDetails['approve'] == false) {
          await getUserDetails();
          valueNotifierHome.incrementNotifier();

          // audioPlayer.play(audio);
        }
        if (driverState.child('fleet_changed').value == 1) {
          FirebaseDatabase.instance
              .ref()
              .child('drivers/driver_${userDetails['id']}')
              .update({'fleet_changed': 0});
          await getUserDetails();
          valueNotifierHome.incrementNotifier();

          // audioPlayer.play(audio);
        }
        if (driverState.child('is_deleted').value == 1) {
          FirebaseDatabase.instance
              .ref()
              .child('drivers/driver_${userDetails['id']}')
              .remove();
          await getUserDetails();
          valueNotifierHome.incrementNotifier();
        }
        if (driverState.key!.contains('vehicle_type_icon')) {
          if (driverState.child('vehicle_type_icon') !=
              userDetails['vehicle_type_icon_for']) {
            FirebaseDatabase.instance
                .ref()
                .child('drivers/driver_${userDetails['id']}')
                .update({
              'vehicle_type_icon': userDetails['vehicle_type_icon_for']
            });
          }
        } else {
          FirebaseDatabase.instance
              .ref()
              .child('drivers/driver_${userDetails['id']}')
              .update(
                  {'vehicle_type_icon': userDetails['vehicle_type_icon_for']});
        }
      }
    } else if (userDetails['role'] == 'owner') {
      var ownerStatus = await FirebaseDatabase.instance
          .ref('owners/${userDetails['id']}')
          .get();
      if (ownerStatus.child('approve').value == 0 &&
          userDetails['approve'] == true) {
        await getUserDetails();
        valueNotifierHome.incrementNotifier();

        // audioPlayer.play(audio);
      } else if (ownerStatus.child('approve').value == 1 &&
          userDetails['approve'] == false) {
        await getUserDetails();
        valueNotifierHome.incrementNotifier();

        // audioPlayer.play(audio);
      }
    }
  });
}

//add request details in firebase realtime database

List latlngArray = [];
dynamic lastLat;
dynamic lastLong;
dynamic totalDistance;

requestDetailsUpdate(
  double bearing,
  double lat,
  double lng,
) async {
  final firebase = FirebaseDatabase.instance.ref();
  if (driverReq['is_trip_start'] == 1 && driverReq['is_completed'] == 0) {
    if (totalDistance == null) {
      var dist = await FirebaseDatabase.instance
          .ref('requests/${driverReq['id']}')
          .get();
      var array = await FirebaseDatabase.instance
          .ref('requests/${driverReq['id']}')
          .get();
      if (dist.child('distance').value != null) {
        totalDistance = dist.child('distance').value;
      }
      if (array.child('lat_lng_array').value != null) {
        latlngArray =
            jsonDecode(jsonEncode(array.child('lat_lng_array').value));
        lastLat = latlngArray[latlngArray.length - 1]['lat'];
        lastLong = latlngArray[latlngArray.length - 1]['lng'];
      }
    }
    if (latlngArray.isEmpty) {
      latlngArray.add({'lat': lat, 'lng': lng});
      lastLat = lat;
      lastLong = lng;
    } else {
      var distance = await calculateDistance(lastLat, lastLong, lat, lng);
      if (distance >= 150.0) {
        latlngArray.add({'lat': lat, 'lng': lng});
        lastLat = lat;
        lastLong = lng;

        if (totalDistance == null) {
          totalDistance = distance / 1000;
        } else {
          totalDistance = ((totalDistance * 1000) + distance) / 1000;
        }
      }
    }
  }

  try {
    firebase.child('requests/${driverReq['id']}').update({
      'bearing': bearing,
      'distance': (totalDistance == null) ? 0.0 : totalDistance,
      'driver_id': userDetails['id'],
      'user_id': driverReq['userDetail']['data']['id'],
      'is_cancelled': (driverReq['is_cancelled'] == 0) ? false : true,
      'is_completed': (driverReq['is_completed'] == 0) ? false : true,
      'lat': lat,
      'lng': lng,
      'lat_lng_array': latlngArray,
      'request_id': driverReq['id'],
      'trip_arrived': (driverReq['is_driver_arrived'] == 0) ? "0" : "1",
      'trip_start': (driverReq['is_trip_start'] == 0) ? "0" : "1",
    });
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
}

//calculate distance

calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  var val = (12742 * asin(sqrt(a))) * 1000;
  return val;
}

userInactive() {
  final firebase = FirebaseDatabase.instance.ref();
  firebase.child('drivers/driver_${userDetails['id']}').update({
    'is_active': 0,
  });
}

userActive() {
  final firebase = FirebaseDatabase.instance.ref();
  firebase.child('drivers/driver_${userDetails['id']}').update({
    'is_active': 1,
    'l': {'0': center.latitude, '1': center.longitude},
    'updated_at': ServerValue.timestamp,
    'is_available': userDetails['available'],
  });
}

calculateIdleDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  var val = (12742 * asin(sqrt(a))) * 1000;
  return val;
}

class AddressList {
  String address;
  LatLng latlng;
  String id;

  AddressList({required this.id, required this.address, required this.latlng});
}

Map etaDetails = {};

//eta request

etaRequest() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/eta'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'drop_lat':
              addressList.firstWhere((e) => e.id == 'drop').latlng.latitude,
          'drop_lng':
              addressList.firstWhere((e) => e.id == 'drop').latlng.longitude,
          'ride_type': 1
        }));

    if (response.statusCode == 200) {
      etaDetails = jsonDecode(response.body)['data'];
      result = true;
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] ==
          "service not available with this location") {
        serviceNotAvailable = true;
      }
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//geocodeing location

geoCodingForLatLng(placeid) async {
  dynamic location;
  try {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeid&key=$mapkey'));

    if (response.statusCode == 200) {
      var val = jsonDecode(response.body)['result']['geometry']['location'];
      location = LatLng(val['lat'], val['lng']);
    } else {
      debugPrint(response.body);
    }
    return location;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//create instant ride

//create request

createRequest(name, phone) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/request/create-instant-ride'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'drop_lat':
              addressList.firstWhere((e) => e.id == 'drop').latlng.latitude,
          'drop_lng':
              addressList.firstWhere((e) => e.id == 'drop').latlng.longitude,
          'ride_type': 1,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'drop_address': addressList.firstWhere((e) => e.id == 'drop').address,
          'name': name,
          'mobile': phone
        }));
    if (response.statusCode == 200) {
      // print(response.body);
      await getUserDetails();
      result = 'success';
      // valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);

      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//get auto fill address

List storedAutoAddress = [];
List addAutoFill = [];

getAutoAddress(input, sessionToken, lat, lng) async {
  dynamic response;
  var countryCode = userDetails['country_code'];
  try {
    if (userDetails['enable_country_restrict_on_map'] == '1' &&
        userDetails['country_code'] != null) {
      response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&library=places&location=$lat%2C$lng&radius=2000&components=country:$countryCode&key=$mapkey&sessiontoken=$sessionToken'));
    } else {
      response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&library=places&key=$mapkey&sessiontoken=$sessionToken'));
    }
    if (response.statusCode == 200) {
      addAutoFill = jsonDecode(response.body)['predictions'];
      // ignore: avoid_function_literals_in_foreach_calls
      addAutoFill.forEach((element) {
        if (storedAutoAddress
            .where((e) =>
                e['description'].toString().toLowerCase() ==
                element['description'].toString().toLowerCase())
            .isEmpty) {
          storedAutoAddress.add(element);
        }
      });
      pref.setString('autoAddress', jsonEncode(storedAutoAddress).toString());
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//driver request accept

requestAccept() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/respond'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id'], 'is_accept': 1}));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['message'] == 'success') {
        audioPlayers.stop();
        // audioPlayers.dispose();
        dropDistance = '';

        await getUserDetails();

        if (driverReq.isNotEmpty) {
          FirebaseDatabase.instance
              .ref()
              .child('drivers/driver_${userDetails['id']}')
              .update({'is_available': false});
          duration = 0;
          requestStreamStart?.cancel();
          requestStreamStart = null;
          requestStreamEnd?.cancel();
          requestStreamEnd = null;
          if (rideStreamStart == null ||
              rideStreamStart?.isPaused == true ||
              rideStreamChanges == null ||
              rideStreamChanges?.isPaused == true) {
            streamRide();
          }
          requestDetailsUpdate(double.parse(heading.toString()),
              center.latitude, center.longitude);
        }
        valueNotifierHome.incrementNotifier();
        FirebaseDatabase.instance
            .ref('request-meta/${driverReq['id']}')
            .remove();
      }
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//driver request reject

bool driverReject = false;

requestReject() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/respond'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id'], 'is_accept': 0}));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['message'] == 'success') {
        if (audioPlayers.state != PlayerState.stopped &&
            audioPlayers.state != PlayerState.completed &&
            audioPlayers.state != PlayerState.paused &&
            audioPlayers.playerId.isNotEmpty) {
          audioPlayers.stop();
          // audioPlayers.dispose();
        }
        driverReject = true;
        await getUserDetails();
        duration = 0;
        userActive();
        valueNotifierHome.incrementNotifier();
      }
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

audioPlay() async {
  audioPlayers.play(AssetSource('audio/request_sound.mp3'));
}

//sound

sound() async {
  audioPlay();

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (duration > 0.0 &&
        driverReq['accepted_at'] == null &&
        driverReq.isNotEmpty) {
      duration--;

      if (audioPlayers.state == PlayerState.completed) {
        audioPlay();
      }
      valueNotifierHome.incrementNotifier();
    } else if (driverReq.isNotEmpty &&
        driverReq['accepted_at'] == null &&
        duration <= 0.0) {
      timer.cancel();
      if (audioPlayers.state != PlayerState.stopped &&
          audioPlayers.state != PlayerState.completed &&
          audioPlayers.state != PlayerState.paused &&
          audioPlayers.playerId.isNotEmpty) {
        audioPlayers.stop();
        // audioPlayers.dispose();
      }
      Future.delayed(const Duration(seconds: 2), () {
        requestReject();
      });
      duration = 0;
    } else {
      if (audioPlayers.state != PlayerState.stopped &&
          audioPlayers.state != PlayerState.completed &&
          audioPlayers.state != PlayerState.paused &&
          audioPlayers.playerId.isNotEmpty) {
        audioPlayers.stop();
        // audioPlayers.dispose();
      }
      timer.cancel();
      duration = 0;
    }
  });
}

//driver arrived

driverArrived() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/arrived'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id']}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['message'] == 'driver_arrived') {
        waitingBeforeTime = 0;
        waitingTime = 0;
        await getUserDetails();
        FirebaseDatabase.instance
            .ref('requests')
            .child(driverReq['id'])
            .update({'trip_arrived': '1'});
        valueNotifierHome.incrementNotifier();
      }
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//opening google map

openMap(lat, lng) async {
  try {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    // ignore: deprecated_member_use
    if (await canLaunch(googleUrl)) {
      // ignore: deprecated_member_use
      await launch(googleUrl);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//trip start with otp

tripStart() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/started'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'pick_lat': driverReq['pick_lat'],
          'pick_lng': driverReq['pick_lng'],
          'ride_otp': driverOtp
        }));
    if (response.statusCode == 200) {
      result = 'success';
      await getUserDetails();
      FirebaseDatabase.instance
          .ref('requests')
          .child(driverReq['id'])
          .update({'trip_start': '1'});
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//trip start without otp

tripStartDispatcher() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/started'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'pick_lat': driverReq['pick_lat'],
          'pick_lng': driverReq['pick_lng']
        }));
    if (response.statusCode == 200) {
      result = 'success';
      await getUserDetails();
      FirebaseDatabase.instance
          .ref('requests')
          .child(driverReq['id'])
          .update({'trip_start': '1'});
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

geoCoding(double lat, double lng) async {
  dynamic result;
  try {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapkey'));

    if (response.statusCode == 200) {
      var val = jsonDecode(response.body);
      result = val['results'][0]['formatted_address'];
    } else {
      debugPrint(response.body);
      result = '';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//ending trip

endTrip() async {
  dynamic result;
  try {
    await requestDetailsUpdate(
        double.parse(heading.toString()), center.latitude, center.longitude);
    var dropAddress = await geoCoding(center.latitude, center.longitude);
    var db = await FirebaseDatabase.instance
        .ref('requests/${driverReq['id']}')
        .get();

    double dist = double.parse(
        double.parse(db.child('distance').value.toString()).toStringAsFixed(2));
    var reqId = driverReq['id'];

    final firebase = FirebaseDatabase.instance.ref();
    firebase.child('requests/${driverReq['id']}').update({
      'bearing': heading,
      'is_cancelled': (driverReq['is_cancelled'] == 0) ? false : true,
      'is_completed': false,
      'lat': center.latitude,
      'lng': center.longitude,
      'lat_lng_array': latlngArray,
      'request_id': driverReq['id'],
      'trip_arrived': "1",
      'trip_start': "1",
    });

    var response = await http.post(Uri.parse('${url}api/v1/request/end'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'distance': dist,
          'before_arrival_waiting_time': 0,
          'after_arrival_waiting_time': 0,
          'drop_lat': center.latitude,
          'drop_lng': center.longitude,
          'drop_address': dropAddress,
          'before_trip_start_waiting_time': (waitingBeforeTime != null &&
                  waitingBeforeTime > 60 &&
                  driverReq['is_rental'] != true)
              ? (waitingBeforeTime / 60).toInt()
              : 0,
          'after_trip_start_waiting_time': (waitingAfterTime != null &&
                  waitingAfterTime > 60 &&
                  driverReq['is_rental'] != true)
              ? (waitingAfterTime / 60).toInt()
              : 0
        }));
    if (response.statusCode == 200) {
      await getUserDetails();
      FirebaseDatabase.instance
          .ref('requests')
          .child(reqId)
          .update({'is_completed': true});
      totalDistance = null;
      lastLat = null;
      lastLong = null;
      waitingTime = null;
      waitingBeforeTime = null;
      waitingAfterTime = null;
      latlngArray.clear();
      polyList.clear();
      chatList.clear();
      driverOtp = '';
      waitingAfterTime = null;
      waitingBeforeTime = null;
      waitingTime = null;
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return result;
}

dynamic heading = 0.0;

//get polylines

List<LatLng> polyList = [];
String dropDistance = '';
String steps = '';

getPolylines() async {
  polyList.clear();
  String pickLat;
  String pickLng;
  String dropLat;
  String dropLng;
  if (tripStops.isEmpty) {
    pickLat = driverReq['pick_lat'].toString();
    pickLng = driverReq['pick_lng'].toString();
    dropLat = driverReq['drop_lat'].toString();
    dropLng = driverReq['drop_lng'].toString();

    try {
      var response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey'));
      if (response.statusCode == 200) {
        var steps = jsonDecode(response.body)['routes'][0]['overview_polyline']
            ['points'];

        decodeEncodedPolyline(steps);
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
      }
    }
  } else {
    for (var i = 0; i < tripStops.length; i++) {
      if (i == 0) {
        pickLat = driverReq['pick_lat'].toString();
        pickLng = driverReq['pick_lng'].toString();

        dropLat = tripStops[i]['latitude'].toString();
        dropLng = tripStops[i]['longitude'].toString();
      } else {
        pickLat = tripStops[i - 1]['latitude'].toString();
        pickLng = tripStops[i - 1]['longitude'].toString();
        dropLat = tripStops[i]['latitude'].toString();
        dropLng = tripStops[i]['longitude'].toString();
      }
      try {
        var response = await http.get(Uri.parse(
            'https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey'));
        if (response.statusCode == 200) {
          var steps = jsonDecode(response.body)['routes'][0]
              ['overview_polyline']['points'];

          decodeEncodedPolyline(steps);
        } else {
          debugPrint(response.body);
        }
      } catch (e) {
        if (e is SocketException) {
          internet = false;
        }
      }
    }
  }

  return polyList;
}

getPolylineshistory({pickLat, pickLng, dropLat, dropLng}) async {
  polyList.clear();

  try {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey'));
    if (response.statusCode == 200) {
      var steps =
          jsonDecode(response.body)['routes'][0]['overview_polyline']['points'];
      decodeEncodedPolylineHistory(steps);
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return polyList;
}

//polyline decode

Set<Polyline> polylineHistory = {};

List<PointLatLng> decodeEncodedPolylineHistory(String encoded) {
  polylineHistory.clear();
  List<PointLatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    polyList.add(p);
  }
  polylineHistory.add(Polyline(
    polylineId: const PolylineId('1'),
    visible: true,
    color: const Color(0xffFD9898),
    width: 4,
    points: polyList,
  ));
  valueNotifierHome.incrementNotifier();
  return poly;
}

Set<Polyline> polyline = {};

List<PointLatLng> decodeEncodedPolyline(String encoded) {
  polyline.clear();
  List<PointLatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    polyList.add(p);
  }
  polyline.add(Polyline(
    polylineId: const PolylineId('1'),
    visible: true,
    color: const Color(0xffFD9898),
    width: 4,
    points: polyList,
  ));
  valueNotifierHome.incrementNotifier();
  return poly;
}

/// Note instead of using the class,
/// you can use Google LatLng() by importing it from their library.
class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
      // ignore: unnecessary_null_comparison
      : assert(latitude != null),
        // ignore: unnecessary_null_comparison
        assert(longitude != null),

        // ignore: unnecessary_this, prefer_initializing_formals
        this.latitude = latitude,
        // ignore: unnecessary_this, prefer_initializing_formals
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}

//add user rating

userRating() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/rating'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'rating': review,
          'comment': feedback
        }));
    if (response.statusCode == 200) {
      FirebaseDatabase.instance
          .ref()
          .child('drivers/driver_${userDetails['id']}')
          .update({'is_available': true});
      await getUserDetails();
      result = true;
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//making call to user

makingPhoneCall(phnumber) async {
  var mobileCall = 'tel:$phnumber';
  // ignore: deprecated_member_use
  if (await canLaunch(mobileCall)) {
    // ignore: deprecated_member_use
    await launch(mobileCall);
  } else {
    throw 'Could not launch $mobileCall';
  }
}

//request cancel by driver

cancelRequestDriver(reason) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/request/cancel/by-driver'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'request_id': driverReq['id'], 'custom_reason': reason}));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        await FirebaseDatabase.instance
            .ref()
            .child('requests/${driverReq['id']}')
            .update({'cancelled_by_driver': true});
        result = true;
        await getUserDetails();
        userActive();
        valueNotifierHome.incrementNotifier();
      } else {
        result = false;
      }
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//sos data
List sosData = [];

getSosData(lat, lng) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/common/sos/list/$lat/$lng'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      sosData = jsonDecode(response.body)['data'];
      valueNotifierHome.incrementNotifier();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return result;
}

//get current ride messages

List chatList = [];

getCurrentMessages() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/request/chat-history/${driverReq['id']}'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        if (chatList.where((element) => element['from_type'] == 1).length !=
            jsonDecode(response.body)['data']
                .where((element) => element['from_type'] == 1)
                .length) {
          // audioPlayer.play(audio);
        }
        chatList = jsonDecode(response.body)['data'];
        valueNotifierHome.incrementNotifier();
      }
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return result;
}

//send chat

sendMessage(chat) async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/send'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id'], 'message': chat}));
    if (response.statusCode == 200) {
      getCurrentMessages();
      FirebaseDatabase.instance
          .ref('requests/${driverReq['id']}')
          .update({'message_by_driver': chatList.length});
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return result;
}

//message seen

messageSeen() async {
  var response = await http.post(Uri.parse('${url}api/v1/request/seen'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'request_id': driverReq['id']}));
  if (response.statusCode == 200) {
    getCurrentMessages();
  } else {
    debugPrint(response.body);
  }
}

//cancellation reason
List cancelReasonsList = [];
cancelReason(reason) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/common/cancallation/reasons?arrived=$reason'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      cancelReasonsList = jsonDecode(response.body)['data'];
      result = true;
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//open url in browser

openBrowser(browseUrl) async {
  // ignore: deprecated_member_use
  if (await canLaunch(browseUrl)) {
    // ignore: deprecated_member_use
    await launch(browseUrl);
  } else {
    throw 'Could not launch $browseUrl';
  }
}

//manage vehicle

List vehicledata = [];

getVehicleInfo() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/owner/list-fleets'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      result = 'success';
      vehicledata = jsonDecode(response.body)['data'];
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(vehicledata.toString());
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

deletefleetdriver(driverid) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/owner/delete-driver/$driverid'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      FirebaseDatabase.instance
          .ref()
          .child('drivers/driver_$driverid')
          .update({'is_deleted': 1});
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(vehicledata.toString());
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//update driver vehicle

updateVehicle() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/user/driver-profile'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "service_location_id": myServiceId,
              "is_company_driver": false,
              "vehicle_type": myVehicleId,
              "vehicle_types": jsonEncode(vehicletypelist),
              "car_make": vehicleMakeId,
              "car_model": vehicleModelId,
              "car_color": vehicleColor,
              "car_number": vehicleNumber,
              "vehicle_year": modelYear
            }));

    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//edit user profile

updateProfile(name, email) async {
  dynamic result;
  try {
    var response = http.MultipartRequest(
      'POST',
      Uri.parse('${url}api/v1/user/driver-profile'),
    );
    response.headers
        .addAll({'Authorization': 'Bearer ${bearerToken[0].token}'});
    response.files.add(
        await http.MultipartFile.fromPath('profile_picture', proImageFile));
    response.fields['email'] = email;
    response.fields['name'] = name;
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      result = 'success';
      if (val['success'] == true) {
        await getUserDetails();
      }
    } else if (request.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else if (request.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(val);
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
    }
  }
  return result;
}

updateProfileWithoutImage(name, email) async {
  dynamic result;
  try {
    var response = http.MultipartRequest(
      'POST',
      Uri.parse('${url}api/v1/user/driver-profile'),
    );
    response.headers
        .addAll({'Authorization': 'Bearer ${bearerToken[0].token}'});
    response.fields['email'] = email;
    response.fields['name'] = name;
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      result = 'success';
      if (val['success'] == true) {
        await getUserDetails();
      }
    } else if (request.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else if (request.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(respon.body);
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
    }
  }
  return result;
}

//get faq
List faqData = [];
Map<String, dynamic> myFaqPage = {};

getFaqData(lat, lng) async {
  dynamic result;
  myFaqPage.clear();
  try {
    var response = await http
        .get(Uri.parse('${url}api/v1/common/faq/list/$lat/$lng'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      faqData = jsonDecode(response.body)['data'];
      myFaqPage = jsonDecode(response.body)['meta'];
      valueNotifierHome.incrementNotifier();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
    return result;
  }
}

getFaqPages(id) async {
  dynamic result;
  try {
    var response =
        await http.get(Uri.parse('${url}api/v1/common/faq/list/$id'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      var val = jsonDecode(response.body)['data'];
      val.forEach((element) {
        faqData.add(element);
      });
      myFaqPage = jsonDecode(response.body)['meta'];
      valueNotifierHome.incrementNotifier();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
    return result;
  }
}

//request history
List myHistory = [];
Map<String, dynamic> myHistoryPage = {};

getHistory(id) async {
  dynamic result;

  try {
    var response = await http.get(Uri.parse('${url}api/v1/request/history?$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      myHistory = jsonDecode(response.body)['data'];
      myHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

getHistoryPages(id) async {
  dynamic result;

  try {
    var response = await http.get(Uri.parse('${url}api/v1/request/history?$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body)['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        myHistory.add(element);
      });
      myHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//get wallet history

Map<String, dynamic> walletBalance = {};
List walletHistory = [];
Map<String, dynamic> walletPages = {};

getWalletHistory() async {
  walletBalance.clear();
  walletHistory.clear();
  walletPages.clear();
  dynamic result;
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/payment/wallet/history'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      walletBalance = jsonDecode(response.body);
      walletHistory = walletBalance['wallet_history']['data'];
      walletPages = walletBalance['wallet_history']['meta']['pagination'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

getWalletHistoryPage(page) async {
  dynamic result;
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/payment/wallet/history?page=$page'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      walletBalance = jsonDecode(response.body);
      List list = walletBalance['wallet_history']['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        walletHistory.add(element);
      });
      walletPages = walletBalance['wallet_history']['meta']['pagination'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//add sos

addSos(name, number) async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/common/sos/store'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'name': name, 'number': number}));

    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//remove sos

deleteSos(id) async {
  dynamic result;
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/common/sos/delete/$id'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//get user referral

Map<String, dynamic> myReferralCode = {};
getReferral() async {
  dynamic result;
  try {
    var response =
        await http.get(Uri.parse('${url}api/v1/get/referral'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      result = 'success';
      myReferralCode = jsonDecode(response.body)['data'];
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//stripe payment

Map<String, dynamic> stripeToken = {};

getStripePayment(money) async {
  dynamic results;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/payment/stripe/intent'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'amount': money}));
    if (response.statusCode == 200) {
      results = 'success';
      stripeToken = jsonDecode(response.body)['data'];
    } else if (response.statusCode == 401) {
      results = 'logout';
    } else {
      debugPrint(response.body);
      results = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      results = 'no internet';
      internet = false;
    }
  }
  return results;
}

//stripe add money

addMoneyStripe(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/stripe/add/money'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//paystack payment
Map<String, dynamic> paystackCode = {};

getPaystackPayment(money) async {
  dynamic results;
  paystackCode.clear();
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/payment/paystack/initialize'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'amount': money}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['status'] == false) {
        results = jsonDecode(response.body)['message'];
      } else {
        results = 'success';
        paystackCode = jsonDecode(response.body)['data'];
      }
    } else if (response.statusCode == 401) {
      results = 'logout';
    } else {
      debugPrint(response.body);
      results = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      results = 'no internet';
      internet = false;
    }
  }
  return results;
}

addMoneyPaystack(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/paystack/add-money'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      paystackCode.clear();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//flutterwave

addMoneyFlutterwave(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/flutter-wave/add-money'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//razorpay

//razorpay

razorpayCreateOrder(amount, publishkey, secretkey) async {
  dynamic result;
  String basicAuth =
      'Basic ${base64Encode(utf8.encode('$publishkey:$secretkey'))}';
  try {
    var response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'amount': amount,
          "currency": "INR",
          "receipt": userDetails['role'] == 'owner'
              ? 'user_${userDetails['user_id'].toString()}_${DateTime.now().toString()}'
              : 'user_${userDetails['id'].toString()}_${DateTime.now().toString()}'
        }));
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    } else {
      result = 'failure';
    }
  }
  return result;
}

addMoneyRazorpay(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/razerpay/add-money'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//cashfree

Map<String, dynamic> cftToken = {};

getCfToken(money, currency) async {
  cftToken.clear();
  cfSuccessList.clear();
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/cashfree/generate-cftoken'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'order_amount': money, 'order_currency': currency}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['status'] == 'OK') {
        cftToken = jsonDecode(response.body);
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failure';
      }
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

Map<String, dynamic> cfSuccessList = {};

cashFreePaymentSuccess() async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/cashfree/add-money-to-wallet-webhooks'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'orderId': cfSuccessList['orderId'],
          'orderAmount': cfSuccessList['orderAmount'],
          'referenceId': cfSuccessList['referenceId'],
          'txStatus': cfSuccessList['txStatus'],
          'paymentMode': cfSuccessList['paymentMode'],
          'txMsg': cfSuccessList['txMsg'],
          'txTime': cfSuccessList['txTime'],
          'signature': cfSuccessList['signature']
        }));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
        await getWalletHistory();
        await getUserDetails();
      } else {
        debugPrint(response.body);
        result = 'failure';
      }
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//user logout

userLogout() async {
  dynamic result;
  var id = userDetails['id'];
  var role = userDetails['role'];
  try {
    var response = await http.post(Uri.parse('${url}api/v1/logout'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      if (platform == TargetPlatform.android) {
        platforms.invokeMethod('logout');
      }
      // print(id);
      if (role != 'owner') {
        final position = FirebaseDatabase.instance.ref();
        position.child('drivers/driver_$id').update({
          'is_active': 0,
        });
      }
      rideStreamStart?.cancel();
      rideStreamChanges?.cancel();
      requestStreamEnd?.cancel();
      requestStreamStart?.cancel();
      rideStreamStart = null;
      rideStreamChanges = null;
      requestStreamStart = null;
      requestStreamEnd = null;
      pref.remove('Bearer');
      result = 'success';
    } else if (response.statusCode == 401) {
      pref.remove('Bearer');
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//check internet connection

checkInternetConnection() async {
  Connectivity().onConnectivityChanged.listen((connectionState) {
    if (connectionState == ConnectivityResult.none) {
      internet = false;
      valueNotifierHome.incrementNotifier();
      valueNotifierHome.incrementNotifier();
    } else {
      internet = true;

      valueNotifierHome.incrementNotifier();
      valueNotifierHome.incrementNotifier();
    }
  });
}

//internet true
internetTrue() {
  internet = true;
  valueNotifierHome.incrementNotifier();
}

//driver earnings

Map<String, dynamic> driverTodayEarnings = {};
Map<String, dynamic> driverWeeklyEarnings = {};
Map<String, dynamic> weekDays = {};
Map<String, dynamic> driverReportEarnings = {};

driverTodayEarning() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/driver/today-earnings'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      result = 'success';
      driverTodayEarnings = jsonDecode(response.body)['data'];
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

driverWeeklyEarning() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/driver/weekly-earnings'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      result = 'success';
      driverWeeklyEarnings = jsonDecode(response.body)['data'];
      weekDays = jsonDecode(response.body)['data']['week_days'];
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

driverEarningReport(fromdate, todate) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/driver/earnings-report/$fromdate/$todate'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      driverReportEarnings = jsonDecode(response.body)['data'];
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//withdraw request

requestWithdraw(amount) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/wallet/request-for-withdrawal'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'requested_amount': amount}));
    if (response.statusCode == 200) {
      await getWithdrawList();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//withdraw list

Map<String, dynamic> withDrawList = {};
List withDrawHistory = [];
Map<String, dynamic> withDrawHistoryPages = {};

getWithdrawList() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/payment/wallet/withdrawal-requests'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      withDrawList = jsonDecode(response.body);
      withDrawHistory = jsonDecode(response.body)['withdrawal_history']['data'];
      withDrawHistoryPages =
          jsonDecode(response.body)['withdrawal_history']['meta']['pagination'];
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

getWithdrawListPages(page) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/payment/wallet/withdrawal-requests?page=$page'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      withDrawList = jsonDecode(response.body);
      List val = jsonDecode(response.body)['withdrawal_history']['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      val.forEach((element) {
        withDrawHistory.add(element);
      });
      withDrawHistoryPages =
          jsonDecode(response.body)['withdrawal_history']['meta']['pagination'];
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//get bank info
Map<String, dynamic> bankData = {};

getBankInfo() async {
  bankData.clear();
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/user/get-bank-info'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      result = 'success';
      bankData = jsonDecode(response.body)['data'];
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

addBankData(accName, accNo, bankCode, bankName) async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/user/update-bank-info'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'account_name': accName,
              'account_no': accNo,
              'bank_code': bankCode,
              'bank_name': bankName
            }));

    if (response.statusCode == 200) {
      await getBankInfo();
      result = 'success';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//sos admin notification

notifyAdmin() async {
  var db = FirebaseDatabase.instance.ref();
  dynamic result;
  try {
    await db.child('SOS/${driverReq['id']}').update({
      "is_driver": "1",
      "is_user": "0",
      "req_id": driverReq['id'],
      "serv_loc_id": driverReq['service_location_id'],
      "updated_at": ServerValue.timestamp
    });
    result = true;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = false;
    }
  }
  return result;
}

//make complaint

List generalComplaintList = [];
getGeneralComplaint(type) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/common/complaint-titles?complaint_type=$type'),
      headers: {'Authorization': 'Bearer ${bearerToken[0].token}'},
    );
    if (response.statusCode == 200) {
      generalComplaintList = jsonDecode(response.body)['data'];
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

makeGeneralComplaint() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/common/make-complaint'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'complaint_title_id': generalComplaintList[complaintType]['id'],
              'description': complaintDesc,
            }));
    if (response.statusCode == 200) {
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

makeRequestComplaint() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/common/make-complaint'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'complaint_title_id': generalComplaintList[complaintType]['id'],
              'description': complaintDesc,
              'request_id': myHistory[selectedHistory]['id']
            }));
    if (response.statusCode == 200) {
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//waiting time

//waiting before start
dynamic waitingTime;
dynamic waitingBeforeTime;
dynamic waitingAfterTime;
dynamic arrivedTimer;
dynamic rideTimer;
waitingBeforeStart() async {
  var bWaitingTimes = await FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      // .child('waiting_time_before_start')
      .get();
  var waitingTimes = await FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      // .child('total_waiting_time')
      .get();
  if (bWaitingTimes.child('waiting_time_before_start').value != null) {
    waitingBeforeTime = bWaitingTimes.child('waiting_time_before_start').value;
  } else {
    waitingBeforeTime = 0;
  }
  if (waitingTimes.child('total_waiting_time').value != null) {
    waitingTime = waitingTimes.child('total_waiting_time').value;
  } else {
    waitingTime = 0;
  }
  await Future.delayed(const Duration(seconds: 10), () {});

  arrivedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (driverReq['is_driver_arrived'] == 1 &&
        driverReq['is_trip_start'] == 0) {
      waitingBeforeTime++;
      waitingTime++;
      if (waitingTime % 60 == 0) {
        FirebaseDatabase.instance
            .ref()
            .child('requests/${driverReq['id']}')
            .update({
          'waiting_time_before_start': waitingBeforeTime,
          'total_waiting_time': waitingTime
        });
      }
      valueNotifierHome.incrementNotifier();
    } else {
      timer.cancel();
      arrivedTimer = null;
    }
  });
}

dynamic currentRidePosition;

dynamic startTimer;

waitingAfterStart() async {
  var bWaitingTimes = await FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      // .child('waiting_time_before_start')
      .get();
  var waitingTimes = await FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      // .child('total_waiting_time')
      .get();
  var aWaitingTimes = await FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      // .child('waiting_time_after_start')
      .get();
  if (bWaitingTimes.child('waiting_time_before_start').value != null &&
      waitingBeforeTime == null) {
    waitingBeforeTime = bWaitingTimes.child('waiting_time_before_start').value;
  }
  if (waitingTimes.child('total_waiting_time').value != null) {
    waitingTime = waitingTimes.child('total_waiting_time').value;
    // ignore: prefer_conditional_assignment
  } else if (waitingTime == null) {
    waitingTime = 0;
  }
  if (aWaitingTimes.child('waiting_time_after_start').value != null) {
    waitingAfterTime = aWaitingTimes.child('waiting_time_after_start').value;
  } else {
    waitingAfterTime = 0;
  }
  await Future.delayed(const Duration(seconds: 10), () {});
  rideTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
    if (currentRidePosition == null &&
        driverReq['is_completed'] == 0 &&
        driverReq['is_trip_start'] == 1) {
      currentRidePosition = center;
    } else if (currentRidePosition != null &&
        driverReq['is_completed'] == 0 &&
        driverReq['is_trip_start'] == 1) {
      var dist = await calculateIdleDistance(currentRidePosition.latitude,
          currentRidePosition.longitude, center.latitude, center.longitude);
      if (dist < 150) {
        waitingAfterTime = waitingAfterTime + 60;
        waitingTime = waitingTime + 60;
        if (waitingTime % 60 == 0) {
          FirebaseDatabase.instance
              .ref()
              .child('requests/${driverReq['id']}')
              .update({
            'waiting_time_after_start': waitingAfterTime,
            'total_waiting_time': waitingTime
          });
        }
        valueNotifierHome.incrementNotifier();
      } else {
        currentRidePosition = center;
      }
    } else {
      timer.cancel();
      rideTimer = null;
    }
  });
}

//requestStream
StreamSubscription<DatabaseEvent>? requestStreamStart;
StreamSubscription<DatabaseEvent>? requestStreamEnd;
StreamSubscription<DatabaseEvent>? rideStreamStart;
StreamSubscription<DatabaseEvent>? rideStreamChanges;

streamRequest() {
  rideStreamStart?.cancel();
  rideStreamChanges?.cancel();
  requestStreamEnd?.cancel();
  requestStreamStart?.cancel();
  rideStreamStart = null;
  rideStreamChanges = null;
  requestStreamStart = null;
  requestStreamEnd = null;
  requestStreamStart = FirebaseDatabase.instance
      .ref('request-meta')
      .orderByChild('driver_id')
      .equalTo(userDetails['id'])
      .onChildAdded
      .handleError((onError) {
    requestStreamStart?.cancel();
  }).listen((event) {
    if (driverReq.isEmpty) {
      streamEnd(event.snapshot.key.toString());
      getUserDetails();
    }
  });
}

streamEnd(id) {
  requestStreamEnd = FirebaseDatabase.instance
      .ref('request-meta')
      .child(id)
      .onChildRemoved
      .handleError((onError) {
    requestStreamEnd?.cancel();
  }).listen((event) {
    if (driverReq['accepted_at'] == null) {
      // userReject = true;
      driverReq.clear();
      getUserDetails();
    }
  });
}

streamRide() {
  requestStreamEnd?.cancel();
  requestStreamStart?.cancel();
  rideStreamStart?.cancel();
  rideStreamChanges?.cancel();
  requestStreamStart = null;
  requestStreamEnd = null;
  rideStreamStart = null;
  rideStreamChanges = null;
  rideStreamChanges = FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      .onChildChanged
      .handleError((onError) {
    rideStreamChanges?.cancel();
  }).listen((DatabaseEvent event) {
    if (event.snapshot.key.toString() == 'cancelled_by_user') {
      getUserDetails();
      if (driverReq.isEmpty) {
        userReject = true;
      }
    } else if (event.snapshot.key.toString() == 'message_by_user') {
      getCurrentMessages();
    } else if (event.snapshot.key.toString() == 'is_paid' ||
        event.snapshot.key.toString() == 'modified_by_user') {
      getUserDetails();
    }
  });
  rideStreamStart = FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      .onChildAdded
      .handleError((onError) {
    rideStreamChanges?.cancel();
  }).listen((DatabaseEvent event) async {
    if (event.snapshot.key.toString() == 'cancelled_by_user') {
      getUserDetails();

      userReject = true;
    } else if (event.snapshot.key.toString() == 'message_by_user') {
      getCurrentMessages();
    } else if (event.snapshot.key.toString() == 'is_paid' ||
        event.snapshot.key.toString() == 'modified_by_user') {
      getUserDetails();
    }
  });
}

//location stream
bool positionStreamStarted = false;
StreamSubscription<geolocs.Position>? positionStream;

geolocs.LocationSettings locationSettings = (platform == TargetPlatform.android)
    ? geolocs.AndroidSettings(
        accuracy: geolocs.LocationAccuracy.high,
        distanceFilter: 50,
        foregroundNotificationConfig:
            const geolocs.ForegroundNotificationConfig(
          notificationText:
              "marhaba will continue to receive your location in background",
          notificationTitle: "Location background service running",
          enableWakeLock: true,
        ))
    : geolocs.AppleSettings(
        accuracy: geolocs.LocationAccuracy.high,
        activityType: geolocs.ActivityType.otherNavigation,
        distanceFilter: 50,
        showBackgroundLocationIndicator: true,
      );

dynamic testDistance = 0;
// Location location = Location();

positionStreamData() {
  positionStream =
      geolocs.Geolocator.getPositionStream(locationSettings: locationSettings)
          .handleError((error) {
    positionStream = null;
    positionStream?.cancel();
  }).listen((geolocs.Position? position) {
    if (position != null) {
      center = LatLng(position.latitude, position.longitude);
    } else {
      positionStream!.cancel();
    }
  });
}

userDelete() async {
  dynamic result;
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/user/delete-user-account'), headers: {
      'Authorization': 'Bearer ${bearerToken[0].token}',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      pref.remove('Bearer');

      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

addHomeAddress(lat, lng, add) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/driver/add-my-route-address'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'my_route_lat': lat,
          'my_route_lng': lng,
          'my_route_address': add
        }));
    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

enableMyRouteBookings(lat, lng) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/driver/enable-my-route-booking'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'is_enable': (userDetails['enable_my_route_booking'] == 1) ? 0 : 1,
          'current_lat': lat,
          'current_lng': lng
        }));
    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

var ccUrl = '';
getCcavenuePayment(body) async {
  dynamic results;
  ccUrl = '';
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/payment/ccavenue/initialize'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      ccUrl =
          'https://secure.ccavenue.com/transaction.do?command=initiateTransaction&encRequest=${data['enc_val']}&access_code=${data['access_code']}';

      results = 'success';
    } else if (response.statusCode == 401) {
      results = 'logout';
    } else {
      debugPrint(response.body);
      results = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      results = 'no internet';
      internet = false;
    }
  }
  return results;
}

paymentReceived() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/request/payment-confirm'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'request_id': driverReq['id']}));
    if (response.statusCode == 200) {
      // printWrapped(response.body);
      // userCancelled = true;
      FirebaseDatabase.instance
          .ref('requests')
          .child(driverReq['id'])
          .update({'modified_by_driver': ServerValue.timestamp});
      await getUserDetails();
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return result;
}

String ownermodule = '1';
String isemailmodule = '1';
getOwnermodule() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse('${url}api/v1/common/modules'),
    );

    if (response.statusCode == 200) {
      ownermodule = jsonDecode(response.body)['enable_owner_login'];
      isemailmodule = jsonDecode(response.body)['enable_email_otp'];

      res = 'success';
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }
  return res;
}
