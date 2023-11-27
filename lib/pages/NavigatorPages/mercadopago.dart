import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../functions/functions.dart';
import 'walletpage.dart';

// ignore: must_be_immutable
class MercadoPago extends StatefulWidget {
  dynamic from;
  MercadoPago({super.key, this.from});

  @override
  State<MercadoPago> createState() => _MercadoPagoState();
}

class _MercadoPagoState extends State<MercadoPago> {
  bool pop = true;
  late final WebViewController _controller;

  @override
  void initState() {
    // #docregion platform_features
    var paymentUrl =
        '${url}mercadopago-checkout?amount=$addMoney&user_id=${userDetails['user_id']}&request_for=add-money-to-wallet';

    late final PlatformWebViewControllerCreationParams params;

    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('${url}mercadopago-success')) {
              setState(() {
                pop = true;
              });
            } else if (request.url.startsWith(
                'https://www.mercadopago.com.ar/checkout/v1/payment/redirect')) {
              setState(() {
                pop = false;
              });
            } else if (request.url.startsWith('${url}failure')) {
              setState(() {
                pop = true;
              });
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));
    _controller = controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Material(
        child: Container(
          height: media.height,
          width: media.width,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          // child: Container(),
          child: Column(
            children: [
              if (pop == true)
                Container(
                  width: media.width,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(media.width * 0.05),
                  child: InkWell(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: const Icon(Icons.arrow_back)),
                ),
              Expanded(
                child: WebViewWidget(
                  controller: _controller,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
