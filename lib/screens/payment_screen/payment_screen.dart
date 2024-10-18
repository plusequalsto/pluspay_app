import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:rive/rive.dart';

class PaymentScreen extends StatefulWidget {
  final Terminal terminal;
  final String deviceType;

  const PaymentScreen({
    super.key,
    required this.terminal,
    required this.deviceType,
  });
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  bool _isPaymentSuccessful = false;
  PaymentIntent? _paymentIntent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSnackBar("Connected");
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _disconnectReader() async {
    try {
      await widget.terminal.disconnectReader();
      showSnackBar("Disconnected from reader.");
    } catch (e) {
      showSnackBar("Failed to disconnect from the reader: ${e.toString()}");
    }
  }

  Future<bool> _createPaymentIntent(Terminal terminal, String amount) async {
    final paymentIntent =
        await terminal.createPaymentIntent(PaymentIntentParameters(
      amount:
          (double.parse(double.parse(amount).toStringAsFixed(2)) * 100).ceil(),
      currency: "gbp",
      captureMethod: CaptureMethod.automatic,
      paymentMethodTypes: [PaymentMethodType.cardPresent],
    ));
    _paymentIntent = paymentIntent;
    if (_paymentIntent == null) {
      showSnackBar('Payment intent is not created!');
    }

    return await _collectPaymentMethod(terminal, _paymentIntent!);
  }

  Future<bool> _collectPaymentMethod(
      Terminal terminal, PaymentIntent paymentIntent) async {
    final collectingPaymentMethod = terminal.collectPaymentMethod(
      paymentIntent,
      skipTipping: true,
    );

    try {
      final paymentIntentWithPaymentMethod = await collectingPaymentMethod;
      _paymentIntent = paymentIntentWithPaymentMethod;
      await _confirmPaymentIntent(terminal, _paymentIntent!).then((value) {});
      return true;
    } on TerminalException catch (exception) {
      switch (exception.code) {
        case TerminalExceptionCode.canceled:
          showSnackBar('Collecting Payment method is cancelled!');
          return false;
        default:
          rethrow;
      }
    }
  }

  Future<void> _confirmPaymentIntent(
      Terminal terminal, PaymentIntent paymentIntent) async {
    try {
      showSnackBar('Processing!');

      final processedPaymentIntent =
          await terminal.confirmPaymentIntent(paymentIntent);
      _paymentIntent = processedPaymentIntent;
      // Show the animation for a while and then reset the state
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _isPaymentSuccessful = false;
        });
      });
      setState(() {
        _isPaymentSuccessful = true;
      });
      showSnackBar('Payment processed!');
    } catch (e) {
      showSnackBar('Inside collect payment exception ${e.toString()}');

      logger.d(e.toString());
    }
    // navigate to payment success screen
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
  }

  void _collectPayment() async {
    if (_formKey.currentState!.validate()) {
      bool status =
          await _createPaymentIntent(widget.terminal, _amountController.text);
      if (status) {
        showSnackBar('Payment Collected: ${_amountController.text}');
      } else {
        showSnackBar('Payment Canceled');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _disconnectReader(); // Disconnect from the reader
            Navigator.of(context).pop();
          },
        ),
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Collect Payment',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textPrimary,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Enter Amount',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors
                              .primaryColor, // Set your desired color here
                          width: 2.0, // You can adjust the width of the border
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors
                              .primaryColor, // Set color when focused
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              AppColors.primaryColor, // Set color when enabled
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.accentColor, // Set color for error state
                          width: 2.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors
                              .accentColor, // Set color for focused error state
                          width: 2.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _collectPayment,
                    child: Text(
                      'Collect Payment',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isPaymentSuccessful)
            RiveAnimation.asset(
              'assets/animations/success.riv',
            ),
        ],
      ),
    );
  }
}
