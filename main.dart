import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Stripe basics', home: Homepage());
  }
}

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Token _token;
  PaymentMethod _paymentMethod;
  Source _source;
  final String _secretKey =
      'sk_test_51HHlB2CE7SJxpelTVcJCAGwym4tKHW4goVHGtk70SaWolS5oXe14kdC791CqOGEOzBJPM1WL6VOf0BEW613QiHng00WHrnqgHb';
  PaymentIntentResult _paymentIntentResult;
  final CreditCard creditCard =
      CreditCard(number: '4111111111111111', expMonth: 02, expYear: 24);
  String _error;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  void getError(dynamic error) {
    _globalKey.currentState.showSnackBar(SnackBar(
      content: Text(error.toString()),
    ));
    setState(() {
      _error = error;
    });
  }

  @override
  void initState() {
    super.initState();
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            'pk_test_51HHlB2CE7SJxpelTu61y48rjxXzqms9pJuEtTAxNbP5rgRoZANHR4IFITZnDFn53Aaogbiski6JRRHpFw2ldNrB0006vX87gda',
        androidPayMode: 'test',
        merchantId: 'Test'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Stripe Basics'),
      ),
      body: Container(
        child: Center(
          child: SingleChildScrollView(
                      child: Column(
              children: [
                MaterialButton(
                  child: Text('Initialize Source'),
                  color: Colors.lightBlue,
                  onPressed: () {
                    StripePayment.createSourceWithParams(SourceParams(
                            returnURL: 'example://stripe-redirect',
                            amount: 8000,
                            currency: 'inr',
                            type: 'ideal'))
                        .then((source) {
                      setState(() {
                        _source = source;
                      });
                    }).catchError(getError);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      child: Text('Token with Card Form'),
                      color: Colors.redAccent,
                      onPressed: () {
                        StripePayment.paymentRequestWithCardForm(
                                CardFormPaymentRequest())
                            .then((paymentMethod) {
                          setState(() {
                            _paymentMethod = paymentMethod;
                          });
                        }).catchError(getError);
                      },
                    ),
                    MaterialButton(
                      child: Text('Token with Card'),
                      color: Colors.yellow,
                      onPressed: () {
                        StripePayment.createTokenWithCard(creditCard)
                            .then((token) {
                          setState(() {
                            _token = token;
                          });
                        }).catchError(getError);
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      child: Text('Payment Method with Card'),
                      color: Colors.amber,
                      onPressed: () {
                        StripePayment.createPaymentMethod(
                                PaymentMethodRequest(card: creditCard))
                            .then((paymentMethod) {
                          setState(() {
                            _paymentMethod = paymentMethod;
                          });
                        }).catchError(getError);
                      },
                    ),
                    MaterialButton(
                      child: Text('Payment Method with token'),
                      color: Colors.pink,
                      onPressed: _token == null
                          ? null
                          : () {
                              StripePayment.createPaymentMethod(
                                      PaymentMethodRequest(
                                          card:
                                              CreditCard(token: _token.tokenId)))
                                  .then((paymentMethod) {
                                setState(() {
                                  _paymentMethod = paymentMethod;
                                });
                              }).catchError(getError);
                            },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      child: Text('Get Payment Intent'),
                      color: Colors.greenAccent,
                      onPressed: _paymentMethod == null || _secretKey == null
                          ? null
                          : () {
                              StripePayment.confirmPaymentIntent(PaymentIntent(
                                      clientSecret: _secretKey,
                                      paymentMethodId: _paymentMethod.id))
                                  .then((paymentIntent) {
                                setState(() {
                                  _paymentIntentResult = paymentIntent;
                                });
                              }).catchError(getError);
                            },
                    ),
                    MaterialButton(
                      child: Text('Authenticate Payment Intent'),
                      color: Colors.purpleAccent,
                      onPressed: () {
                        StripePayment.authenticatePaymentIntent(
                                clientSecret: _secretKey)
                            .then((paymentIntent) {
                          setState(() {
                            _paymentIntentResult = paymentIntent;
                          });
                        }).catchError(getError);
                      },
                    )
                  ],
                ),
                Divider(),
                Text('Source:'),
                Text(
                    JsonEncoder.withIndent(' ').convert(_source?.toJson() ?? {})),
                Text('Token:'),
                Text(JsonEncoder.withIndent(' ').convert(_token?.toJson() ?? {})),
                Text('Payment Method:'),
                Text(JsonEncoder.withIndent(' ')
                    .convert(_paymentMethod?.toJson() ?? {})),
                Text('Payment Intent:'),
                Text(JsonEncoder.withIndent(' ')
                    .convert(_paymentIntentResult?.toJson() ?? {})),
                Text('Error'),
                Text(_error.toString())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
