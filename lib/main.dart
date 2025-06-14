import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('isFirstRun') ?? true;
    final height = prefs.getDouble('height');
    final weight = prefs.getDouble('weight');
    final goal = prefs.getString('goal');

    if (isFirstRun || height == null || weight == null || goal == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Health App',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
            ),
            SizedBox(height: 10),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _goal;

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('height', double.parse(_heightController.text));
    await prefs.setDouble('weight', double.parse(_weightController.text));
    await prefs.setString('goal', _goal ?? 'Maintain');
    await prefs.setBool('isFirstRun', false); // Set only after successful save
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to Health App')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Height (cm)'),
            ),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
            ),
            DropdownButton<String>(
              hint: Text('Select Goal'),
              value: _goal,
              items: ['Lose Weight', 'Gain Muscle', 'Maintain']
                  .map((goal) => DropdownMenuItem(
                value: goal,
                child: Text(goal),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _goal = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserData,
              child: Text('Save and Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? height;
  double? weight;
  String? goal;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      height = prefs.getDouble('height') ?? 0.0;
      weight = prefs.getDouble('weight') ?? 0.0;
      goal = prefs.getString('goal') ?? 'Not set';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Health App Home')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Height: ${height?.toStringAsFixed(1)} cm',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Weight: ${weight?.toStringAsFixed(1)} kg',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Goal: $goal',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}