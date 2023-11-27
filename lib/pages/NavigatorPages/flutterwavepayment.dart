import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagxidriver/functions/functions.dart';
import 'package:tagxidriver/pages/NavigatorPages/walletpage.dart';
import 'package:tagxidriver/pages/loadingPage/loading.dart';
import 'package:tagxidriver/pages/login/signupmethod.dart';
import 'package:tagxidriver/pages/noInternet/nointernet.dart';
import 'package:tagxidriver/styles/styles.dart';
import 'package:tagxidriver/translation/translation.dart';
import 'package:tagxidriver/widgets/widgets.dart';
import 'package:flutterwave_standard/flutterwave.dart';

class FlutterWavePage extends StatefulWidget {
  const FlutterWavePage({Key? key}) : super(key: key);

  @override
  State<FlutterWavePage> createState() => _FlutterWavePageState();
}

class _FlutterWavePageState extends State<FlutterWavePage> {
  bool _isLoading = true;
  bool _success = false;
  bool _failed = false;
  dynamic flutterwave;
  @override
  void initState() {
    payMoney();
    super.initState();
  }

//navigate pop
  pop() {
    Navigator.pop(context, true);
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupMethod()),
        (route) => false);
  }

//payment gateway code
  payMoney() async {
    final style = FlutterwaveStyle(
      appBarText: "Flutterwave Checkout",
      buttonColor: buttonColor,
      appBarIcon: const Icon(Icons.message, color: Color(0xffd0ebff)),
      buttonTextStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      appBarColor: const Color(0xffd0ebff),
      dialogCancelTextStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 16,
      ),
      dialogContinueTextStyle: const TextStyle(
        color: Colors.blue,
        fontSize: 16,
      ),
    );

    final Customer customer = Customer(
        name: userDetails['name'],
        phoneNumber: userDetails['mobile'],
        email: userDetails['email']);

    flutterwave = Flutterwave(
        context: context,
        style: style,
        publicKey: (walletBalance['flutterwave_environment'] == 'test')
            ? walletBalance['flutter_wave_test_secret_key']
            : walletBalance['flutter_wave_live_secret_key'],
        currency: walletBalance['currency_code'],
        txRef: '${userDetails['id']}_${DateTime.now()}',
        amount: addMoney.toString(),
        customer: customer,
        paymentOptions: "ussd, card, barter, payattitude, account",
        customization: Customization(title: "Payment"),
        isTestMode: (walletBalance['flutterwave_environment'] == 'test')
            ? true
            : false);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Material(
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              return Directionality(
                textDirection: (languageDirection == 'rtl')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(media.width * 0.05,
                          media.width * 0.05, media.width * 0.05, 0),
                      height: media.height * 1,
                      width: media.width * 1,
                      color: page,
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).padding.top),
                          Stack(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.only(bottom: media.width * 0.05),
                                width: media.width * 0.9,
                                alignment: Alignment.center,
                                child: Text(
                                  languages[choosenLanguage]['text_addmoney'],
                                  style: GoogleFonts.roboto(
                                      color: textColor,
                                      fontSize: media.width * sixteen,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Positioned(
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: Icon(Icons.arrow_back,
                                          color: textColor)))
                            ],
                          ),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          Text(
                            walletBalance['currency_symbol'] +
                                ' ' +
                                addMoney.toString(),
                            style: GoogleFonts.roboto(
                                color: textColor,
                                fontSize: media.width * twenty,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          Button(
                              onTap: () async {
                                final ChargeResponse response =
                                    await flutterwave.charge();
                                // ignore: unnecessary_null_comparison
                                if (response != null) {
                                  if (response.status == 'success') {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    var val = await addMoneyFlutterwave(
                                        addMoney, response.transactionId);
                                    if (val == 'success') {
                                      setState(() {
                                        _success = true;
                                        _isLoading = false;
                                      });
                                    } else if (val == 'logout') {
                                      navigateLogout();
                                    }
                                  } else {
                                    setState(() {
                                      _failed = true;
                                      _isLoading = false;
                                    });
                                    // Transaction not successful
                                  }
                                } else {
                                  pop();
                                }
                              },
                              text: 'Pay')
                        ],
                      ),
                    ),
                    //payment failed
                    (_failed == true)
                        ? Positioned(
                            top: 0,
                            child: Container(
                              height: media.height * 1,
                              width: media.width * 1,
                              color: Colors.transparent.withOpacity(0.6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(media.width * 0.05),
                                    width: media.width * 0.9,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: page),
                                    child: Column(
                                      children: [
                                        Text(
                                          languages[choosenLanguage]
                                              ['text_somethingwentwrong'],
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Button(
                                            onTap: () async {
                                              setState(() {
                                                _failed = false;
                                              });
                                            },
                                            text: languages[choosenLanguage]
                                                ['text_ok'])
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        : Container(),

                    //payment success
                    (_success == true)
                        ? Positioned(
                            top: 0,
                            child: Container(
                              height: media.height * 1,
                              width: media.width * 1,
                              color: Colors.transparent.withOpacity(0.6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(media.width * 0.05),
                                    width: media.width * 0.9,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: page),
                                    child: Column(
                                      children: [
                                        Text(
                                          languages[choosenLanguage]
                                              ['text_paymentsuccess'],
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Button(
                                            onTap: () async {
                                              setState(() {
                                                _success = false;

                                                Navigator.pop(context, true);
                                              });
                                            },
                                            text: languages[choosenLanguage]
                                                ['text_ok'])
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
                                setState(() {
                                  internetTrue();
                                  _isLoading = true;
                                });
                              },
                            ))
                        : Container(),

                    //loader
                    (_isLoading == true)
                        ? const Positioned(top: 0, child: Loading())
                        : Container()
                  ],
                ),
              );
            }),
      ),
    );
  }
}
