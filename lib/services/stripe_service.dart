import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:project_lab_rat/consts.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  // NEW: Store payment intent ID for backend usage
  String? _paymentIntentId;

  Future<void> makePayment() async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(
        20,
        'usd',
      );
      if (paymentIntentClientSecret == null) return;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: 'Fahim',
        ),
      );

      // Modified: Now we check if payment was successful using try-catch
      bool paymentSuccessful = await _processPayment();

      // NEW: Send transaction data to backend after successful payment
      if (paymentSuccessful && _paymentIntentId != null) {
        await _sendTransactionToBackend(_paymentIntentId!);
      }
    } catch (e) {
      print(e);
    }
  }

  // Changed: Using http package instead of dio
  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      Map<String, String> data = {
        "amount": _calculatedAmount(amount),
        "currency": currency,
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          "Authorization": "Bearer $stripeSecretKey",
          "Content-Type": 'application/x-www-form-urlencoded',
        },
        body: data,
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print(responseData);
        // NEW: Store the payment intent ID for backend usage
        _paymentIntentId = responseData['id'];
        return responseData['client_secret'];
      }
      return null;
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Modified: Now returns bool to indicate if payment was successful
  Future<bool> _processPayment() async {
    try{
      await Stripe.instance.presentPaymentSheet();
      // If no exception is thrown, payment was successful
      return true;
    } catch (e) {
      print(e);
      // If exception is thrown, payment failed or was cancelled
      return false;
    }
  }

  // NEW: Function to send transaction data to your backend using http
  Future<void> _sendTransactionToBackend(String transactionId) async {
    try {
      // Replace with your actual backend URL
      const String backendUrl = 'https://your-backend-api.com/transactions';

      Map<String, dynamic> transactionData = {
        "transactionId": transactionId, // Using actual payment intent ID (pi_3RdV84...)
        "paymentType": "online"
      };

      var response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          "Content-Type": 'application/json',
          // Add any authentication headers your backend requires
          // "Authorization": "Bearer YOUR_BACKEND_TOKEN",
        },
        body: json.encode(transactionData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Transaction sent to backend successfully');
        print(response.body);
      } else {
        print('Failed to send transaction to backend: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending transaction to backend: $e');
    }
  }

  String _calculatedAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}