import 'package:flutter/material.dart';
import 'package:project_lab_rat/services/stripe_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.blue[300],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text('ঈদের চাঁদ আকাশে, টাকা পাঠান স্ট্রাইপে!', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center,),
                MaterialButton( color: Colors.blue, onPressed: (){
                  StripeService.instance.makePayment();
                }, child: const Text('টেকা দেন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),))
              ],
            ),
          ),
        ],
      ),
    );
  }
}