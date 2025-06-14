import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

// Root widget configuring the app's theme and initial screen
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App', // Sets the app title
      theme: ThemeData(primarySwatch: Colors.blue), // Applies a blue theme
      home: SplashScreen(), // Sets SplashScreen as the initial route
    );
  }
}

// Splash screen to display a loading state before navigation
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay(); // Initiates delayed navigation logic
  }

  // Navigates after a 3-second delay based on onboarding status
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(Duration(seconds: 3)); // 3-second splash delay
    final prefs = await SharedPreferences.getInstance(); // Access shared preferences
    final isFirstRun = prefs.getBool('isFirstRun') ?? true; // Check if first run
    final height = prefs.getDouble('height'); // Retrieve saved height
    final weight = prefs.getDouble('weight'); // Retrieve saved weight
    final goal = prefs.getString('goal'); // Retrieve saved goal

    // Navigate to onboarding if first run or data is missing
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
      backgroundColor: Colors.blue[100], // Light blue background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            Text(
              'Health App',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800], // Dark blue text
              ),
            ),
            SizedBox(height: 20), // Spacing between elements
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!), // Matching spinner color
            ),
            SizedBox(height: 10), // Spacing
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[800], // Matching text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Onboarding screen with a multi-page flow for weight, height, and goal
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController(); // Controls page navigation
  final _heightController = TextEditingController(); // Manages height input
  final _weightController = TextEditingController(); // Manages weight input
  String? _goal; // Stores selected goal

  int _currentPage = 0; // Tracks the current page (0, 1, or 2)

  // Saves user data to shared preferences and navigates to home
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('height', double.parse(_heightController.text)); // Save height
    await prefs.setDouble('weight', double.parse(_weightController.text)); // Save weight
    await prefs.setString('goal', _goal ?? 'Maintain'); // Save goal with fallback
    await prefs.setBool('isFirstRun', false); // Mark onboarding as complete
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  // Advances to the next page with animation
  void _nextPage() {
    if (_currentPage < 2) { // Ensure not on the last page
      _pageController.nextPage(
        duration: Duration(milliseconds: 300), // Smooth transition
        curve: Curves.easeInOut, // Easing animation
      );
    }
  }

  // Goes back to the previous page with animation
  void _previousPage() {
    if (_currentPage > 0) { // Ensure not on the first page
      _pageController.previousPage(
        duration: Duration(milliseconds: 300), // Smooth transition
        curve: Curves.easeInOut, // Easing animation
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // Clean up page controller
    _heightController.dispose(); // Clean up height controller
    _weightController.dispose(); // Clean up weight controller
    super.dispose(); // Call parent dispose
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to Health App')), // App bar with title
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController, // Manages page transitions
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index; // Update current page
                });
              },
              children: [
                _buildPage(
                  title: 'Enter Your Weight',
                  controller: _weightController,
                  hint: 'Weight (kg)',
                  keyboardType: TextInputType.number,
                ),
                _buildPage(
                  title: 'Enter Your Height',
                  controller: _heightController,
                  hint: 'Height (cm)',
                  keyboardType: TextInputType.number,
                ),
                _buildPage(
                  title: 'Select Your Goal',
                  child: DropdownButton<String>(
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
                        _goal = value; // Update goal selection
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0), // Padding around buttons
            child: Column(
              mainAxisSize: MainAxisSize.min, // Minimize column height
              children: [
                if (_currentPage > 0 && _currentPage < 3) // Show back button on pages 1 and 2
                  ElevatedButton(
                    onPressed: _previousPage, // Navigate to previous page
                    child: Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Differentiate from Next
                    ),
                  ),
                SizedBox(height: 10), // Spacing between buttons
                _currentPage == 2
                    ? ElevatedButton(
                  onPressed: _saveUserData, // Save data on last page
                  child: Text('Save and Continue'),
                )
                    : ElevatedButton(
                  onPressed: _nextPage, // Move to next page
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds a page with a title and either a text field or dropdown
  Widget _buildPage({
    required String title,
    TextEditingController? controller,
    String? hint,
    TextInputType? keyboardType,
    Widget? child,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.0), // Padding around page content
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20), // Spacing
          if (child != null) child, // Render dropdown if provided
          if (controller != null)
            TextField(
              controller: controller, // Bind controller
              keyboardType: keyboardType, // Set keyboard type
              decoration: InputDecoration(labelText: hint), // Label with hint
            ),
        ],
      ),
    );
  }
}

// Home screen displaying the user's saved profile data
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? height; // Stores height value
  double? weight; // Stores weight value
  String? goal; // Stores goal value

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load data on initialization
  }

  // Loads user data from shared preferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      height = prefs.getDouble('height') ?? 0.0; // Load height with fallback
      weight = prefs.getDouble('weight') ?? 0.0; // Load weight with fallback
      goal = prefs.getString('goal') ?? 'Not set'; // Load goal with fallback
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Health App Home')), // App bar with title
      body: Padding(
        padding: EdgeInsets.all(16.0), // Padding around content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
          children: [
            Text(
              'Your Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20), // Spacing
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