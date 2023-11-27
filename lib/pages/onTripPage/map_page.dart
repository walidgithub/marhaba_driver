import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/functions/geohash.dart';
import 'package:tagxidriver/functions/notifications.dart';
import 'package:tagxidriver/pages/NavigatorPages/notification.dart';
import 'package:tagxidriver/pages/chatPage/chat_page.dart';
import 'package:tagxidriver/pages/onTripPage/droplocation.dart';
import 'package:tagxidriver/pages/onTripPage/invoice.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/login.dart';
import 'package:tagxidriver/pages/navDrawer/nav_drawer.dart';
import 'package:tagxidriver/pages/noInternet/nointernet.dart';
import 'package:tagxidriver/pages/vehicleInformations/docs_onprocess.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:tagxidriver/translation/translation.dart';
import 'package:tagxidriver/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:vector_math/vector_math.dart' as vector;

import '../login/signupmethod.dart';

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  State<Maps> createState() => _MapsState();
}

dynamic _center = const LatLng(41.4219057, -102.0840772);
dynamic center;
bool locationAllowed = false;

List<Marker> myMarkers = [];
Set<Circle> circles = {};

dynamic _timer;
String cancelReasonText = '';
bool notifyCompleted = false;
bool logout = false;
bool deleteAccount = false;
bool getStartOtp = false;
String driverOtp = '';
bool serviceEnabled = false;
bool show = true;
int filtericon = 0;

class _MapsState extends State<Maps>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  List driverData = [];

  bool sosLoaded = false;
  bool cancelRequest = false;
  bool _pickAnimateDone = false;
  bool _dropMarkerDone = false;

  late geolocator.LocationPermission permission;
  // Location location = Location();
  String state = '';
  dynamic _controller;
  Animation<double>? _animation;
  dynamic animationController;
  String _cancellingError = '';
  double mapPadding = 0.0;

  String _cancelReason = '';
  bool _locationDenied = false;
  int gettingPerm = 0;
  bool _errorOtp = false;
  dynamic loc;
  String _otp1 = '';
  String _otp2 = '';
  String _otp3 = '';
  String _otp4 = '';
  bool showSos = false;
  bool _showWaitingInfo = false;
  bool _isLoading = false;
  bool _reqCancelled = false;
  dynamic pinLocationIcon;
  dynamic pinLocationIcon2;
  dynamic userLocationIcon;
  bool makeOnline = false;
  bool contactus = false;
  GlobalKey iconKey = GlobalKey();
  GlobalKey iconDropKey = GlobalKey();
  var iconDropKeys = {};
  int bottom = 0;
  bool _tripOpenMap = false;

  dynamic onrideicon;
  dynamic offlineicon;
  dynamic onlineicon;
  dynamic onridebikeicon;
  dynamic offlinebikeicon;
  dynamic onlinebikeicon;
  bool _isDarkTheme = false;
  bool currentpage = true;

  List gesture = [];
  dynamic start;

  final _mapMarkerSC = StreamController<List<Marker>>();
  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;
  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    myMarkers = [];
    addressList.clear();
    show = true;
    filtericon = 0;
    _isDarkTheme = isDarkTheme;
    currentpage = true;
    getLocs();
    getonlineoffline();
    // setState(() {
    // vehicletypelist = userDetails['vehicle_types'];

    // });
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _controller?.setMapStyle(mapStyle);
    });
    if (driverReq.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        addPickDropMarker();
      });
    }
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

  getonlineoffline() async {
    if (userDetails['role'] == 'driver' &&
        userDetails['owner_id'] != null &&
        userDetails['vehicle_type_id'] == null &&
        userDetails['active'] == true) {
      var val = await driverStatus();
      if (val == 'logout') {
        navigateLogout();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _controller!.setMapStyle(mapStyle);
        valueNotifierHome.incrementNotifier();
      }
      FirebaseMessaging.instance.getInitialMessage().then((value) {
        if (value?.data != null) {
          if (value?.data['push_type'] == 'general') {
            latestNotification = value?.data['message'];
            isGeneral = true;
            valueNotifierHome.incrementNotifier();
          }
        }
      });

      isBackground = false;
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      isBackground = true;
    }
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    _controller?.dispose();
    _controller = null;

    animationController?.dispose();

    super.dispose();
  }

  reqCancel() {
    _reqCancelled = true;

    Future.delayed(const Duration(seconds: 2), () {
      _reqCancelled = false;
      userReject = false;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  capturePng(GlobalKey iconKeys) async {
    dynamic bitmap;

    try {
      RenderRepaintBoundary boundary =
          iconKeys.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      bitmap = BitmapDescriptor.fromBytes(pngBytes);
      // return pngBytes;
    } catch (e) {
      debugPrint(e.toString());
    }
    return bitmap;
  }

  addDropMarker() async {
    if (tripStops.isNotEmpty) {
      for (var i = 0; i < tripStops.length; i++) {
        var testIcon = await capturePng(iconDropKeys[i]);
        // ignore: unnecessary_null_comparison
        if (testIcon != null) {
          myMarkers.add(Marker(
              markerId: MarkerId((i + 3).toString()),
              icon: testIcon,
              position:
                  LatLng(tripStops[i]['latitude'], tripStops[i]['longitude'])));
        }
      }
    } else {
      var testIcon = await capturePng(iconDropKey);
      // ignore: unnecessary_null_comparison
      if (testIcon != null) {
        myMarkers.add(Marker(
            markerId: const MarkerId('3'),
            icon: testIcon,
            position: LatLng(driverReq['drop_lat'], driverReq['drop_lng'])));
      }
    }
    // setState((){});
    LatLngBounds bound;
    if (driverReq['pick_lat'] > driverReq['drop_lat'] &&
        driverReq['pick_lng'] > driverReq['drop_lng']) {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['drop_lat'], driverReq['drop_lng']),
          northeast: LatLng(driverReq['pick_lat'], driverReq['pick_lng']));
    } else if (driverReq['pick_lng'] > driverReq['drop_lng']) {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['pick_lat'], driverReq['drop_lng']),
          northeast: LatLng(driverReq['drop_lat'], driverReq['pick_lng']));
    } else if (driverReq['pick_lat'] > driverReq['drop_lat']) {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['drop_lat'], driverReq['pick_lng']),
          northeast: LatLng(driverReq['pick_lat'], driverReq['drop_lng']));
    } else {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['pick_lat'], driverReq['pick_lng']),
          northeast: LatLng(driverReq['drop_lat'], driverReq['drop_lng']));
    }
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bound, 50);
    _controller?.animateCamera(cameraUpdate);
  }

  addPickDropMarker() async {
    addMarker();
    if (driverReq['drop_address'] != null) {
      // await getPolylines();
      addDropMarker();
    }
  }

  addMarker() async {
    if (driverReq.isNotEmpty) {
      var testIcon = await capturePng(iconKey);
      // ignore: unnecessary_null_comparison
      if (testIcon != null) {
        setState(() {
          myMarkers.add(Marker(
              markerId: const MarkerId('2'),
              icon: testIcon,
              position: LatLng(driverReq['pick_lat'], driverReq['pick_lng'])));
        });
      }
    }
    if (driverReq['drop_address'] != null) {
      addDropMarker();
      if (polyline.isEmpty) {
        getPolylines();
        // addToast();
        if (driverReq.isNotEmpty) {
          polyline.add(
            Polyline(
                polylineId: const PolylineId('1'),
                color: buttonColor,
                points: [
                  LatLng(double.parse(driverReq['pick_lat'].toString()),
                      double.parse(driverReq['pick_lng'].toString())),
                  LatLng(double.parse(driverReq['pick_lat'].toString()),
                      double.parse(driverReq['pick_lng'].toString()))
                ],
                geodesic: false,
                width: 5),
          );
        }
      }
    } else {
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(driverReq['pick_lat'], driverReq['pick_lng']), 11.0));
    }
  }

//getting permission and current location
  getLocs() async {
    permission = await geolocator.GeolocatorPlatform.instance.checkPermission();
    serviceEnabled =
        await geolocator.GeolocatorPlatform.instance.isLocationServiceEnabled();

    if (permission == geolocator.LocationPermission.denied ||
        permission == geolocator.LocationPermission.deniedForever ||
        serviceEnabled == false) {
      gettingPerm++;

      if (gettingPerm > 1) {
        locationAllowed = false;
        if (userDetails['active'] == true) {
          var val = await driverStatus();
          if (val == 'logout') {
            navigateLogout();
          }
        }
        state = '3';
      } else {
        state = '2';
      }
      setState(() {
        _isLoading = false;
      });
    } else if (permission == geolocator.LocationPermission.whileInUse ||
        permission == geolocator.LocationPermission.always) {
      if (serviceEnabled == true) {
        final Uint8List onrideicon1;
        final Uint8List offlineicon1;
        final Uint8List onlineicon1;
        final Uint8List onridebikeicon1;
        final Uint8List offlinebikeicon1;
        final Uint8List onlinebikeicon1;
        final Uint8List markerIcon =
            await getBytesFromAsset('assets/images/top-taxi.png', 40);
        final Uint8List markerIcon2 =
            await getBytesFromAsset('assets/images/bike.png', 40);
        if (userDetails['role'] == 'owner') {
          onrideicon1 =
              await getBytesFromAsset('assets/images/onboardicon.png', 40);
          offlineicon1 =
              await getBytesFromAsset('assets/images/offlineicon.png', 40);
          onlineicon1 =
              await getBytesFromAsset('assets/images/onlineicon.png', 40);
          onlinebikeicon1 =
              await getBytesFromAsset('assets/images/bike_online.png', 40);
          onridebikeicon1 =
              await getBytesFromAsset('assets/images/bike_onride.png', 40);
          offlinebikeicon1 =
              await getBytesFromAsset('assets/images/bike.png', 40);
          onrideicon = BitmapDescriptor.fromBytes(onrideicon1);
          offlineicon = BitmapDescriptor.fromBytes(offlineicon1);
          onlineicon = BitmapDescriptor.fromBytes(onlineicon1);
          onridebikeicon = BitmapDescriptor.fromBytes(onridebikeicon1);
          offlinebikeicon = BitmapDescriptor.fromBytes(offlinebikeicon1);
          onlinebikeicon = BitmapDescriptor.fromBytes(onlinebikeicon1);
        }
        if (center == null) {
          var locs = await geolocator.Geolocator.getLastKnownPosition();
          if (locs != null) {
            center = LatLng(locs.latitude, locs.longitude);
            heading = locs.heading;
          } else {
            loc = await geolocator.Geolocator.getCurrentPosition(
                desiredAccuracy: geolocator.LocationAccuracy.low);
            center = LatLng(double.parse(loc.latitude.toString()),
                double.parse(loc.longitude.toString()));
            heading = loc.heading;
          }
          _controller?.animateCamera(CameraUpdate.newLatLngZoom(center, 14.0));
        }
        if (mounted) {
          setState(() {
            pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
            pinLocationIcon2 = BitmapDescriptor.fromBytes(markerIcon2);

            if (myMarkers.isEmpty && userDetails['role'] != 'owner') {
              myMarkers = [
                Marker(
                    markerId: const MarkerId('1'),
                    rotation: heading,
                    position: center,
                    icon: (userDetails['vehicle_type_icon_for'] == 'motor_bike')
                        ? pinLocationIcon2
                        : pinLocationIcon,
                    anchor: const Offset(0.5, 0.5))
              ];
            }
          });
        }
      }

      if (makeOnline == true && userDetails['active'] == false) {
        var val = await driverStatus();
        if (val == 'logout') {
          navigateLogout();
        }
      }
      makeOnline = false;
      if (mounted) {
        setState(() {
          locationAllowed = true;
          state = '3';
          _isLoading = false;
        });
      }
    }
  }

  getLocationService() async {
    // await location.requestService();
    await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.low);
    getLocs();
  }

  getLocationPermission() async {
    if (permission == geolocator.LocationPermission.denied ||
        permission == geolocator.LocationPermission.deniedForever) {
      if (permission != geolocator.LocationPermission.deniedForever) {
        await perm.Permission.location.request();
      }
      if (serviceEnabled == false) {
        await geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.low);
        // await location.requestService();
      }
    } else if (serviceEnabled == false) {
      await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.low);
      // await location.requestService();
    }
    setState(() {
      _isLoading = true;
    });
    getLocs();
  }

  getLatLngBounds() {
    LatLngBounds bound;
    if (driverReq['pick_lat'] > driverReq['drop_lat'] &&
        driverReq['pick_lng'] > driverReq['drop_lng']) {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['drop_lat'], driverReq['drop_lng']),
          northeast: LatLng(driverReq['pick_lat'], driverReq['pick_lng']));
    } else if (driverReq['pick_lng'] > driverReq['drop_lng']) {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['pick_lat'], driverReq['drop_lng']),
          northeast: LatLng(driverReq['drop_lat'], driverReq['pick_lng']));
    } else if (driverReq['pick_lat'] > driverReq['drop_lat']) {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['drop_lat'], driverReq['pick_lng']),
          northeast: LatLng(driverReq['pick_lat'], driverReq['drop_lng']));
    } else {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['pick_lat'], driverReq['pick_lng']),
          northeast: LatLng(driverReq['drop_lat'], driverReq['drop_lng']));
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bound, 50);
    _controller?.animateCamera(cameraUpdate);
    // setState((){});
  }

  int _bottom = 0;

  GeoHasher geo = GeoHasher();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (platform == TargetPlatform.android) {
          platforms.invokeMethod('pipmode');
        }
        return false;
      },
      child: Material(
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              if (_isDarkTheme != isDarkTheme && _controller != null) {
                _controller!.setMapStyle(mapStyle);
                _isDarkTheme = isDarkTheme;
              }
              if (isGeneral == true) {
                isGeneral = false;
                if (lastNotification != latestNotification) {
                  lastNotification = latestNotification;
                  pref.setString('lastNotification', latestNotification);
                  latestNotification = '';
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationPage()));
                  });
                }
              }
              if (myMarkers
                  .where((element) => element.markerId == const MarkerId('1'))
                  .isNotEmpty) {
                if (userDetails['vehicle_type_icon_for'] == 'taxi' &&
                    myMarkers
                            .firstWhere((element) =>
                                element.markerId == const MarkerId('1'))
                            .icon ==
                        pinLocationIcon2) {
                  myMarkers.removeWhere(
                      (element) => element.markerId == const MarkerId('1'));
                } else if (userDetails['vehicle_type_icon_for'] != 'taxi' &&
                    myMarkers
                            .firstWhere((element) =>
                                element.markerId == const MarkerId('1'))
                            .icon ==
                        pinLocationIcon) {
                  myMarkers.removeWhere(
                      (element) => element.markerId == const MarkerId('1'));
                }
              }
              if (myMarkers
                      .where(
                          (element) => element.markerId == const MarkerId('1'))
                      .isNotEmpty &&
                  pinLocationIcon != null &&
                  _controller != null &&
                  center != null) {
                var dist = calculateDistance(
                    myMarkers
                        .firstWhere((element) =>
                            element.markerId == const MarkerId('1'))
                        .position
                        .latitude,
                    myMarkers
                        .firstWhere((element) =>
                            element.markerId == const MarkerId('1'))
                        .position
                        .longitude,
                    center.latitude,
                    center.longitude);
                if (dist > 100 &&
                    animationController == null &&
                    _controller != null) {
                  animationController = AnimationController(
                    duration: const Duration(
                        milliseconds: 1500), //Animation duration of marker

                    vsync: this, //From the widget
                  );
                  animateCar(
                      myMarkers
                          .firstWhere((element) =>
                              element.markerId == const MarkerId('1'))
                          .position
                          .latitude,
                      myMarkers
                          .firstWhere((element) =>
                              element.markerId == const MarkerId('1'))
                          .position
                          .longitude,
                      center.latitude,
                      center.longitude,
                      _mapMarkerSink,
                      this,
                      _controller,
                      '1',
                      (userDetails['vehicle_type_icon_for'] == 'motor_bike')
                          ? pinLocationIcon2
                          : pinLocationIcon,
                      '',
                      '');
                }
              } else if (myMarkers
                      .where(
                          (element) => element.markerId == const MarkerId('1'))
                      .isEmpty &&
                  pinLocationIcon != null &&
                  center != null &&
                  userDetails['role'] != 'owner') {
                myMarkers.add(Marker(
                    markerId: const MarkerId('1'),
                    rotation: heading,
                    position: center,
                    icon: (userDetails['vehicle_type_icon_for'] == 'motor_bike')
                        ? pinLocationIcon2
                        : pinLocationIcon,
                    anchor: const Offset(0.5, 0.5)));
              }
              if (driverReq.isNotEmpty) {
                if (_controller != null) {
                  mapPadding = media.width * 1;
                }

                if (driverReq['is_completed'] != 1) {
                  if (myMarkers
                          .where((element) =>
                              element.markerId == const MarkerId('2'))
                          .isEmpty &&
                      _pickAnimateDone != true &&
                      isBackground == false) {
                    _pickAnimateDone = true;
                    Future.delayed(const Duration(milliseconds: 100), () {
                      // _pickAnimateDone = true;
                      addPickDropMarker();
                      // addMarker();
                    });
                  }
                } else if (driverReq['is_completed'] == 1 &&
                    driverReq['requestBill'] != null &&
                    currentpage == true) {
                  currentpage = false;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Invoice()),
                        (route) => false);
                  });
                  _pickAnimateDone = false;
                  _dropMarkerDone = false;
                  myMarkers.removeWhere(
                      (element) => element.markerId != const MarkerId('1'));
                  polyline.clear();
                }

                if (driverReq['accepted_at'] != null &&
                    _dropMarkerDone == false &&
                    driverReq['drop_address'] != null) {
                  _dropMarkerDone = true;
                  Future.delayed(const Duration(seconds: 2), () {
                    if (myMarkers
                        .where((element) =>
                            element.markerId == const MarkerId('3'))
                        .isNotEmpty) {
                      myMarkers.removeWhere(
                          (element) => element.markerId == const MarkerId('3'));
                    }
                    addDropMarker();
                  });
                }
              } else {
                mapPadding = 0;
                if (myMarkers
                    .where((element) => element.markerId != const MarkerId('1'))
                    .isNotEmpty) {
                  myMarkers.removeWhere(
                      (element) => element.markerId != const MarkerId('1'));
                  polyline.clear();
                  if (userReject == true) {
                    reqCancel();
                  }
                }
                _pickAnimateDone = false;
                _dropMarkerDone = false;
              }

              if (userDetails['approve'] == false && driverReq.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DocsProcess()),
                      (route) => false);
                });
              }
              if (package == null) {
                checkVersion();
              }
              return Directionality(
                textDirection: (languageDirection == 'rtl')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Scaffold(
                  drawer: const NavDrawer(),
                  body: StreamBuilder(
                      stream: userDetails['role'] == 'owner'
                          ? FirebaseDatabase.instance
                              .ref('drivers')
                              .orderByChild('ownerid')
                              .equalTo(userDetails['id'].toString())
                              .onValue
                          : null,
                      builder: (context, AsyncSnapshot<DatabaseEvent> event) {
                        if (event.hasData) {
                          driverData.clear();
                          for (var element in event.data!.snapshot.children) {
                            driverData.add(element.value);
                          }
                          // myMarkers.removeWhere((element) =>
                          //     element.markerId.toString().contains('car'));
                          for (var element in driverData) {
                            if (element['l'] != null &&
                                element['is_deleted'] != 1) {
                              if (userDetails['role'] == 'owner') {
                                if (userDetails['role'] == 'owner' &&
                                    offlineicon != null &&
                                    onlineicon != null &&
                                    onrideicon != null &&
                                    filtericon == 0) {
                                  if (myMarkers
                                      .where((e) => e.markerId
                                          .toString()
                                          .contains('car${element['id']}'))
                                      .isEmpty) {
                                    myMarkers.add(Marker(
                                      markerId: MarkerId('car${element['id']}'),
                                      rotation: double.parse(
                                          element['bearing'].toString()),
                                      position: LatLng(
                                          element['l'][0], element['l'][1]),
                                      infoWindow: InfoWindow(
                                          title: element['vehicle_number'],
                                          snippet: element['name']),
                                      anchor: const Offset(0.5, 0.5),
                                      icon: (element['is_active'] == 0)
                                          ? (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? offlinebikeicon
                                              : offlineicon
                                          : (element['is_available'] == true &&
                                                  element['is_active'] == 1)
                                              ? (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onlinebikeicon
                                                  : onlineicon
                                              : (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onridebikeicon
                                                  : onrideicon,
                                    ));
                                  } else if ((element['is_active'] != 0 && myMarkers.lastWhere((e) => e.markerId.toString().contains('car${element['id']}')).icon == offlineicon) ||
                                      (element['is_active'] != 0 &&
                                          myMarkers.lastWhere((e) => e.markerId.toString().contains('car${element['id']}')).icon ==
                                              offlinebikeicon)) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'));
                                    myMarkers.add(Marker(
                                      markerId: MarkerId('car${element['id']}'),
                                      rotation: double.parse(
                                          element['bearing'].toString()),
                                      position: LatLng(
                                          element['l'][0], element['l'][1]),
                                      infoWindow: InfoWindow(
                                          title: element['vehicle_number'],
                                          snippet: element['name']),
                                      anchor: const Offset(0.5, 0.5),
                                      icon: (element['is_active'] == 0)
                                          ? (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? offlinebikeicon
                                              : offlineicon
                                          : (element['is_available'] == true &&
                                                  element['is_active'] == 1)
                                              ? (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onlinebikeicon
                                                  : onlineicon
                                              : (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onridebikeicon
                                                  : onrideicon,
                                    ));
                                  } else if ((element['is_available'] != true &&
                                          myMarkers.lastWhere((e) => e.markerId.toString().contains('car${element['id']}')).icon ==
                                              onlineicon) ||
                                      (element['is_available'] != true &&
                                          myMarkers.lastWhere((e) => e.markerId.toString().contains('car${element['id']}')).icon ==
                                              onlinebikeicon)) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'));
                                    myMarkers.add(Marker(
                                      markerId: MarkerId('car${element['id']}'),
                                      rotation: double.parse(
                                          element['bearing'].toString()),
                                      position: LatLng(
                                          element['l'][0], element['l'][1]),
                                      infoWindow: InfoWindow(
                                          title: element['vehicle_number'],
                                          snippet: element['name']),
                                      anchor: const Offset(0.5, 0.5),
                                      icon: (element['is_active'] == 0)
                                          ? (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? offlinebikeicon
                                              : offlineicon
                                          : (element['is_available'] == true &&
                                                  element['is_active'] == 1)
                                              ? (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onlinebikeicon
                                                  : onlineicon
                                              : (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onridebikeicon
                                                  : onrideicon,
                                    ));
                                  } else if ((element['is_active'] != 1 && myMarkers.lastWhere((e) => e.markerId.toString().contains('car${element['id']}')).icon == onlineicon) ||
                                      (element['is_active'] != 1 &&
                                          myMarkers.lastWhere((e) => e.markerId.toString().contains('car${element['id']}')).icon ==
                                              onlinebikeicon)) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'));
                                    myMarkers.add(Marker(
                                      markerId: MarkerId('car${element['id']}'),
                                      rotation: double.parse(
                                          element['bearing'].toString()),
                                      position: LatLng(
                                          element['l'][0], element['l'][1]),
                                      infoWindow: InfoWindow(
                                          title: element['vehicle_number'],
                                          snippet: element['name']),
                                      anchor: const Offset(0.5, 0.5),
                                      icon: (element['is_active'] == 0)
                                          ? (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? offlinebikeicon
                                              : offlineicon
                                          : (element['is_available'] == true &&
                                                  element['is_active'] == 1)
                                              ? (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onlinebikeicon
                                                  : onlineicon
                                              : (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onridebikeicon
                                                  : onrideicon,
                                    ));
                                  } else if ((element['is_available'] == true &&
                                          myMarkers.lastWhere((e) => e.markerId.toString().contains('car${element['id']}')).icon ==
                                              onrideicon) ||
                                      (element['is_available'] == true &&
                                          myMarkers.lastWhere((e) => e.markerId.toString().contains('car${element['id']}')).icon ==
                                              onridebikeicon)) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'));
                                    myMarkers.add(Marker(
                                      markerId: MarkerId('car${element['id']}'),
                                      rotation: double.parse(
                                          element['bearing'].toString()),
                                      position: LatLng(
                                          element['l'][0], element['l'][1]),
                                      infoWindow: InfoWindow(
                                          title: element['vehicle_number'],
                                          snippet: element['name']),
                                      anchor: const Offset(0.5, 0.5),
                                      icon: (element['is_active'] == 0)
                                          ? (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? offlinebikeicon
                                              : offlineicon
                                          : (element['is_available'] == true &&
                                                  element['is_active'] == 1)
                                              ? (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onlinebikeicon
                                                  : onlineicon
                                              : (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onridebikeicon
                                                  : onrideicon,
                                    ));
                                  } else if (_controller != null) {
                                    if (myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car${element['id']}'))
                                                .position
                                                .latitude !=
                                            element['l'][0] ||
                                        myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car${element['id']}'))
                                                .position
                                                .longitude !=
                                            element['l'][1]) {
                                      var dist = calculateDistance(
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car${element['id']}'))
                                              .position
                                              .latitude,
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car${element['id']}'))
                                              .position
                                              .longitude,
                                          element['l'][0],
                                          element['l'][1]);
                                      if (dist > 100 && _controller != null) {
                                        animationController =
                                            AnimationController(
                                          duration: const Duration(
                                              milliseconds:
                                                  1500), //Animation duration of marker

                                          vsync: this, //From the widget
                                        );

                                        animateCar(
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car${element['id']}'))
                                                .position
                                                .latitude,
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car${element['id']}'))
                                                .position
                                                .longitude,
                                            element['l'][0],
                                            element['l'][1],
                                            _mapMarkerSink,
                                            this,
                                            _controller,
                                            'car${element['id']}',
                                            (element['is_active'] == 0)
                                                ? (element['vehicle_type_icon'] ==
                                                        'motor_bike')
                                                    ? offlinebikeicon
                                                    : offlineicon
                                                : (element['is_available'] ==
                                                            true &&
                                                        element['is_active'] ==
                                                            1)
                                                    ? (element['vehicle_type_icon'] ==
                                                            'motor_bike')
                                                        ? onlinebikeicon
                                                        : onlineicon
                                                    : (element['vehicle_type_icon'] ==
                                                            'motor_bike')
                                                        ? onridebikeicon
                                                        : onrideicon,
                                            element['vehicle_number'],
                                            element['name']);
                                      }
                                    }
                                  }
                                } else if (filtericon == 1 &&
                                    userDetails['role'] == 'owner' &&
                                    onlineicon != null) {
                                  if (element['l'] != null) {
                                    if (element['is_active'] == 0 &&
                                        offlineicon != null) {
                                      if (myMarkers
                                          .where((e) => e.markerId
                                              .toString()
                                              .contains('car${element['id']}'))
                                          .isEmpty) {
                                        myMarkers.add(Marker(
                                          markerId: MarkerId(
                                              'carid${element['id']}idoffline'),
                                          rotation: double.parse(
                                              element['bearing'].toString()),
                                          position: LatLng(
                                              element['l'][0], element['l'][1]),
                                          anchor: const Offset(0.5, 0.5),
                                          icon: (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? offlinebikeicon
                                              : offlineicon,
                                        ));
                                      } else if (_controller != null) {
                                        if (myMarkers
                                                    .lastWhere((e) => e.markerId
                                                        .toString()
                                                        .contains(
                                                            'car${element['id']}'))
                                                    .position
                                                    .latitude !=
                                                element['l'][0] ||
                                            myMarkers
                                                    .lastWhere((e) => e.markerId
                                                        .toString()
                                                        .contains(
                                                            'car${element['id']}'))
                                                    .position
                                                    .longitude !=
                                                element['l'][1]) {
                                          var dist = calculateDistance(
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                      .toString()
                                                      .contains(
                                                          'car${element['id']}'))
                                                  .position
                                                  .latitude,
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                      .toString()
                                                      .contains(
                                                          'car${element['id']}'))
                                                  .position
                                                  .longitude,
                                              element['l'][0],
                                              element['l'][1]);
                                          if (dist > 100 &&
                                              _controller != null) {
                                            animationController =
                                                AnimationController(
                                              duration: const Duration(
                                                  milliseconds:
                                                      1500), //Animation duration of marker

                                              vsync: this, //From the widget
                                            );

                                            animateCar(
                                                myMarkers
                                                    .lastWhere((e) => e.markerId
                                                        .toString()
                                                        .contains(
                                                            'car${element['id']}'))
                                                    .position
                                                    .latitude,
                                                myMarkers
                                                    .lastWhere((e) => e.markerId
                                                        .toString()
                                                        .contains(
                                                            'car${element['id']}'))
                                                    .position
                                                    .longitude,
                                                element['l'][0],
                                                element['l'][1],
                                                _mapMarkerSink,
                                                this,
                                                _controller,
                                                'car${element['id']}',
                                                (element['vehicle_type_icon'] ==
                                                        'motor_bike')
                                                    ? offlinebikeicon
                                                    : offlineicon,
                                                element['vehicle_number'],
                                                element['name']);
                                          }
                                        }
                                      }
                                    } else {
                                      if (myMarkers
                                          .where((e) => e.markerId
                                              .toString()
                                              .contains('car${element['id']}'))
                                          .isNotEmpty) {
                                        myMarkers.removeWhere((e) => e.markerId
                                            .toString()
                                            .contains('car${element['id']}'));
                                      }
                                    }
                                  }
                                } else if (filtericon == 2 &&
                                    userDetails['role'] == 'owner' &&
                                    onlineicon != null) {
                                  if (element['is_available'] == false &&
                                      element['is_active'] == 1) {
                                    if (myMarkers
                                        .where((e) => e.markerId
                                            .toString()
                                            .contains('car${element['id']}'))
                                        .isEmpty) {
                                      myMarkers.add(Marker(
                                        markerId:
                                            MarkerId('car${element['id']}'),
                                        rotation: double.parse(
                                            element['bearing'].toString()),
                                        position: LatLng(
                                            element['l'][0], element['l'][1]),
                                        anchor: const Offset(0.5, 0.5),
                                        icon: (element['vehicle_type_icon'] ==
                                                'motor_bike')
                                            ? onridebikeicon
                                            : onrideicon,
                                      ));
                                    } else if (_controller != null) {
                                      if (myMarkers
                                                  .lastWhere((e) => e.markerId
                                                      .toString()
                                                      .contains(
                                                          'car${element['id']}'))
                                                  .position
                                                  .latitude !=
                                              element['l'][0] ||
                                          myMarkers
                                                  .lastWhere((e) => e.markerId
                                                      .toString()
                                                      .contains(
                                                          'car${element['id']}'))
                                                  .position
                                                  .longitude !=
                                              element['l'][1]) {
                                        var dist = calculateDistance(
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car${element['id']}'))
                                                .position
                                                .latitude,
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car${element['id']}'))
                                                .position
                                                .longitude,
                                            element['l'][0],
                                            element['l'][1]);
                                        if (dist > 100 && _controller != null) {
                                          animationController =
                                              AnimationController(
                                            duration: const Duration(
                                                milliseconds:
                                                    1500), //Animation duration of marker

                                            vsync: this, //From the widget
                                          );

                                          animateCar(
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                      .toString()
                                                      .contains(
                                                          'car${element['id']}'))
                                                  .position
                                                  .latitude,
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                      .toString()
                                                      .contains(
                                                          'car${element['id']}'))
                                                  .position
                                                  .longitude,
                                              element['l'][0],
                                              element['l'][1],
                                              _mapMarkerSink,
                                              this,
                                              _controller,
                                              'car${element['id']}',
                                              (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onridebikeicon
                                                  : onrideicon,
                                              element['vehicle_number'],
                                              element['name']);
                                        }
                                      }
                                    }
                                  } else {
                                    if (myMarkers
                                        .where((e) => e.markerId
                                            .toString()
                                            .contains('car${element['id']}'))
                                        .isNotEmpty) {
                                      myMarkers.removeWhere((e) => e.markerId
                                          .toString()
                                          .contains('car${element['id']}'));
                                    }
                                  }
                                } else if (filtericon == 3 &&
                                    userDetails['role'] == 'owner' &&
                                    onlineicon != null) {
                                  if (element['is_available'] == true &&
                                      element['is_active'] == 1) {
                                    if (myMarkers
                                        .where((e) => e.markerId
                                            .toString()
                                            .contains('car${element['id']}'))
                                        .isEmpty) {
                                      myMarkers.add(Marker(
                                        markerId:
                                            MarkerId('car${element['id']}'),
                                        rotation: double.parse(
                                            element['bearing'].toString()),
                                        position: LatLng(
                                            element['l'][0], element['l'][1]),
                                        anchor: const Offset(0.5, 0.5),
                                        icon: (element['vehicle_type_icon'] ==
                                                'motor_bike')
                                            ? onlinebikeicon
                                            : onlineicon,
                                      ));
                                    } else if (_controller != null) {
                                      if (myMarkers
                                                  .lastWhere((e) => e.markerId
                                                      .toString()
                                                      .contains(
                                                          'car${element['id']}'))
                                                  .position
                                                  .latitude !=
                                              element['l'][0] ||
                                          myMarkers
                                                  .lastWhere((e) => e.markerId
                                                      .toString()
                                                      .contains(
                                                          'car${element['id']}'))
                                                  .position
                                                  .longitude !=
                                              element['l'][1]) {
                                        var dist = calculateDistance(
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car${element['id']}'))
                                                .position
                                                .latitude,
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car${element['id']}'))
                                                .position
                                                .longitude,
                                            element['l'][0],
                                            element['l'][1]);
                                        if (dist > 100 && _controller != null) {
                                          animationController =
                                              AnimationController(
                                            duration: const Duration(
                                                milliseconds:
                                                    1500), //Animation duration of marker

                                            vsync: this, //From the widget
                                          );

                                          animateCar(
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                      .toString()
                                                      .contains(
                                                          'car${element['id']}'))
                                                  .position
                                                  .latitude,
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                      .toString()
                                                      .contains(
                                                          'car${element['id']}'))
                                                  .position
                                                  .longitude,
                                              element['l'][0],
                                              element['l'][1],
                                              _mapMarkerSink,
                                              this,
                                              _controller,
                                              'car${element['id']}',
                                              (element['vehicle_type_icon'] ==
                                                      'motor_bike')
                                                  ? onlinebikeicon
                                                  : onlineicon,
                                              element['vehicle_number'],
                                              element['name']);
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (myMarkers
                                      .where((e) => e.markerId
                                          .toString()
                                          .contains('car${element['id']}'))
                                      .isNotEmpty) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'));
                                  }
                                }
                              }
                            } else {
                              if (myMarkers
                                  .where((e) => e.markerId
                                      .toString()
                                      .contains('car${element['id']}'))
                                  .isNotEmpty) {
                                myMarkers.removeWhere((e) => e.markerId
                                    .toString()
                                    .contains('car${element['id']}'));
                              }
                            }
                          }
                        }
                        return SingleChildScrollView(
                          child: Stack(
                            children: [
                              Container(
                                color: page,
                                height: media.height * 1,
                                width: media.width * 1,
                                child: Column(
                                    mainAxisAlignment:
                                        (state == '1' || state == '2')
                                            ? MainAxisAlignment.center
                                            : MainAxisAlignment.start,
                                    children: [
                                      (state == '1')
                                          ? Container(
                                              padding: EdgeInsets.all(
                                                  media.width * 0.05),
                                              width: media.width * 0.6,
                                              height: media.width * 0.3,
                                              decoration: BoxDecoration(
                                                  color: page,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        blurRadius: 5,
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        spreadRadius: 2)
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    languages[choosenLanguage][
                                                        'text_enable_location'],
                                                    style: GoogleFonts.roboto(
                                                        fontSize: media.width *
                                                            sixteen,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          state = '';
                                                        });
                                                        getLocs();
                                                      },
                                                      child: Text(
                                                        languages[
                                                                choosenLanguage]
                                                            ['text_ok'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: media
                                                                        .width *
                                                                    twenty,
                                                                color:
                                                                    buttonColor),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          : (state == '2')
                                              ? Container(
                                                  height: media.height * 1,
                                                  width: media.width * 1,
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        height:
                                                            media.height * 0.31,
                                                        child: Image.asset(
                                                          'assets/images/allow_location_permission.png',
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.05,
                                                      ),
                                                      Text(
                                                        languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_trustedtaxi'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                                color:
                                                                    textColor,
                                                                fontSize: media
                                                                        .width *
                                                                    eighteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.025,
                                                      ),
                                                      Text(
                                                        languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_allowpermission1'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  fourteen,
                                                        ),
                                                      ),
                                                      Text(
                                                        languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_allowpermission2'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                          color: textColor,
                                                          fontSize:
                                                              media.width *
                                                                  fourteen,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.05,
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                media.width *
                                                                    0.05,
                                                                0,
                                                                media.width *
                                                                    0.05,
                                                                0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.075,
                                                                child: Icon(
                                                                    Icons
                                                                        .location_on_outlined,
                                                                    color:
                                                                        textColor)),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.8,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_loc_permission'],
                                                                style: GoogleFonts.roboto(
                                                                    color:
                                                                        textColor,
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.02,
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                media.width *
                                                                    0.05,
                                                                0,
                                                                media.width *
                                                                    0.05,
                                                                0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.075,
                                                                child: Icon(
                                                                    Icons
                                                                        .location_on_outlined,
                                                                    color:
                                                                        textColor)),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.8,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_background_permission'],
                                                                style: GoogleFonts.roboto(
                                                                    color:
                                                                        textColor,
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  media.width *
                                                                      0.05),
                                                          child: Button(
                                                              onTap: () async {
                                                                getLocationPermission();
                                                              },
                                                              text: languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_continue']))
                                                    ],
                                                  ),
                                                )
                                              : (state == '3')
                                                  ? Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        SizedBox(
                                                            height:
                                                                media.height *
                                                                    1,
                                                            width:
                                                                media.width * 1,
                                                            //google maps
                                                            child: StreamBuilder<
                                                                    List<
                                                                        Marker>>(
                                                                stream:
                                                                    mapMarkerStream,
                                                                builder: (context,
                                                                    snapshot) {
                                                                  return GoogleMap(
                                                                    padding: EdgeInsets.only(
                                                                        bottom:
                                                                            mapPadding,
                                                                        top: media.height *
                                                                                0.1 +
                                                                            MediaQuery.of(context).padding.top),
                                                                    onMapCreated:
                                                                        _onMapCreated,
                                                                    initialCameraPosition:
                                                                        CameraPosition(
                                                                      target: (center ==
                                                                              null)
                                                                          ? _center
                                                                          : center,
                                                                      zoom:
                                                                          11.0,
                                                                    ),
                                                                    markers: Set<
                                                                            Marker>.from(
                                                                        myMarkers),
                                                                    polylines:
                                                                        polyline,
                                                                    minMaxZoomPreference:
                                                                        const MinMaxZoomPreference(
                                                                            0.0,
                                                                            20.0),
                                                                    myLocationButtonEnabled:
                                                                        false,
                                                                    compassEnabled:
                                                                        false,
                                                                    buildingsEnabled:
                                                                        false,
                                                                    zoomControlsEnabled:
                                                                        false,
                                                                  );
                                                                })),

                                                        //driver status
                                                        (userDetails['role'] ==
                                                                'owner')
                                                            ? Container()
                                                            : Positioned(
                                                                top: MediaQuery.of(
                                                                            context)
                                                                        .padding
                                                                        .top +
                                                                    25,
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets.fromLTRB(
                                                                      media.width *
                                                                          0.05,
                                                                      media.width *
                                                                          0.025,
                                                                      media.width *
                                                                          0.05,
                                                                      media.width *
                                                                          0.025),
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            blurRadius:
                                                                                2,
                                                                            color:
                                                                                Colors.black.withOpacity(0.2),
                                                                            spreadRadius: 2)
                                                                      ],
                                                                      color:
                                                                          page),
                                                                  //driver status display
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            10,
                                                                        width:
                                                                            10,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                                shape: BoxShape
                                                                                    .circle,
                                                                                boxShadow: [
                                                                                  BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2)
                                                                                ],
                                                                                color: (driverReq.isEmpty)
                                                                                    ? (userDetails['active'] == false)
                                                                                        ? const Color(0xff666666)
                                                                                        : const Color(0xff319900)
                                                                                    : (driverReq['accepted_at'] != null && driverReq['arrived_at'] == null)
                                                                                        ? const Color(0xff2E67D5)
                                                                                        : (driverReq['accepted_at'] != null && driverReq['arrived_at'] != null && driverReq['is_trip_start'] == 0)
                                                                                            ? const Color(0xff319900)
                                                                                            : (driverReq['accepted_at'] != null && driverReq['arrived_at'] != null && driverReq['is_trip_start'] != null)
                                                                                                ? const Color(0xffFF0000)
                                                                                                : (driverReq['accepted'] == null && userDetails['active'] == false)
                                                                                                    ? const Color(0xff666666)
                                                                                                    : const Color(0xff319900)),
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.02,
                                                                      ),
                                                                      Text(
                                                                        (driverReq.isEmpty)
                                                                            ? (userDetails['active'] == false)
                                                                                ? languages[choosenLanguage]['text_youareoffline']
                                                                                : languages[choosenLanguage]['text_youareonline']
                                                                            : (driverReq['accepted_at'] != null && driverReq['arrived_at'] == null)
                                                                                ? languages[choosenLanguage]['text_arriving']
                                                                                : (driverReq['accepted_at'] != null && driverReq['arrived_at'] != null && driverReq['is_trip_start'] == 0)
                                                                                    ? languages[choosenLanguage]['text_arrived']
                                                                                    : (driverReq['accepted_at'] != null && driverReq['arrived_at'] != null && driverReq['is_trip_start'] != null)
                                                                                        ? languages[choosenLanguage]['text_onride']
                                                                                        : (driverReq['accepted'] == null && userDetails['active'] == false)
                                                                                            ? languages[choosenLanguage]['text_youareoffline']
                                                                                            : languages[choosenLanguage]['text_youareonline'],
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize: media.width * twelve,
                                                                            color: (driverReq.isEmpty)
                                                                                ? (userDetails['active'] == false)
                                                                                    ? const Color(0xff666666)
                                                                                    : const Color(0xff319900)
                                                                                : (driverReq['accepted_at'] != null && driverReq['arrived_at'] == null)
                                                                                    ? const Color(0xff2E67D5)
                                                                                    : (driverReq['accepted_at'] != null && driverReq['arrived_at'] != null && driverReq['is_trip_start'] == 0)
                                                                                        ? const Color(0xff319900)
                                                                                        : (driverReq['accepted_at'] != null && driverReq['arrived_at'] != null && driverReq['is_trip_start'] == 1)
                                                                                            ? const Color(0xffFF0000)
                                                                                            : (driverReq['accepted'] == null && userDetails['active'] == false)
                                                                                                ? const Color(0xff666666)
                                                                                                : const Color(0xff319900)),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )),
                                                        //menu bar
                                                        Positioned(
                                                            top: MediaQuery.of(
                                                                        context)
                                                                    .padding
                                                                    .top +
                                                                12.5,
                                                            child: SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.9,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    height:
                                                                        media.width *
                                                                            0.1,
                                                                    width: media
                                                                            .width *
                                                                        0.1,
                                                                    decoration: BoxDecoration(
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                              blurRadius: 2,
                                                                              color: textColor.withOpacity(0.2),
                                                                              spreadRadius: 2)
                                                                        ],
                                                                        color:
                                                                            page,
                                                                        borderRadius:
                                                                            BorderRadius.circular(media.width *
                                                                                0.02)),
                                                                    child: StatefulBuilder(builder:
                                                                        (context,
                                                                            setState) {
                                                                      return InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            Scaffold.of(context).openDrawer();
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.menu,
                                                                            color:
                                                                                textColor,
                                                                          ));
                                                                    }),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                        //online or offline button
                                                        (userDetails['role'] ==
                                                                'owner')
                                                            ? (languageDirection ==
                                                                    'rtl')
                                                                ? Positioned(
                                                                    top: MediaQuery.of(context)
                                                                            .padding
                                                                            .top +
                                                                        12.5,
                                                                    left: 10,
                                                                    child:
                                                                        AnimatedContainer(
                                                                      curve: Curves
                                                                          .fastLinearToSlowEaseIn,
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              0),
                                                                      height: media
                                                                              .width *
                                                                          0.13,
                                                                      width: (show == true)
                                                                          ? media.width *
                                                                              0.13
                                                                          : media.width *
                                                                              0.7,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius: show ==
                                                                                true
                                                                            ? BorderRadius.circular(
                                                                                100.0)
                                                                            : const BorderRadius.only(
                                                                                topLeft: Radius.circular(100),
                                                                                bottomLeft: Radius.circular(100),
                                                                                topRight: Radius.circular(20),
                                                                                bottomRight: Radius.circular(20)),
                                                                        color: Colors
                                                                            .white,
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            color: ui.Color.fromARGB(
                                                                                255,
                                                                                8,
                                                                                38,
                                                                                172),
                                                                            offset:
                                                                                Offset(0.0, 1.0), //(x,y)
                                                                            blurRadius:
                                                                                10.0,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          show == false
                                                                              ? SizedBox(
                                                                                  width: media.width * 0.57,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                    children: [
                                                                                      OwnerCarImagecontainer(
                                                                                        color: Colors.green,
                                                                                        imgurl: 'assets/images/available.png',
                                                                                        text: languages[choosenLanguage]['text_available'],
                                                                                        ontap: () {
                                                                                          setState(() {
                                                                                            filtericon = 3;
                                                                                            myMarkers.clear();
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                      OwnerCarImagecontainer(
                                                                                        color: Colors.red,
                                                                                        imgurl: 'assets/images/onboard.png',
                                                                                        text: languages[choosenLanguage]['text_onboard'],
                                                                                        ontap: () {
                                                                                          setState(() {
                                                                                            filtericon = 2;
                                                                                            myMarkers.clear();
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                      OwnerCarImagecontainer(
                                                                                        color: Colors.grey,
                                                                                        imgurl: 'assets/images/offlinecar.png',
                                                                                        text: languages[choosenLanguage]['text_offline'],
                                                                                        ontap: () {
                                                                                          setState(() {
                                                                                            filtericon = 1;
                                                                                            myMarkers.clear();
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              : Container(),
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                filtericon = 0;
                                                                                myMarkers.clear();
                                                                                if (show == false) {
                                                                                  show = true;
                                                                                } else {
                                                                                  show = false;
                                                                                }
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              width: media.width * 0.13,
                                                                              decoration: BoxDecoration(image: const DecorationImage(image: AssetImage('assets/images/bluecar.png'), fit: BoxFit.contain), borderRadius: BorderRadius.circular(100.0)),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Positioned(
                                                                    top: MediaQuery.of(context)
                                                                            .padding
                                                                            .top +
                                                                        12.5,
                                                                    right: 10,
                                                                    child:
                                                                        AnimatedContainer(
                                                                      curve: Curves
                                                                          .fastLinearToSlowEaseIn,
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              0),
                                                                      height: media
                                                                              .width *
                                                                          0.13,
                                                                      width: (show == true)
                                                                          ? media.width *
                                                                              0.13
                                                                          : media.width *
                                                                              0.7,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius: show ==
                                                                                true
                                                                            ? BorderRadius.circular(
                                                                                100.0)
                                                                            : const BorderRadius.only(
                                                                                topLeft: Radius.circular(20),
                                                                                bottomLeft: Radius.circular(20),
                                                                                topRight: Radius.circular(100),
                                                                                bottomRight: Radius.circular(100)),
                                                                        color: Colors
                                                                            .white,
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            color: ui.Color.fromARGB(
                                                                                255,
                                                                                8,
                                                                                38,
                                                                                172),
                                                                            offset:
                                                                                Offset(0.0, 1.0), //(x,y)
                                                                            blurRadius:
                                                                                10.0,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          show == false
                                                                              ? SizedBox(
                                                                                  width: media.width * 0.57,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                    children: [
                                                                                      OwnerCarImagecontainer(
                                                                                        color: Colors.green,
                                                                                        imgurl: 'assets/images/available.png',
                                                                                        text: languages[choosenLanguage]['text_available'],
                                                                                        ontap: () {
                                                                                          setState(() {
                                                                                            filtericon = 3;
                                                                                            myMarkers.clear();
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                      OwnerCarImagecontainer(
                                                                                        color: Colors.red,
                                                                                        imgurl: 'assets/images/onboard.png',
                                                                                        text: languages[choosenLanguage]['text_onboard'],
                                                                                        ontap: () {
                                                                                          setState(() {
                                                                                            filtericon = 2;
                                                                                            myMarkers.clear();
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                      OwnerCarImagecontainer(
                                                                                        color: Colors.grey,
                                                                                        imgurl: 'assets/images/offlinecar.png',
                                                                                        text: 'Offline',
                                                                                        ontap: () {
                                                                                          setState(() {
                                                                                            filtericon = 1;
                                                                                            myMarkers.clear();
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              : Container(),
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                filtericon = 0;
                                                                                myMarkers.clear();
                                                                                if (show == false) {
                                                                                  show = true;
                                                                                } else {
                                                                                  show = false;
                                                                                }
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              width: media.width * 0.13,
                                                                              decoration: BoxDecoration(image: const DecorationImage(image: AssetImage('assets/images/bluecar.png'), fit: BoxFit.contain), borderRadius: BorderRadius.circular(100.0)),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                            : Container(),

                                                        (userDetails['low_balance'] ==
                                                                    false) &&
                                                                (userDetails[
                                                                            'role'] ==
                                                                        'driver' &&
                                                                    (userDetails['vehicle_type_id'] !=
                                                                            null ||
                                                                        userDetails['vehicle_types']
                                                                            .isNotEmpty))
                                                            ? Positioned(
                                                                bottom: 25,
                                                                child: InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    // await getUserDetails();
                                                                    if (userDetails['role'] ==
                                                                            'driver' &&
                                                                        (userDetails['vehicle_type_id'] !=
                                                                                null ||
                                                                            userDetails['vehicle_types'] !=
                                                                                [])) {
                                                                      if (locationAllowed ==
                                                                              true &&
                                                                          serviceEnabled ==
                                                                              true) {
                                                                        setState(
                                                                            () {
                                                                          _isLoading =
                                                                              true;
                                                                        });

                                                                        var val =
                                                                            await driverStatus();
                                                                        if (val ==
                                                                            'logout') {
                                                                          navigateLogout();
                                                                        }
                                                                        setState(
                                                                            () {
                                                                          _isLoading =
                                                                              false;
                                                                        });
                                                                      } else if (locationAllowed ==
                                                                              true &&
                                                                          serviceEnabled ==
                                                                              false) {
                                                                        await geolocator.Geolocator.getCurrentPosition(
                                                                            desiredAccuracy:
                                                                                geolocator.LocationAccuracy.low);
                                                                        // await location
                                                                        //     .requestService();
                                                                        if (await geolocator
                                                                            .GeolocatorPlatform
                                                                            .instance
                                                                            .isLocationServiceEnabled()) {
                                                                          serviceEnabled =
                                                                              true;
                                                                          setState(
                                                                              () {
                                                                            _isLoading =
                                                                                true;
                                                                          });

                                                                          var val =
                                                                              await driverStatus();
                                                                          if (val ==
                                                                              'logout') {
                                                                            navigateLogout();
                                                                          }
                                                                          setState(
                                                                              () {
                                                                            _isLoading =
                                                                                false;
                                                                          });
                                                                        }
                                                                      } else {
                                                                        if (serviceEnabled ==
                                                                            true) {
                                                                          setState(
                                                                              () {
                                                                            makeOnline =
                                                                                true;
                                                                            _locationDenied =
                                                                                true;
                                                                          });
                                                                        } else {
                                                                          await geolocator.Geolocator.getCurrentPosition(
                                                                              desiredAccuracy: geolocator.LocationAccuracy.low);
                                                                          // await location
                                                                          //     .requestService();
                                                                          setState(
                                                                              () {
                                                                            _isLoading =
                                                                                true;
                                                                          });
                                                                          await getLocs();
                                                                          if (serviceEnabled ==
                                                                              true) {
                                                                            setState(() {
                                                                              makeOnline = true;
                                                                              _locationDenied = true;
                                                                            });
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.only(
                                                                        left: media.width *
                                                                            0.01,
                                                                        right: media.width *
                                                                            0.01),
                                                                    height: media
                                                                            .width *
                                                                        0.08,
                                                                    width: media
                                                                            .width *
                                                                        0.267,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(media.width *
                                                                              0.04),
                                                                      color: (userDetails['active'] ==
                                                                              false)
                                                                          ? offline
                                                                          : online,
                                                                    ),
                                                                    child: (userDetails['active'] ==
                                                                            false)
                                                                        ? Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Container(),
                                                                              Text(
                                                                                'OFF DUTY',
                                                                                style: GoogleFonts.roboto(fontSize: media.width * twelve, color: onlineOfflineText),
                                                                              ),
                                                                              Container(
                                                                                padding: EdgeInsets.all(media.width * 0.01),
                                                                                height: media.width * 0.07,
                                                                                width: media.width * 0.07,
                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: onlineOfflineText),
                                                                                child: Image.asset('assets/images/offline.png'),
                                                                              )
                                                                            ],
                                                                          )
                                                                        : Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Container(
                                                                                padding: EdgeInsets.all(media.width * 0.01),
                                                                                height: media.width * 0.07,
                                                                                width: media.width * 0.07,
                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: onlineOfflineText),
                                                                                child: Image.asset('assets/images/online.png'),
                                                                              ),
                                                                              Text(
                                                                                'ON DUTY',
                                                                                style: GoogleFonts.roboto(fontSize: media.width * twelve, color: onlineOfflineText),
                                                                              ),
                                                                              Container(),
                                                                            ],
                                                                          ),
                                                                  ),
                                                                ))
                                                            : (userDetails['role'] ==
                                                                        'driver' &&
                                                                    userDetails[
                                                                            'vehicle_type_id'] ==
                                                                        null &&
                                                                    userDetails[
                                                                            'vehicle_types']
                                                                        .isEmpty)
                                                                ? Positioned(
                                                                    bottom: 0,
                                                                    child:
                                                                        Container(
                                                                      color:
                                                                          buttonColor,
                                                                      width:
                                                                          media.width *
                                                                              1,
                                                                      padding: EdgeInsets.all(
                                                                          media.width *
                                                                              0.05),
                                                                      child:
                                                                          Text(
                                                                        languages[choosenLanguage]
                                                                            [
                                                                            'text_no_fleet_assigned'],
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              media.width * fourteen,
                                                                          color: isDarkTheme
                                                                              ? Colors.black
                                                                              : Colors.white,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : (userDetails
                                                                            .isNotEmpty &&
                                                                        userDetails['low_balance'] ==
                                                                            true)
                                                                    ?
                                                                    //low balance
                                                                    Positioned(
                                                                        bottom:
                                                                            0,
                                                                        child:
                                                                            Container(
                                                                          color:
                                                                              buttonColor,
                                                                          width:
                                                                              media.width * 1,
                                                                          padding:
                                                                              EdgeInsets.all(media.width * 0.05),
                                                                          child:
                                                                              Text(
                                                                            userDetails['owner_id'] != null
                                                                                ? languages[choosenLanguage]['text_fleet_diver_low_bal']
                                                                                : languages[choosenLanguage]['text_low_balance'],
                                                                            style:
                                                                                GoogleFonts.roboto(
                                                                              fontSize: media.width * fourteen,
                                                                              color: isDarkTheme ? verifyDeclined : Colors.white,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Container(),

                                                        //request popup accept or reject
                                                        Positioned(
                                                            bottom: 20,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                (driverReq.isNotEmpty &&
                                                                        driverReq['is_trip_start'] ==
                                                                            1)
                                                                    ? InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            showSos =
                                                                                true;
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              media.width * 0.1,
                                                                          width:
                                                                              media.width * 0.1,
                                                                          decoration: BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2)
                                                                              ],
                                                                              color: buttonColor,
                                                                              borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Text(
                                                                            'SOS',
                                                                            style:
                                                                                GoogleFonts.roboto(fontSize: media.width * fourteen, color: page),
                                                                          ),
                                                                        ))
                                                                    : Container(),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                (driverReq.isNotEmpty &&
                                                                        driverReq['accepted_at'] !=
                                                                            null)
                                                                    ? InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          if (driverReq['is_trip_start'] ==
                                                                              0) {
                                                                            openMap(driverReq['pick_lat'],
                                                                                driverReq['pick_lng']);
                                                                          } else if (tripStops
                                                                              .isNotEmpty) {
                                                                            setState(() {
                                                                              _tripOpenMap = true;
                                                                            });
                                                                          } else {
                                                                            openMap(driverReq['drop_lat'],
                                                                                driverReq['drop_lng']);
                                                                          }
                                                                        },
                                                                        child: Container(
                                                                            height: media.width *
                                                                                0.1,
                                                                            width: media.width *
                                                                                0.1,
                                                                            decoration:
                                                                                BoxDecoration(boxShadow: [
                                                                              BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2)
                                                                            ], color: page, borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                                            alignment: Alignment.center,
                                                                            child: Image.asset('assets/images/locationFind.png', width: media.width * 0.06, color: textColor)),
                                                                      )
                                                                    : Container(),
                                                                const SizedBox(
                                                                    height: 20),
                                                                //animate to current location button
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.9,
                                                                  child: Row(
                                                                    mainAxisAlignment: userDetails[
                                                                                'show_instant_ride_feature_on_mobile_app'] ==
                                                                            '1'
                                                                        ? MainAxisAlignment
                                                                            .spaceBetween
                                                                        : MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      (driverReq.isEmpty &&
                                                                              userDetails['role'] != 'owner' &&
                                                                              userDetails['active'] == true &&
                                                                              userDetails['show_instant_ride_feature_on_mobile_app'] == '1')
                                                                          ? Button(
                                                                              onTap: () async {
                                                                                addressList.clear();
                                                                                var val = await geoCoding(center.latitude, center.longitude);
                                                                                setState(() {
                                                                                  if (addressList.where((element) => element.id == 'pickup').isNotEmpty) {
                                                                                    var add = addressList.firstWhere((element) => element.id == 'pickup');
                                                                                    add.address = val;
                                                                                    add.latlng = LatLng(center.latitude, center.longitude);
                                                                                  } else {
                                                                                    addressList.add(AddressList(id: 'pickup', address: val, latlng: LatLng(center.latitude, center.longitude)));
                                                                                  }
                                                                                });

                                                                                if (addressList.isNotEmpty) {
                                                                                  // ignore: use_build_context_synchronously
                                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DropLocation()));
                                                                                }
                                                                              },
                                                                              text: languages[choosenLanguage]['text_instant_ride'])
                                                                          : Container(),
                                                                      InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          if (locationAllowed ==
                                                                              true) {
                                                                            _controller?.animateCamera(CameraUpdate.newLatLngZoom(center,
                                                                                18.0));
                                                                          } else {
                                                                            if (serviceEnabled ==
                                                                                true) {
                                                                              setState(() {
                                                                                _locationDenied = true;
                                                                              });
                                                                            } else {
                                                                              await geolocator.Geolocator.getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.low);
                                                                              setState(() {
                                                                                _isLoading = true;
                                                                              });
                                                                              await getLocs();
                                                                              if (serviceEnabled == true) {
                                                                                setState(() {
                                                                                  _locationDenied = true;
                                                                                });
                                                                              }
                                                                            }
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              media.width * 0.1,
                                                                          width:
                                                                              media.width * 0.1,
                                                                          decoration: BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(blurRadius: 2, color: textColor.withOpacity(0.2), spreadRadius: 2)
                                                                              ],
                                                                              color: page,
                                                                              borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Icon(
                                                                            Icons.my_location_sharp,
                                                                            size:
                                                                                media.width * 0.06,
                                                                            color:
                                                                                textColor,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.25),
                                                                (driverReq
                                                                        .isNotEmpty)
                                                                    ? (driverReq['accepted_at'] ==
                                                                            null)
                                                                        ? Column(
                                                                            children: [
                                                                              (driverReq['is_later'] == 1 && driverReq['is_rental'] != true)
                                                                                  ? Container(
                                                                                      alignment: Alignment.center,
                                                                                      margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                                                      padding: EdgeInsets.all(media.width * 0.025),
                                                                                      decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                                                      width: media.width * 0.9,
                                                                                      child: Text(
                                                                                        languages[choosenLanguage]['text_rideLaterTime'] + " " + driverReq['cv_trip_start_time'],
                                                                                        style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: (isDarkTheme == true) ? Colors.black : topBar),
                                                                                      ),
                                                                                    )
                                                                                  : (driverReq['is_rental'] == true && driverReq['is_later'] != 1)
                                                                                      ? Container(
                                                                                          alignment: Alignment.center,
                                                                                          margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                                                          padding: EdgeInsets.all(media.width * 0.025),
                                                                                          decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                                                          width: media.width * 0.9,
                                                                                          child: Text(
                                                                                            languages[choosenLanguage]['text_rental_ride'] + ' - ' + driverReq['rental_package_name'],
                                                                                            style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: (isDarkTheme == true) ? Colors.black : topBar),
                                                                                          ),
                                                                                        )
                                                                                      : (driverReq['is_rental'] == true && driverReq['is_later'] == 1)
                                                                                          ? Container(
                                                                                              alignment: Alignment.center,
                                                                                              margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                                                              padding: EdgeInsets.all(media.width * 0.025),
                                                                                              decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                                                              width: media.width * 0.9,
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Text(
                                                                                                    languages[choosenLanguage]['text_rideLaterTime'] + " " + driverReq['cv_trip_start_time'],
                                                                                                    style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: (isDarkTheme == true) ? Colors.black : topBar),
                                                                                                  ),
                                                                                                  SizedBox(height: media.width * 0.02),
                                                                                                  Text(
                                                                                                    languages[choosenLanguage]['text_rental_ride'] + ' - ' + driverReq['rental_package_name'],
                                                                                                    style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: (isDarkTheme == true) ? Colors.black : topBar),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            )
                                                                                          : Container(),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    if (bottom == 0) {
                                                                                      bottom = 1;
                                                                                    } else {
                                                                                      bottom = 0;
                                                                                    }
                                                                                  });
                                                                                },
                                                                                child:
                                                                                    Container(
                                                                                        padding: const EdgeInsets.fromLTRB(0, 0, 0,
                                                                                            0),
                                                                                        width: media.width *
                                                                                            0.9,
                                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: page, boxShadow: [
                                                                                          BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2)
                                                                                        ]),
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            (duration != 0)
                                                                                                ? AnimatedContainer(
                                                                                                    duration: const Duration(milliseconds: 100),
                                                                                                    height: 10,
                                                                                                    width: (media.width * 0.9 / double.parse(userDetails['trip_accept_reject_duration_for_driver'].toString())) * (double.parse(userDetails['trip_accept_reject_duration_for_driver'].toString()) - duration),
                                                                                                    decoration: BoxDecoration(
                                                                                                        color: Colors.green,
                                                                                                        borderRadius: (languageDirection == 'ltr')
                                                                                                            ? BorderRadius.only(
                                                                                                                topLeft: const Radius.circular(100),
                                                                                                                topRight: (duration <= 2.0) ? const Radius.circular(100) : const Radius.circular(0),
                                                                                                              )
                                                                                                            : BorderRadius.only(
                                                                                                                topRight: const Radius.circular(100),
                                                                                                                topLeft: (duration <= 2.0) ? const Radius.circular(100) : const Radius.circular(0),
                                                                                                              )),
                                                                                                  )
                                                                                                : Container(),
                                                                                            Container(
                                                                                              padding: EdgeInsets.fromLTRB(media.width * 0.05, media.width * 0.02, media.width * 0.05, media.width * 0.05),
                                                                                              child: Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        height: media.width * 0.25,
                                                                                                        width: media.width * 0.25,
                                                                                                        decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(driverReq['userDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                                                      ),
                                                                                                      SizedBox(width: media.width * 0.05),
                                                                                                      Expanded(
                                                                                                        child: SizedBox(
                                                                                                          height: media.width * 0.2,
                                                                                                          child: Column(
                                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                            children: [
                                                                                                              Text(
                                                                                                                driverReq['userDetail']['data']['name'],
                                                                                                                style: GoogleFonts.roboto(fontSize: media.width * eighteen, color: textColor),
                                                                                                              ),
                                                                                                              (driverReq['drop_address'] == null && driverReq['is_rental'] == false)
                                                                                                                  ? Container()
                                                                                                                  : Row(
                                                                                                                      children: [
                                                                                                                        //payment image
                                                                                                                        SizedBox(
                                                                                                                          width: media.width * 0.06,
                                                                                                                          child: (driverReq['payment_opt'].toString() == '1')
                                                                                                                              ? Image.asset(
                                                                                                                                  'assets/images/cash.png',
                                                                                                                                  fit: BoxFit.contain,
                                                                                                                                )
                                                                                                                              : (driverReq['payment_opt'].toString() == '2')
                                                                                                                                  ? Image.asset('assets/images/wallet.png', fit: BoxFit.contain, color: textColor)
                                                                                                                                  : (driverReq['payment_opt'].toString() == '0')
                                                                                                                                      ? Image.asset('assets/images/card.png', fit: BoxFit.contain, color: textColor)
                                                                                                                                      : Container(),
                                                                                                                        ),
                                                                                                                        SizedBox(
                                                                                                                          width: media.width * 0.03,
                                                                                                                        ),
                                                                                                                        Text(
                                                                                                                          driverReq['payment_type_string'].toString(),
                                                                                                                          style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: textColor),
                                                                                                                        ),
                                                                                                                        SizedBox(width: media.width * 0.03),
                                                                                                                        (driverReq['show_request_eta_amount'] == true && driverReq['request_eta_amount'] != null)
                                                                                                                            ? SizedBox(
                                                                                                                                width: media.width * 0.2,
                                                                                                                                child: FittedBox(
                                                                                                                                  child: Text(
                                                                                                                                    driverReq['requested_currency_symbol'] + driverReq['request_eta_amount'].toStringAsFixed(2),
                                                                                                                                    style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor),
                                                                                                                                  ),
                                                                                                                                ),
                                                                                                                              )
                                                                                                                            : Container()
                                                                                                                      ],
                                                                                                                    ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      FittedBox(
                                                                                                        child: Text(
                                                                                                          (duration != 0) ? duration.toString().split('.')[0] : '',
                                                                                                          style: GoogleFonts.roboto(fontSize: media.width * twenty, fontWeight: FontWeight.bold, color: textColor),
                                                                                                          textAlign: TextAlign.end,
                                                                                                        ),
                                                                                                      )
                                                                                                    ],
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: media.width * 0.02,
                                                                                                  ),
                                                                                                  Text(
                                                                                                    languages[choosenLanguage]['text_pickpoint'],
                                                                                                    style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor, fontWeight: FontWeight.bold),
                                                                                                  ),
                                                                                                  SizedBox(height: media.width * 0.02),
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      Image.asset(
                                                                                                        'assets/images/picklocation.png',
                                                                                                        width: media.width * 0.075,
                                                                                                      ),
                                                                                                      SizedBox(width: media.width * 0.05),
                                                                                                      Expanded(
                                                                                                        child: Text(
                                                                                                          driverReq['pick_address'],
                                                                                                          style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor),
                                                                                                          maxLines: (bottom == 1) ? 4 : 1,
                                                                                                        ),
                                                                                                      )
                                                                                                    ],
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: media.width * 0.02,
                                                                                                  ),
                                                                                                  (driverReq['is_rental'] != true && driverReq['drop_address'] != null) ? Text(languages[choosenLanguage]['text_droppoint'], style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor, fontWeight: FontWeight.bold)) : Container(),
                                                                                                  (tripStops.isNotEmpty)
                                                                                                      ? Column(
                                                                                                          children: tripStops
                                                                                                              .asMap()
                                                                                                              .map((i, value) {
                                                                                                                return MapEntry(
                                                                                                                    i,
                                                                                                                    (i < tripStops.length - 1)
                                                                                                                        ? Container(
                                                                                                                            padding: EdgeInsets.only(top: media.width * 0.025),
                                                                                                                            child: Row(
                                                                                                                              children: [
                                                                                                                                Icon(
                                                                                                                                  Icons.location_on_outlined,
                                                                                                                                  size: media.width * 0.075,
                                                                                                                                  color: Colors.red,
                                                                                                                                ),
                                                                                                                                SizedBox(width: media.width * 0.05),
                                                                                                                                Expanded(
                                                                                                                                  child: Text(
                                                                                                                                    tripStops[i]['address'],
                                                                                                                                    style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor),
                                                                                                                                    maxLines: (bottom == 1) ? 4 : 1,
                                                                                                                                  ),
                                                                                                                                )
                                                                                                                              ],
                                                                                                                            ),
                                                                                                                          )
                                                                                                                        : Container());
                                                                                                              })
                                                                                                              .values
                                                                                                              .toList(),
                                                                                                        )
                                                                                                      : Container(),
                                                                                                  SizedBox(
                                                                                                    height: media.width * 0.025,
                                                                                                  ),
                                                                                                  (driverReq['is_rental'] != true && driverReq['drop_address'] != null)
                                                                                                      ? Row(
                                                                                                          children: [
                                                                                                            Icon(
                                                                                                              Icons.location_on_outlined,
                                                                                                              size: media.width * 0.075,
                                                                                                              color: Colors.red,
                                                                                                            ),
                                                                                                            SizedBox(width: media.width * 0.05),
                                                                                                            Expanded(
                                                                                                              child: Text(
                                                                                                                driverReq['drop_address'],
                                                                                                                style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor),
                                                                                                                maxLines: (bottom == 1) ? 4 : 1,
                                                                                                              ),
                                                                                                            )
                                                                                                          ],
                                                                                                        )
                                                                                                      : Container(),
                                                                                                  SizedBox(
                                                                                                    height: media.width * 0.04,
                                                                                                  ),
                                                                                                  Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                    children: [
                                                                                                      Button(
                                                                                                          borcolor: buttonColor,
                                                                                                          textcolor: buttonColor,
                                                                                                          width: media.width * 0.38,
                                                                                                          color: page,
                                                                                                          onTap: () async {
                                                                                                            setState(() {
                                                                                                              _isLoading = true;
                                                                                                            });
                                                                                                            //reject request
                                                                                                            var val = await requestReject();
                                                                                                            if (val == 'logout') {
                                                                                                              navigateLogout();
                                                                                                            }
                                                                                                            setState(() {
                                                                                                              _isLoading = false;
                                                                                                            });
                                                                                                          },
                                                                                                          text: languages[choosenLanguage]['text_decline']),
                                                                                                      Button(
                                                                                                        onTap: () async {
                                                                                                          setState(() {
                                                                                                            _isLoading = true;
                                                                                                          });
                                                                                                          var val = await requestAccept();
                                                                                                          if (val == 'logout') {
                                                                                                            navigateLogout();
                                                                                                          }
                                                                                                          setState(() {
                                                                                                            _isLoading = false;
                                                                                                          });
                                                                                                        },
                                                                                                        text: languages[choosenLanguage]['text_accept'],
                                                                                                        width: media.width * 0.38,
                                                                                                      )
                                                                                                    ],
                                                                                                  )
                                                                                                ],
                                                                                              ),
                                                                                            )
                                                                                          ],
                                                                                        )),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : (driverReq['accepted_at'] !=
                                                                                null)
                                                                            ? SizedBox(
                                                                                width: media.width * 0.9,
                                                                                height: media.width * 0.7,
                                                                              )
                                                                            : Container(width: media.width * 0.9)
                                                                    : Container(
                                                                        width: media.width *
                                                                            0.9,
                                                                      ),
                                                              ],
                                                            )),

                                                        //on ride bottom sheet
                                                        (driverReq['accepted_at'] !=
                                                                null)
                                                            ? Positioned(
                                                                bottom: 0,
                                                                child:
                                                                    GestureDetector(
                                                                  onVerticalDragStart:
                                                                      (v) {
                                                                    start = v
                                                                        .globalPosition
                                                                        .dy;
                                                                    gesture
                                                                        .clear();
                                                                  },
                                                                  onVerticalDragUpdate:
                                                                      (v) {
                                                                    gesture.add(v
                                                                        .globalPosition
                                                                        .dy);
                                                                  },
                                                                  onVerticalDragEnd:
                                                                      (v) {
                                                                    if (gesture
                                                                            .isNotEmpty &&
                                                                        start >
                                                                            gesture[gesture.length -
                                                                                1] &&
                                                                        _bottom ==
                                                                            0) {
                                                                      setState(
                                                                          () {
                                                                        _bottom =
                                                                            1;
                                                                      });
                                                                    } else if (gesture
                                                                            .isNotEmpty &&
                                                                        start <
                                                                            gesture[gesture.length -
                                                                                1] &&
                                                                        _bottom ==
                                                                            1) {
                                                                      setState(
                                                                          () {
                                                                        _bottom =
                                                                            0;
                                                                      });
                                                                    }
                                                                  },
                                                                  child:
                                                                      AnimatedContainer(
                                                                    duration: const Duration(
                                                                        milliseconds:
                                                                            200),
                                                                    padding: EdgeInsets.all(
                                                                        media.width *
                                                                            0.05),
                                                                    width: media
                                                                            .width *
                                                                        1,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: const BorderRadius
                                                                            .only(
                                                                            topLeft: Radius.circular(
                                                                                10),
                                                                            topRight: Radius.circular(
                                                                                10)),
                                                                        color:
                                                                            page),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.02,
                                                                          width:
                                                                              media.width * 0.2,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(media.width * 0.01),
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              media.width * 0.025,
                                                                        ),
                                                                        Column(
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Container(
                                                                                    height: media.width * 0.25,
                                                                                    width: media.width * 0.25,
                                                                                    decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(driverReq['userDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                                  ),
                                                                                  SizedBox(width: media.width * 0.05),
                                                                                  SizedBox(
                                                                                    width: media.width * 0.3,
                                                                                    height: media.width * 0.2,
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                      children: [
                                                                                        SizedBox(
                                                                                          width: media.width * 0.3,
                                                                                          child: Text(
                                                                                            driverReq['userDetail']['data']['name'],
                                                                                            style: GoogleFonts.roboto(fontSize: media.width * eighteen, color: textColor),
                                                                                            maxLines: 1,
                                                                                          ),
                                                                                        ),
                                                                                        Row(
                                                                                          children: [
                                                                                            Icon(
                                                                                              Icons.star,
                                                                                              color: buttonColor,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: media.width * 0.01,
                                                                                            ),
                                                                                            Text(
                                                                                              driverReq['userDetail']['data']['rating'].toString(),
                                                                                              style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: textColor),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        (driverReq['accepted_at'] == null && driverReq['show_request_eta_amount'] == true && driverReq['request_eta_amount'] != null)
                                                                                            ? Text(
                                                                                                driverReq['requested_currency_symbol'] + driverReq['request_eta_amount'].toString(),
                                                                                                style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor),
                                                                                              )
                                                                                            : (driverReq['is_driver_arrived'] == 1 && waitingTime != null)
                                                                                                ? (waitingTime / 60 >= 1)
                                                                                                    ? Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                        children: [
                                                                                                          Row(
                                                                                                            children: [
                                                                                                              Container(
                                                                                                                width: media.width * 0.25,
                                                                                                                alignment: Alignment.center,
                                                                                                                child: Text(
                                                                                                                  languages[choosenLanguage]['text_waiting_time'],
                                                                                                                  style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: buttonColor),
                                                                                                                ),
                                                                                                              ),
                                                                                                              SizedBox(
                                                                                                                width: media.width * 0.01,
                                                                                                              ),
                                                                                                              InkWell(
                                                                                                                onTap: () {
                                                                                                                  setState(() {
                                                                                                                    _showWaitingInfo = true;
                                                                                                                  });
                                                                                                                },
                                                                                                                child: Icon(Icons.info_outline, size: media.width * 0.04, color: textColor),
                                                                                                              )
                                                                                                            ],
                                                                                                          ),
                                                                                                          SizedBox(
                                                                                                            height: media.width * 0.02,
                                                                                                          ),
                                                                                                          Container(
                                                                                                            width: media.width * 0.3,
                                                                                                            alignment: Alignment.center,
                                                                                                            child: Text(
                                                                                                              '${(waitingTime / 60).toInt()} mins',
                                                                                                              style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      )
                                                                                                    : Container()
                                                                                                : Container(),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: media.width * 0.05,
                                                                              ),
                                                                              (_bottom != 0)
                                                                                  ? AnimatedContainer(
                                                                                      duration: const Duration(milliseconds: 200),
                                                                                      height: media.height * 0.4,
                                                                                      child: SingleChildScrollView(
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text(
                                                                                              languages[choosenLanguage]['text_pickpoint'],
                                                                                              style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            SizedBox(height: media.width * 0.02),
                                                                                            Row(
                                                                                              children: [
                                                                                                Container(
                                                                                                  height: media.width * 0.05,
                                                                                                  width: media.width * 0.05,
                                                                                                  alignment: Alignment.center,
                                                                                                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xff319900).withOpacity(0.3)),
                                                                                                  child: Container(
                                                                                                    height: media.width * 0.02,
                                                                                                    width: media.width * 0.02,
                                                                                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff319900)),
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(width: media.width * 0.05),
                                                                                                Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    SizedBox(
                                                                                                      width: media.width * 0.6,
                                                                                                      child: Text(
                                                                                                        driverReq['pick_address'],
                                                                                                        style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: media.width * 0.02,
                                                                                            ),
                                                                                            (driverReq['drop_address'] != null) ? Text(languages[choosenLanguage]['text_droppoint'], style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold)) : Container(),
                                                                                            (tripStops.isNotEmpty)
                                                                                                ? Column(
                                                                                                    children: tripStops
                                                                                                        .asMap()
                                                                                                        .map((i, value) {
                                                                                                          return MapEntry(
                                                                                                              i,
                                                                                                              (i < tripStops.length - 1)
                                                                                                                  ? Container(
                                                                                                                      padding: EdgeInsets.only(top: media.width * 0.04),
                                                                                                                      child: Row(
                                                                                                                        children: [
                                                                                                                          Container(
                                                                                                                            height: media.width * 0.05,
                                                                                                                            width: media.width * 0.05,
                                                                                                                            alignment: Alignment.center,
                                                                                                                            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xffFF0000).withOpacity(0.3)),
                                                                                                                            child: Container(
                                                                                                                              height: media.width * 0.02,
                                                                                                                              width: media.width * 0.02,
                                                                                                                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffFF0000)),
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                          SizedBox(width: media.width * 0.05),
                                                                                                                          Expanded(
                                                                                                                            // width: media.width * 0.6,
                                                                                                                            child: Text(
                                                                                                                              tripStops[i]['address'],
                                                                                                                              style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor),
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ],
                                                                                                                      ),
                                                                                                                    )
                                                                                                                  : Container());
                                                                                                        })
                                                                                                        .values
                                                                                                        .toList(),
                                                                                                  )
                                                                                                : Container(),
                                                                                            SizedBox(height: media.width * 0.05),
                                                                                            (driverReq['is_rental'] != true && driverReq['drop_address'] != null)
                                                                                                ? Row(
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        height: media.width * 0.05,
                                                                                                        width: media.width * 0.05,
                                                                                                        alignment: Alignment.center,
                                                                                                        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xffFF0000).withOpacity(0.3)),
                                                                                                        child: Container(
                                                                                                          height: media.width * 0.02,
                                                                                                          width: media.width * 0.02,
                                                                                                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffFF0000)),
                                                                                                        ),
                                                                                                      ),
                                                                                                      SizedBox(width: media.width * 0.05),
                                                                                                      Column(
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: [
                                                                                                          (tripStops.isEmpty)
                                                                                                              ? SizedBox(
                                                                                                                  height: media.width * 0.02,
                                                                                                                )
                                                                                                              : Container(),
                                                                                                          SizedBox(
                                                                                                            width: media.width * 0.6,
                                                                                                            child: Text(
                                                                                                              driverReq['drop_address'],
                                                                                                              style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      )
                                                                                                    ],
                                                                                                  )
                                                                                                : Container(),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                  : Container(),
                                                                            ]),
                                                                        (driverReq['is_trip_start'] ==
                                                                                0)
                                                                            ? Column(
                                                                                children: [
                                                                                  (_bottom == 0)
                                                                                      ? Row(
                                                                                          children: [
                                                                                            Icon(Icons.location_on_outlined, color: Colors.red, size: media.width * 0.075),
                                                                                            SizedBox(width: media.width * 0.05),
                                                                                            Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Text(languages[choosenLanguage]['text_pickpoint'], style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor.withOpacity(0.7))),
                                                                                                SizedBox(
                                                                                                  height: media.width * 0.02,
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: media.width * 0.6,
                                                                                                  child: Text(
                                                                                                    driverReq['pick_address'],
                                                                                                    style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor),
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  height: media.width * 0.02,
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          ],
                                                                                        )
                                                                                      : Container(),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                    children: [
                                                                                      Column(
                                                                                        children: [
                                                                                          InkWell(
                                                                                              onTap: () {
                                                                                                makingPhoneCall(driverReq['userDetail']['data']['mobile']);
                                                                                              },
                                                                                              child: Image.asset(
                                                                                                'assets/images/Call.png',
                                                                                                width: media.width * 0.06,
                                                                                                color: textColor,
                                                                                              )),
                                                                                          Text(
                                                                                            languages[choosenLanguage]['text_call'],
                                                                                            style: GoogleFonts.roboto(
                                                                                              fontSize: media.width * twelve,
                                                                                              color: textColor,
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                      (driverReq['if_dispatch'] == true)
                                                                                          ? Container()
                                                                                          : InkWell(
                                                                                              onTap: () {
                                                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
                                                                                              },
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      Image.asset(
                                                                                                        'assets/images/message-square.png',
                                                                                                        width: media.width * 0.06,
                                                                                                        color: textColor,
                                                                                                      ),
                                                                                                      (chatList.where((element) => element['from_type'] == 1 && element['seen'] == 0).isNotEmpty)
                                                                                                          ? Text(
                                                                                                              chatList.where((element) => element['from_type'] == 1 && element['seen'] == 0).length.toString(),
                                                                                                              style: GoogleFonts.roboto(fontSize: media.width * twelve, color: const Color(0xffFF0000)),
                                                                                                            )
                                                                                                          : Container()
                                                                                                    ],
                                                                                                  ),
                                                                                                  Text(
                                                                                                    languages[choosenLanguage]['text_chat'],
                                                                                                    style: GoogleFonts.roboto(
                                                                                                      fontSize: media.width * twelve,
                                                                                                      color: textColor,
                                                                                                    ),
                                                                                                  )
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                      Column(
                                                                                        children: [
                                                                                          InkWell(
                                                                                            onTap: () async {
                                                                                              setState(() {
                                                                                                _isLoading = true;
                                                                                              });
                                                                                              var val = await cancelReason((driverReq['is_driver_arrived'] == 0) ? 'before' : 'after');
                                                                                              if (val == true) {
                                                                                                setState(() {
                                                                                                  cancelRequest = true;
                                                                                                  _cancelReason = '';
                                                                                                  _cancellingError = '';
                                                                                                });
                                                                                              } else if (val == 'logout') {
                                                                                                navigateLogout();
                                                                                              }
                                                                                              setState(() {
                                                                                                _isLoading = false;
                                                                                              });
                                                                                            },
                                                                                            child: Image.asset(
                                                                                              'assets/images/cancel.png',
                                                                                              width: media.width * 0.06,
                                                                                              color: textColor,
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            languages[choosenLanguage]['text_cancel'],
                                                                                            style: GoogleFonts.roboto(
                                                                                              fontSize: media.width * twelve,
                                                                                              color: textColor,
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : (_bottom == 0 && driverReq['is_trip_start'] == 1 && driverReq['is_rental'] != true && driverReq['drop_address'] != null)
                                                                                ? Row(
                                                                                    children: [
                                                                                      Icon(Icons.location_on_outlined, color: Colors.red, size: media.width * 0.075),
                                                                                      SizedBox(width: media.width * 0.05),
                                                                                      Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(languages[choosenLanguage]['text_droppoint'], style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor.withOpacity(0.7))),
                                                                                          SizedBox(
                                                                                            height: media.width * 0.02,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: media.width * 0.6,
                                                                                            child: Text(
                                                                                              driverReq['drop_address'],
                                                                                              style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  )
                                                                                : Container(),
                                                                        SizedBox(
                                                                          height:
                                                                              media.width * 0.05,
                                                                        ),
                                                                        Button(
                                                                            onTap:
                                                                                () async {
                                                                              setState(() {
                                                                                _isLoading = true;
                                                                              });
                                                                              if ((driverReq['is_driver_arrived'] == 0)) {
                                                                                var val = await driverArrived();
                                                                                if (val == 'logout') {
                                                                                  navigateLogout();
                                                                                }
                                                                              } else if (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0) {
                                                                                if (driverReq['show_otp_feature'] == true) {
                                                                                  setState(() {
                                                                                    getStartOtp = true;
                                                                                  });
                                                                                } else {
                                                                                  var val = await tripStartDispatcher();
                                                                                  if (val == 'logout') {
                                                                                    navigateLogout();
                                                                                  }
                                                                                }
                                                                              } else {
                                                                                driverOtp = '';
                                                                                var val = await endTrip();
                                                                                if (val == 'logout') {
                                                                                  navigateLogout();
                                                                                }
                                                                              }

                                                                              _isLoading = false;
                                                                            },
                                                                            text: (driverReq['is_driver_arrived'] == 0)
                                                                                ? languages[choosenLanguage]['text_arrived']
                                                                                : (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0)
                                                                                    ? languages[choosenLanguage]['text_startride']
                                                                                    : languages[choosenLanguage]['text_endtrip'])
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ))
                                                            : Container(),
                                                        if (driverReq.isEmpty)
                                                          Positioned(
                                                            right: 10,
                                                            top: MediaQuery.of(
                                                                        context)
                                                                    .padding
                                                                    .top +
                                                                12.5 +
                                                                media.width *
                                                                    0.16,
                                                            child: InkWell(
                                                              onTap: () async {
                                                                if (contactus ==
                                                                    false) {
                                                                  setState(() {
                                                                    contactus =
                                                                        true;
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    contactus =
                                                                        false;
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                height: media
                                                                        .width *
                                                                    0.1,
                                                                width: media
                                                                        .width *
                                                                    0.1,
                                                                decoration: BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          blurRadius:
                                                                              2,
                                                                          color: textColor.withOpacity(
                                                                              0.2),
                                                                          spreadRadius:
                                                                              2)
                                                                    ],
                                                                    color: page,
                                                                    borderRadius:
                                                                        BorderRadius.circular(media.width *
                                                                            0.02)),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    Image.asset(
                                                                  'assets/images/customercare.png',
                                                                  fit: BoxFit
                                                                      .contain,
                                                                  width: media
                                                                          .width *
                                                                      0.06,
                                                                  color:
                                                                      textColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        (contactus == true)
                                                            ? Positioned(
                                                                right: 10,
                                                                top: MediaQuery.of(
                                                                            context)
                                                                        .padding
                                                                        .top +
                                                                    12.5 +
                                                                    media.width *
                                                                        0.27,
                                                                child: InkWell(
                                                                  onTap:
                                                                      () async {},
                                                                  child:
                                                                      Container(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              10),
                                                                          height: media.width *
                                                                              0.3,
                                                                          width: media.width *
                                                                              0.45,
                                                                          decoration: BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2)
                                                                              ],
                                                                              color:
                                                                                  page,
                                                                              borderRadius: BorderRadius.circular(media.width *
                                                                                  0.02)),
                                                                          alignment: Alignment
                                                                              .center,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  makingPhoneCall(userDetails['contact_us_mobile1']);
                                                                                },
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(flex: 20, child: Icon(Icons.call, color: textColor)),
                                                                                    Expanded(
                                                                                        flex: 80,
                                                                                        child: Text(
                                                                                          userDetails['contact_us_mobile1'],
                                                                                          style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor),
                                                                                        ))
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  makingPhoneCall(userDetails['contact_us_mobile1']);
                                                                                },
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(flex: 20, child: Icon(Icons.call, color: textColor)),
                                                                                    Expanded(
                                                                                        flex: 80,
                                                                                        child: Text(
                                                                                          userDetails['contact_us_mobile2'],
                                                                                          style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor),
                                                                                        ))
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  openBrowser(userDetails['contact_us_link'].toString());
                                                                                },
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(flex: 20, child: Icon(Icons.vpn_lock_rounded, color: textColor)),
                                                                                    Expanded(
                                                                                        flex: 80,
                                                                                        child: Text(
                                                                                          'Goto URL',
                                                                                          maxLines: 1,
                                                                                          // overflow:
                                                                                          //     TextOverflow.ellipsis,
                                                                                          style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor),
                                                                                        ))
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            ],
                                                                          )),
                                                                ),
                                                              )
                                                            : Container(),
                                                        //user cancelled request popup
                                                        (_reqCancelled == true)
                                                            ? Positioned(
                                                                bottom: media
                                                                        .height *
                                                                    0.5,
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .all(media
                                                                              .width *
                                                                          0.05),
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(10),
                                                                      color: page,
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            color: Colors.black.withOpacity(
                                                                                0.2),
                                                                            blurRadius:
                                                                                2,
                                                                            spreadRadius:
                                                                                2)
                                                                      ]),
                                                                  child: Text(languages[
                                                                          choosenLanguage]
                                                                      [
                                                                      'text_user_cancelled_request']),
                                                                ))
                                                            : Container(),
                                                      ],
                                                    )
                                                  : Container(),
                                    ]),
                              ),
                              (_locationDenied == true)
                                  ? Positioned(
                                      child: Container(
                                      height: media.height * 1,
                                      width: media.width * 1,
                                      color:
                                          Colors.transparent.withOpacity(0.6),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: media.width * 0.9,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _locationDenied = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    height: media.height * 0.05,
                                                    width: media.height * 0.05,
                                                    decoration: BoxDecoration(
                                                      color: page,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.cancel,
                                                        color: buttonColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: media.width * 0.025),
                                          Container(
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            width: media.width * 0.9,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: page,
                                                boxShadow: [
                                                  BoxShadow(
                                                      blurRadius: 2.0,
                                                      spreadRadius: 2.0,
                                                      color: Colors.black
                                                          .withOpacity(0.2))
                                                ]),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                    width: media.width * 0.8,
                                                    child: Text(
                                                      languages[choosenLanguage]
                                                          [
                                                          'text_open_loc_settings'],
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  sixteen,
                                                          color: textColor,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    )),
                                                SizedBox(
                                                    height: media.width * 0.05),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
                                                        onTap: () async {
                                                          await perm
                                                              .openAppSettings();
                                                        },
                                                        child: Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_open_settings'],
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color:
                                                                  buttonColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )),
                                                    InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            _locationDenied =
                                                                false;
                                                            _isLoading = true;
                                                          });

                                                          getLocs();
                                                        },
                                                        child: Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              ['text_done'],
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color:
                                                                  buttonColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
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
                              //enter otp
                              (getStartOtp == true && driverReq.isNotEmpty)
                                  ? Positioned(
                                      top: 0,
                                      child: Container(
                                        height: media.height * 1,
                                        width: media.width * 1,
                                        // color:
                                        //     Colors.transparent.withOpacity(0.5),
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.2)
                                            : Colors.transparent
                                                .withOpacity(0.6),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: media.width * 0.8,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        getStartOtp = false;
                                                      });
                                                    },
                                                    child: Container(
                                                      height:
                                                          media.height * 0.05,
                                                      width:
                                                          media.height * 0.05,
                                                      decoration: BoxDecoration(
                                                        color: page,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(Icons.cancel,
                                                          color: buttonColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height: media.width * 0.025),
                                            Container(
                                              padding: EdgeInsets.all(
                                                  media.width * 0.05),
                                              width: media.width * 0.8,
                                              height: media.width * 0.7,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: page,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        spreadRadius: 2,
                                                        blurRadius: 2)
                                                  ]),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    languages[choosenLanguage]
                                                        ['text_driver_otp'],
                                                    style: GoogleFonts.roboto(
                                                        fontSize: media.width *
                                                            eighteen,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textColor),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          media.width * 0.05),
                                                  Text(
                                                    languages[choosenLanguage]
                                                        ['text_enterdriverotp'],
                                                    style: GoogleFonts.roboto(
                                                      fontSize:
                                                          media.width * twelve,
                                                      color: textColor
                                                          .withOpacity(0.7),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.05,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width:
                                                            media.width * 0.12,
                                                        color: page,
                                                        child: TextFormField(
                                                          onChanged: (val) {
                                                            if (val.length ==
                                                                1) {
                                                              setState(() {
                                                                _otp1 = val;
                                                                driverOtp =
                                                                    _otp1 +
                                                                        _otp2 +
                                                                        _otp3 +
                                                                        _otp4;
                                                                FocusScope.of(
                                                                        context)
                                                                    .nextFocus();
                                                              });
                                                            }
                                                          },
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          maxLength: 1,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              counterText: '',
                                                              border: const UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .white,
                                                                      width:
                                                                          1.5,
                                                                      style: BorderStyle
                                                                          .solid)),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: (isDarkTheme ==
                                                                              true)
                                                                          ? Colors
                                                                              .white
                                                                          : hintColor))),
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  color:
                                                                      textColor),
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width:
                                                            media.width * 0.12,
                                                        color: page,
                                                        child: TextFormField(
                                                          onChanged: (val) {
                                                            if (val.length ==
                                                                1) {
                                                              setState(() {
                                                                _otp2 = val;
                                                                driverOtp =
                                                                    _otp1 +
                                                                        _otp2 +
                                                                        _otp3 +
                                                                        _otp4;
                                                                FocusScope.of(
                                                                        context)
                                                                    .nextFocus();
                                                              });
                                                            } else {
                                                              setState(() {
                                                                FocusScope.of(
                                                                        context)
                                                                    .previousFocus();
                                                              });
                                                            }
                                                          },
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          maxLength: 1,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              counterText: '',
                                                              border: const UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          1.5,
                                                                      style: BorderStyle
                                                                          .solid)),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: (isDarkTheme ==
                                                                              true)
                                                                          ? Colors
                                                                              .white
                                                                          : hintColor))),
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  color:
                                                                      textColor),
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width:
                                                            media.width * 0.12,
                                                        color: page,
                                                        child: TextFormField(
                                                          onChanged: (val) {
                                                            if (val.length ==
                                                                1) {
                                                              setState(() {
                                                                _otp3 = val;
                                                                driverOtp =
                                                                    _otp1 +
                                                                        _otp2 +
                                                                        _otp3 +
                                                                        _otp4;
                                                                FocusScope.of(
                                                                        context)
                                                                    .nextFocus();
                                                              });
                                                            } else {
                                                              setState(() {
                                                                FocusScope.of(
                                                                        context)
                                                                    .previousFocus();
                                                              });
                                                            }
                                                          },
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          maxLength: 1,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              counterText: '',
                                                              border: const UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          1.5,
                                                                      style: BorderStyle
                                                                          .solid)),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: (isDarkTheme ==
                                                                              true)
                                                                          ? Colors
                                                                              .white
                                                                          : hintColor))),
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  color:
                                                                      textColor),
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width:
                                                            media.width * 0.12,
                                                        color: page,
                                                        child: TextFormField(
                                                          onChanged: (val) {
                                                            if (val.length ==
                                                                1) {
                                                              setState(() {
                                                                _otp4 = val;
                                                                driverOtp =
                                                                    _otp1 +
                                                                        _otp2 +
                                                                        _otp3 +
                                                                        _otp4;
                                                                FocusScope.of(
                                                                        context)
                                                                    .nextFocus();
                                                              });
                                                            } else {
                                                              setState(() {
                                                                FocusScope.of(
                                                                        context)
                                                                    .previousFocus();
                                                              });
                                                            }
                                                          },
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          maxLength: 1,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration: InputDecoration(
                                                              counterText: '',
                                                              border: const UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          1.5,
                                                                      style: BorderStyle
                                                                          .solid)),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: (isDarkTheme ==
                                                                              true)
                                                                          ? Colors
                                                                              .white
                                                                          : hintColor))),
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  color:
                                                                      textColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.04,
                                                  ),
                                                  (_errorOtp == true)
                                                      ? Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_error_trip_otp'],
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve),
                                                        )
                                                      : Container(),
                                                  SizedBox(
                                                      height:
                                                          media.width * 0.02),
                                                  Button(
                                                    onTap: () async {
                                                      if (driverOtp.length !=
                                                          4) {
                                                        setState(() {});
                                                      } else {
                                                        setState(() {
                                                          _errorOtp = false;
                                                          _isLoading = true;
                                                        });
                                                        var val =
                                                            await tripStart();
                                                        if (val == 'logout') {
                                                          navigateLogout();
                                                        } else if (val !=
                                                            'success') {
                                                          setState(() {
                                                            _errorOtp = true;
                                                            _isLoading = false;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            _isLoading = false;
                                                            getStartOtp = false;
                                                          });
                                                        }
                                                      }
                                                    },
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_confirm'],
                                                    color:
                                                        (driverOtp.length != 4)
                                                            ? Colors.grey
                                                            : buttonColor,
                                                    borcolor:
                                                        (driverOtp.length != 4)
                                                            ? Colors.grey
                                                            : buttonColor,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),

                              //popup for cancel request
                              (cancelRequest == true && driverReq.isNotEmpty)
                                  ? Positioned(
                                      child: Container(
                                      height: media.height * 1,
                                      width: media.width * 1,
                                      // color:
                                      //     Colors.transparent.withOpacity(0.6),
                                      color: (isDarkTheme == true)
                                          ? textColor.withOpacity(0.2)
                                          : Colors.transparent.withOpacity(0.6),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            width: media.width * 0.9,
                                            decoration: BoxDecoration(
                                                color: page,
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Column(children: [
                                              Container(
                                                height: media.width * 0.18,
                                                width: media.width * 0.18,
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xffFEF2F2)),
                                                alignment: Alignment.center,
                                                child: Container(
                                                  height: media.width * 0.14,
                                                  width: media.width * 0.14,
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color(
                                                              0xffFF0000)),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.cancel_outlined,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: cancelReasonsList
                                                    .asMap()
                                                    .map((i, value) {
                                                      return MapEntry(
                                                          i,
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                _cancelReason =
                                                                    cancelReasonsList[
                                                                            i][
                                                                        'reason'];
                                                              });
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.01),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    height: media
                                                                            .height *
                                                                        0.05,
                                                                    width: media
                                                                            .width *
                                                                        0.05,
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Border.all(
                                                                            color:
                                                                                textColor,
                                                                            width:
                                                                                1.2)),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: (_cancelReason ==
                                                                            cancelReasonsList[i]['reason'])
                                                                        ? Container(
                                                                            height:
                                                                                media.width * 0.03,
                                                                            width:
                                                                                media.width * 0.03,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: textColor,
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.05,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.65,
                                                                    child: Text(
                                                                      cancelReasonsList[
                                                                              i]
                                                                          [
                                                                          'reason'],
                                                                      style: TextStyle(
                                                                          color:
                                                                              textColor),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ));
                                                    })
                                                    .values
                                                    .toList(),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _cancelReason = 'others';
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.01),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height:
                                                            media.height * 0.05,
                                                        width:
                                                            media.width * 0.05,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color:
                                                                    textColor,
                                                                width: 1.2)),
                                                        alignment:
                                                            Alignment.center,
                                                        child: (_cancelReason ==
                                                                'others')
                                                            ? Container(
                                                                height: media
                                                                        .width *
                                                                    0.03,
                                                                width: media
                                                                        .width *
                                                                    0.03,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color:
                                                                      textColor,
                                                                ),
                                                              )
                                                            : Container(),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.05,
                                                      ),
                                                      Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              ['text_others'],
                                                          style: TextStyle(
                                                              color: textColor))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              (_cancelReason == 'others')
                                                  ? Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0,
                                                              media.width *
                                                                  0.025,
                                                              0,
                                                              media.width *
                                                                  0.025),
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.05),
                                                      width: media.width * 0.9,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  borderLines,
                                                              width: 1.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12)),
                                                      child: TextField(
                                                        decoration: InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText: languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_cancelRideReason'],
                                                            hintStyle: GoogleFonts.roboto(
                                                                color: textColor
                                                                    .withOpacity(
                                                                        0.4),
                                                                fontSize: media
                                                                        .width *
                                                                    twelve)),
                                                        style: TextStyle(
                                                            color: textColor),
                                                        maxLines: 4,
                                                        minLines: 2,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            cancelReasonText =
                                                                val;
                                                          });
                                                        },
                                                      ),
                                                    )
                                                  : Container(),
                                              (_cancellingError != '')
                                                  ? Container(
                                                      padding: EdgeInsets.only(
                                                          top: media.width *
                                                              0.02,
                                                          bottom: media.width *
                                                              0.02),
                                                      width: media.width * 0.9,
                                                      child: Text(
                                                          _cancellingError,
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve,
                                                                  color: Colors
                                                                      .red)))
                                                  : Container(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Button(
                                                      color: page,
                                                      textcolor: buttonColor,
                                                      width: media.width * 0.39,
                                                      onTap: () async {
                                                        setState(() {
                                                          _isLoading = true;
                                                        });
                                                        if (_cancelReason !=
                                                            '') {
                                                          if (_cancelReason ==
                                                              'others') {
                                                            if (cancelReasonText !=
                                                                    '' &&
                                                                cancelReasonText
                                                                    .isNotEmpty) {
                                                              _cancellingError =
                                                                  '';
                                                              var val =
                                                                  await cancelRequestDriver(
                                                                      cancelReasonText);
                                                              if (val ==
                                                                  'logout') {
                                                                navigateLogout();
                                                              }
                                                              setState(() {
                                                                cancelRequest =
                                                                    false;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                _cancellingError =
                                                                    languages[
                                                                            choosenLanguage]
                                                                        [
                                                                        'text_add_cancel_reason'];
                                                              });
                                                            }
                                                          } else {
                                                            var val =
                                                                await cancelRequestDriver(
                                                                    _cancelReason);
                                                            if (val ==
                                                                'logout') {
                                                              navigateLogout();
                                                            }
                                                            setState(() {
                                                              cancelRequest =
                                                                  false;
                                                            });
                                                          }
                                                        }
                                                        setState(() {
                                                          _isLoading = false;
                                                        });
                                                      },
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['text_cancel']),
                                                  Button(
                                                      width: media.width * 0.39,
                                                      onTap: () {
                                                        setState(() {
                                                          cancelRequest = false;
                                                        });
                                                      },
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['tex_dontcancel'])
                                                ],
                                              )
                                            ]),
                                          ),
                                        ],
                                      ),
                                    ))
                                  : Container(),

                              //loader
                              (state == '')
                                  ? const Positioned(top: 0, child: Loading())
                                  : Container(),

                              //delete account
                              (deleteAccount == true)
                                  ? Positioned(
                                      top: 0,
                                      child: Container(
                                        height: media.height * 1,
                                        width: media.width * 1,
                                        // color:
                                        //     Colors.transparent.withOpacity(0.6),
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.2)
                                            : Colors.transparent
                                                .withOpacity(0.6),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: media.width * 0.9,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                      height:
                                                          media.height * 0.1,
                                                      width: media.width * 0.1,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: page),
                                                      child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              deleteAccount =
                                                                  false;
                                                            });
                                                          },
                                                          child: Icon(
                                                              Icons
                                                                  .cancel_outlined,
                                                              color:
                                                                  textColor))),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(
                                                  media.width * 0.05),
                                              width: media.width * 0.9,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: page),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    languages[choosenLanguage]
                                                        ['text_delete_confirm'],
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.roboto(
                                                        fontSize: media.width *
                                                            sixteen,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.05,
                                                  ),
                                                  Button(
                                                      onTap: () async {
                                                        setState(() {
                                                          deleteAccount = false;
                                                          _isLoading = true;
                                                        });
                                                        var result =
                                                            await userDelete();
                                                        if (result ==
                                                            'success') {
                                                          setState(() {
                                                            Navigator.pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const Login()),
                                                                (route) =>
                                                                    false);
                                                            userDetails.clear();
                                                          });
                                                        } else if (result ==
                                                            'logout') {
                                                          navigateLogout();
                                                        } else {
                                                          setState(() {
                                                            _isLoading = false;
                                                            deleteAccount =
                                                                true;
                                                          });
                                                        }
                                                        setState(() {
                                                          _isLoading = false;
                                                        });
                                                      },
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['text_confirm'])
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                  : Container(),

                              //logout popup
                              (logout == true)
                                  ? Positioned(
                                      top: 0,
                                      child: Container(
                                        height: media.height * 1,
                                        width: media.width * 1,
                                        // color:
                                        //     Colors.transparent.withOpacity(0.6),
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.2)
                                            : Colors.transparent
                                                .withOpacity(0.6),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: media.width * 0.9,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                      height:
                                                          media.height * 0.1,
                                                      width: media.width * 0.1,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: page),
                                                      child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              logout = false;
                                                            });
                                                          },
                                                          child: Icon(
                                                              Icons
                                                                  .cancel_outlined,
                                                              color:
                                                                  textColor))),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(
                                                  media.width * 0.05),
                                              width: media.width * 0.9,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: page),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    languages[choosenLanguage]
                                                        ['text_confirmlogout'],
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.roboto(
                                                        fontSize: media.width *
                                                            sixteen,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.05,
                                                  ),
                                                  Button(
                                                      onTap: () async {
                                                        setState(() {
                                                          _isLoading = true;
                                                          logout = false;
                                                        });
                                                        var result =
                                                            await userLogout();
                                                        if (result ==
                                                            'success') {
                                                          setState(() {
                                                            if (ownermodule ==
                                                                '1') {
                                                              Future.delayed(
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                                  () {
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const SignupMethod()));
                                                              });
                                                            } else {
                                                              ischeckownerordriver ==
                                                                  'driver';
                                                              Future.delayed(
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                                  () {
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const Login()));
                                                              });
                                                            }
                                                            userDetails.clear();
                                                          });
                                                        } else {
                                                          setState(() {
                                                            logout = true;
                                                          });
                                                        }
                                                      },
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['text_confirm'])
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                  : Container(),

                              //waiting time popup
                              (_showWaitingInfo == true)
                                  ? Positioned(
                                      top: 0,
                                      child: Container(
                                        height: media.height * 1,
                                        width: media.width * 1,
                                        // color:
                                        //     Colors.transparent.withOpacity(0.6),
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.2)
                                            : Colors.transparent
                                                .withOpacity(0.6),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: media.width * 0.9,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                      height:
                                                          media.height * 0.1,
                                                      width: media.width * 0.1,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: page),
                                                      child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              _showWaitingInfo =
                                                                  false;
                                                            });
                                                          },
                                                          child: Icon(
                                                              Icons
                                                                  .cancel_outlined,
                                                              color:
                                                                  textColor))),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(
                                                  media.width * 0.05),
                                              width: media.width * 0.9,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: page),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    languages[choosenLanguage]
                                                        ['text_waiting_time_1'],
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.roboto(
                                                        fontSize: media.width *
                                                            sixteen,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.w600),
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
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_waiting_time_2'],
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color:
                                                                  textColor)),
                                                      Text(
                                                          '${driverReq['free_waiting_time_in_mins_before_trip_start']} mins',
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color: textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
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
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_waiting_time_3'],
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color:
                                                                  textColor)),
                                                      Text(
                                                          '${driverReq['free_waiting_time_in_mins_after_trip_start']} mins',
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color: textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                  : Container(),

                              //no internet
                              (internet == false)
                                  ? Positioned(
                                      top: 0,
                                      child: NoInternet(
                                        onTap: () {
                                          setState(() async {
                                            internetTrue();
                                            var val = await getUserDetails();
                                            if (val == 'logout') {
                                              navigateLogout();
                                            }
                                          });
                                        },
                                      ))
                                  : Container(),

                              //sos popup
                              (showSos == true)
                                  ? Positioned(
                                      top: 0,
                                      child: Container(
                                        height: media.height * 1,
                                        width: media.width * 1,
                                        // color:
                                        //     Colors.transparent.withOpacity(0.6),
                                        color: (isDarkTheme == true)
                                            ? textColor.withOpacity(0.2)
                                            : Colors.transparent
                                                .withOpacity(0.6),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: media.width * 0.7,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          notifyCompleted =
                                                              false;
                                                          showSos = false;
                                                        });
                                                      },
                                                      child: Container(
                                                        height:
                                                            media.width * 0.1,
                                                        width:
                                                            media.width * 0.1,
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: page),
                                                        child: Icon(
                                                            Icons
                                                                .cancel_outlined,
                                                            color: textColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                height: media.height * 0.5,
                                                width: media.width * 0.7,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: page),
                                                child: SingleChildScrollView(
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        InkWell(
                                                          onTap: () async {
                                                            setState(() {
                                                              notifyCompleted =
                                                                  false;
                                                            });
                                                            var val =
                                                                await notifyAdmin();
                                                            if (val == true) {
                                                              setState(() {
                                                                notifyCompleted =
                                                                    true;
                                                              });
                                                            }
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .all(media
                                                                        .width *
                                                                    0.05),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_notifyadmin'],
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                    (notifyCompleted ==
                                                                            true)
                                                                        ? Container(
                                                                            padding:
                                                                                EdgeInsets.only(top: media.width * 0.01),
                                                                            child:
                                                                                Text(
                                                                              languages[choosenLanguage]['text_notifysuccess'],
                                                                              style: GoogleFonts.roboto(
                                                                                fontSize: media.width * twelve,
                                                                                color: const Color(0xff319900),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Container()
                                                                  ],
                                                                ),
                                                                Icon(
                                                                    Icons
                                                                        .notification_add,
                                                                    color:
                                                                        textColor)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        (sosData.isNotEmpty)
                                                            ? Column(
                                                                children: sosData
                                                                    .asMap()
                                                                    .map((i, value) {
                                                                      return MapEntry(
                                                                          i,
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
                                                                              makingPhoneCall(sosData[i]['number'].toString().replaceAll(' ', ''));
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.all(media.width * 0.05),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      SizedBox(
                                                                                        width: media.width * 0.4,
                                                                                        child: Text(
                                                                                          sosData[i]['name'],
                                                                                          style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor, fontWeight: FontWeight.w600),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: media.width * 0.01,
                                                                                      ),
                                                                                      Text(
                                                                                        sosData[i]['number'],
                                                                                        style: GoogleFonts.roboto(
                                                                                          fontSize: media.width * twelve,
                                                                                          color: textColor,
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                  Icon(Icons.call, color: textColor)
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ));
                                                                    })
                                                                    .values
                                                                    .toList(),
                                                              )
                                                            : Container(
                                                                width: media
                                                                        .width *
                                                                    0.7,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  languages[
                                                                          choosenLanguage]
                                                                      [
                                                                      'text_noDataFound'],
                                                                  style: GoogleFonts.roboto(
                                                                      fontSize:
                                                                          media.width *
                                                                              eighteen,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          textColor),
                                                                ),
                                                              )
                                                      ],
                                                    )),
                                              )
                                            ]),
                                      ))
                                  : Container(),

                              //choose option for seeing location on map while having multiple stops
                              (_tripOpenMap == true)
                                  ? Positioned(
                                      top: 0,
                                      child: Container(
                                        height: media.height * 1,
                                        width: media.width * 1,
                                        color:
                                            Colors.transparent.withOpacity(0.6),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: media.width * 0.9,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _tripOpenMap = false;
                                                      });
                                                    },
                                                    child: Container(
                                                      height: media.width * 0.1,
                                                      width: media.width * 0.1,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: page),
                                                      child: Icon(
                                                        Icons.cancel_outlined,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.05,
                                            ),
                                            Container(
                                                width: media.width * 0.9,
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: page),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width: media.width * 0.8,
                                                      child: Text(
                                                        languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_choose_address_nav'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    sixteen,
                                                                color:
                                                                    textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.height * 0.2,
                                                      child:
                                                          SingleChildScrollView(
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        child: Column(
                                                          children: tripStops
                                                              .asMap()
                                                              .map((i, value) {
                                                                return MapEntry(
                                                                    i,
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        openMap(
                                                                            tripStops[i]['latitude'],
                                                                            tripStops[i]['longitude']);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        // width: media.width*0.5,
                                                                        padding:
                                                                            EdgeInsets.all(media.width *
                                                                                0.025),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                tripStops[i]['address'],
                                                                                style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor, fontWeight: FontWeight.w600),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: media.width * 00.05,
                                                                              child: Image.asset('assets/images/locationFind.png', width: media.width * 0.05, color: textColor, fit: BoxFit.contain),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ));
                                                              })
                                                              .values
                                                              .toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                          ],
                                        ),
                                      ))
                                  : Container(),

                              (updateAvailable == true)
                                  ? Positioned(
                                      top: 0,
                                      child: Container(
                                        height: media.height * 1,
                                        width: media.width * 1,
                                        color:
                                            Colors.transparent.withOpacity(0.6),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                width: media.width * 0.9,
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: page,
                                                ),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                        width:
                                                            media.width * 0.8,
                                                        child: Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_update_available'],
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.05,
                                                    ),
                                                    Button(
                                                        onTap: () async {
                                                          if (platform ==
                                                              TargetPlatform
                                                                  .android) {
                                                            openBrowser(
                                                                'https://play.google.com/store/apps/details?id=${package.packageName}');
                                                          } else {
                                                            setState(() {
                                                              _isLoading = true;
                                                            });
                                                            var response =
                                                                await http.get(
                                                                    Uri.parse(
                                                                        'http://itunes.apple.com/lookup?bundleId=${package.packageName}'));
                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              openBrowser(jsonDecode(
                                                                          response
                                                                              .body)[
                                                                      'results'][0]
                                                                  [
                                                                  'trackViewUrl']);
                                                            }

                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });
                                                          }
                                                        },
                                                        text: 'Update')
                                                  ],
                                                ))
                                          ],
                                        ),
                                      ))
                                  : Container(),

                              //loader
                              (_isLoading == true)
                                  ? const Positioned(top: 0, child: Loading())
                                  : Container(),
                              //pickup marker
                              Positioned(
                                top: media.height * 1.5,
                                left: 100,
                                child: RepaintBoundary(
                                    key: iconKey,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: media.width * 0.5,
                                          height: media.width * 0.12,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: page),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: media.width * 0.12,
                                                width: media.width * 0.12,
                                                decoration: BoxDecoration(
                                                    borderRadius: (languageDirection ==
                                                            'ltr')
                                                        ? const BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10))
                                                        : const BorderRadius
                                                            .only(
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10)),
                                                    color:
                                                        const Color(0xff222222)),
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.star,
                                                  color: Color(0xff319900),
                                                ),
                                              ),
                                              Expanded(
                                                  child: Container(
                                                padding: EdgeInsets.only(
                                                    left: media.width * 0.02,
                                                    right: media.width * 0.02),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      languages[choosenLanguage]
                                                          ['text_pickpoint'],
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  twelve,
                                                          color: textColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    (driverReq.isNotEmpty &&
                                                            driverReq[
                                                                    'pick_address'] !=
                                                                null)
                                                        ? Text(
                                                            driverReq[
                                                                'pick_address'],
                                                            softWrap: false,
                                                            style: GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    twelve,
                                                                color:
                                                                    textColor),
                                                          )
                                                        : Container()
                                                  ],
                                                ),
                                              ))
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/userloc.png'),
                                                  fit: BoxFit.contain)),
                                          height: media.width * 0.05,
                                          width: media.width * 0.05,
                                        )
                                      ],
                                    )),
                              ),

                              //drop marker
                              Positioned(
                                  top: media.height * 2.5,
                                  left: 100,
                                  child: Column(
                                    children: [
                                      (tripStops.isNotEmpty)
                                          ? Column(
                                              children: tripStops
                                                  .asMap()
                                                  .map((i, value) {
                                                    iconDropKeys[i] =
                                                        GlobalKey();
                                                    return MapEntry(
                                                      i,
                                                      RepaintBoundary(
                                                          key: iconDropKeys[i],
                                                          child: Column(
                                                            children: [
                                                              (i <
                                                                      tripStops
                                                                              .length -
                                                                          1)
                                                                  ? Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom: 5),
                                                                          child:
                                                                              Text(
                                                                            (i + 1).toString(),
                                                                            style: GoogleFonts.roboto(
                                                                                fontSize: media.width * sixteen,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: (tripStops[i]['for_pickup'] == 1) ? Colors.green : Colors.red),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              image: DecorationImage(image: AssetImage((tripStops[i]['for_pickup'] == 1) ? 'assets/images/userloc.png' : 'assets/images/droploc.png'), fit: BoxFit.contain)),
                                                                          height:
                                                                              media.width * 0.05,
                                                                          width:
                                                                              media.width * 0.05,
                                                                        )
                                                                      ],
                                                                    )
                                                                  : (i ==
                                                                          tripStops.length -
                                                                              1)
                                                                      ? Column(
                                                                          children: [
                                                                            Container(
                                                                              width: media.width * 0.5,
                                                                              height: media.width * 0.12,
                                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: page),
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    height: media.width * 0.12,
                                                                                    width: media.width * 0.12,
                                                                                    decoration: BoxDecoration(borderRadius: (languageDirection == 'ltr') ? const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)) : const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)), color: const Color(0xff222222)),
                                                                                    alignment: Alignment.center,
                                                                                    child: const Icon(
                                                                                      Icons.star,
                                                                                      color: Color(0xffE60000),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                      child: Container(
                                                                                    padding: EdgeInsets.only(left: media.width * 0.02, right: media.width * 0.02),
                                                                                    child: Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        (driverReq['drop_address'] != null)
                                                                                            ? Text(
                                                                                                languages[choosenLanguage]['text_droppoint'],
                                                                                                style: GoogleFonts.roboto(fontSize: media.width * twelve, fontWeight: FontWeight.bold, color: textColor),
                                                                                              )
                                                                                            : Container(),
                                                                                        (driverReq.isNotEmpty && driverReq['drop_address'] != null)
                                                                                            ? Text(
                                                                                                driverReq['drop_address'],
                                                                                                softWrap: false,
                                                                                                style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor),
                                                                                              )
                                                                                            : Container(),
                                                                                      ],
                                                                                    ),
                                                                                  ))
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            Container(
                                                                              decoration: const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/droploc.png'), fit: BoxFit.contain)),
                                                                              height: media.width * 0.05,
                                                                              width: media.width * 0.05,
                                                                            )
                                                                          ],
                                                                        )
                                                                      : Container(),
                                                            ],
                                                          )),
                                                    );
                                                  })
                                                  .values
                                                  .toList(),
                                            )
                                          : Container(),
                                    ],
                                  )),

                              //drop marker
                              Positioned(
                                top: media.height * 2.5,
                                left: 100,
                                child: Column(
                                  children: [
                                    RepaintBoundary(
                                        key: iconDropKey,
                                        child: Column(
                                          children: [
                                            Container(
                                              width: media.width * 0.5,
                                              height: media.width * 0.12,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: page),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: media.width * 0.12,
                                                    width: media.width * 0.12,
                                                    decoration: BoxDecoration(
                                                        borderRadius: (languageDirection ==
                                                                'ltr')
                                                            ? const BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                        10))
                                                            : const BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight:
                                                                    Radius.circular(
                                                                        10)),
                                                        color: const Color(
                                                            0xff222222)),
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                      Icons.star,
                                                      color: Color(0xffE60000),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Container(
                                                    padding: EdgeInsets.only(
                                                        left:
                                                            media.width * 0.02,
                                                        right:
                                                            media.width * 0.02),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          (dropDistance != '' &&
                                                                  driverReq[
                                                                          'accepted_at'] ==
                                                                      null)
                                                              ? "${languages[choosenLanguage]['text_droppoint']} ($dropDistance)"
                                                              : languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_droppoint'],
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      twelve,
                                                              color: textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        (driverReq.isNotEmpty &&
                                                                driverReq[
                                                                        'drop_address'] !=
                                                                    null)
                                                            ? Text(
                                                                driverReq[
                                                                    'drop_address'],
                                                                softWrap: false,
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        twelve,
                                                                    color:
                                                                        textColor),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ))
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/droploc.png'),
                                                      fit: BoxFit.contain)),
                                              height: media.width * 0.05,
                                              width: media.width * 0.05,
                                            )
                                          ],
                                        )),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                ),
              );
            }),
      ),
    );
  }

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();

    double lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return vector.degrees(atan(lng / lat));
    } else if (begin.latitude >= end.latitude &&
        begin.longitude < end.longitude) {
      return (90 - vector.degrees(atan(lng / lat))) + 90;
    } else if (begin.latitude >= end.latitude &&
        begin.longitude >= end.longitude) {
      return vector.degrees(atan(lng / lat)) + 180;
    } else if (begin.latitude < end.latitude &&
        begin.longitude >= end.longitude) {
      return (90 - vector.degrees(atan(lng / lat))) + 270;
    }

    return -1;
  }

  animateCar(
      double fromLat, //Starting latitude

      double fromLong, //Starting longitude

      double toLat, //Ending latitude

      double toLong, //Ending longitude

      StreamSink<List<Marker>>
          mapMarkerSink, //Stream build of map to update the UI

      TickerProvider
          provider, //Ticker provider of the widget. This is used for animation

      GoogleMapController controller, //Google map controller of our widget

      markerid,
      icon,
      name,
      number) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    dynamic carMarker;
    if (name == '' && number == '') {
      carMarker = Marker(
          markerId: MarkerId(markerid),
          position: LatLng(fromLat, fromLong),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          draggable: false);
    } else {
      carMarker = Marker(
          markerId: MarkerId(markerid),
          position: LatLng(fromLat, fromLong),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(title: number, snippet: name),
          flat: true,
          draggable: false);
    }

    myMarkers.add(carMarker);

    mapMarkerSink.add(Set<Marker>.from(myMarkers).toList());

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController)
      ..addListener(() async {
        myMarkers
            .removeWhere((element) => element.markerId == MarkerId(markerid));

        final v = _animation!.value;

        double lng = v * toLong + (1 - v) * fromLong;

        double lat = v * toLat + (1 - v) * fromLat;

        LatLng newPos = LatLng(lat, lng);

        //New marker location

        if (name == '' && number == '') {
          carMarker = Marker(
              markerId: MarkerId(markerid),
              position: newPos,
              icon: icon,
              anchor: const Offset(0.5, 0.5),
              flat: true,
              rotation: bearing,
              draggable: false);
        } else {
          carMarker = Marker(
              markerId: MarkerId(markerid),
              position: newPos,
              icon: icon,
              infoWindow: InfoWindow(title: number, snippet: name),
              anchor: const Offset(0.5, 0.5),
              flat: true,
              rotation: bearing,
              draggable: false);
        }

        //Adding new marker to our list and updating the google map UI.

        myMarkers.add(carMarker);

        mapMarkerSink.add(Set<Marker>.from(myMarkers).toList());
      });

    //Starting the animation

    animationController.forward();

    if (driverReq.isEmpty || driverReq['is_trip_start'] == 1) {
      controller.getVisibleRegion().then((value) {
        if (value.contains(myMarkers
            .firstWhere((element) => element.markerId == MarkerId(markerid))
            .position)) {
        } else {
          controller.animateCamera(CameraUpdate.newLatLng(center));
        }
      });
    }
    animationController = null;
  }
}

class OwnerCarImagecontainer extends StatelessWidget {
  final String imgurl;
  final String text;
  final Color color;
  final void Function()? ontap;
  const OwnerCarImagecontainer(
      {Key? key,
      required this.imgurl,
      required this.text,
      required this.ontap,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return InkWell(
      onTap: ontap,
      child: Container(
        padding: EdgeInsets.all(
          media.width * 0.01,
        ),
        width: media.width * 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage(imgurl), fit: BoxFit.contain)),
              height: media.width * 0.07,
              width: media.width * 0.15,
            ),
            Container(
              height: media.width * 0.03,
              width: media.width * 0.13,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color,
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            )
          ],
        ),
      ),
    );
  }
}
