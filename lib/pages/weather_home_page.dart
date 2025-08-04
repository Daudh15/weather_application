import 'dart:convert';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:weather_application/screen/login_page.dart';
import 'package:weather_application/theme_provider.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with TickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  String _cityName = '';
  double? _temperature;
  String _description = '';
  String _icon = '';
  int? _humidity;
  double? _windSpeed;
  String _errorMessage = '';
  List<Map<String, dynamic>> _forecast = [];
  bool _isLoading = false;
  bool _showToday = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _temperatureController;
  late AnimationController _cardController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _temperatureAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _temperatureController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _temperatureAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _temperatureController, curve: Curves.bounceOut),
    );
    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _temperatureController.dispose();
    _cardController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    const String apiKey = 'beb68caa757def4aad48a4d473795f8a';
    final String baseUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _cityName = data['name'];
          _temperature = (data['main']['temp'] as num).toDouble();
          _description = data['weather'][0]['description'];
          _icon = data['weather'][0]['icon'];
          _humidity = data['main']['humidity'];
          _windSpeed = (data['wind']['speed'] as num).toDouble();
          _forecast = List.generate(5, (index) {
            String forecastIcon = _getRandomIcon();
            return {
              'temp':
                  '${(_temperature! - index).toStringAsFixed(0)}°/${(_temperature! + 5).toStringAsFixed(0)}°',
              'description': index == 0
                  ? 'Storm'
                  : index == 1
                      ? 'Shower'
                      : index == 2
                          ? 'Rain'
                          : index == 3
                              ? 'Cloudy'
                              : 'Sunny',
              'icon': forecastIcon,
              'day': _getDayName(index),
            };
          });
        });

        _fadeController.forward(from: 0);
        _slideController.forward(from: 0);
        _temperatureController.forward(from: 0);
        _cardController.forward(from: 0);
      } else {
        setState(() {
          _errorMessage = 'City not found';
          _temperature = null;
          _cityName = '';
          _forecast = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather data';
        _temperature = null;
        _cityName = '';
        _forecast = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getRandomIcon() {
    final List<String> icons = ['10d', '09d', '02d', '03d', '01d'];
    return icons[DateTime.now().millisecond % icons.length];
  }

  String _getDayName(int index) {
    final days = ['Today', 'Tomorrow', 'Wed', 'Thu', 'Fri'];
    return days[index];
  }

  IconData _mapIconToIconData(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return Icons.wb_sunny;
      case '02d':
      case '02n':
        return Icons.cloud_queue;
      case '03d':
      case '03n':
        return Icons.cloud;
      case '09d':
      case '09n':
        return Icons.invert_colors;
      case '10d':
      case '10n':
        return Icons.beach_access;
      case '11d':
      case '11n':
        return Icons.flash_on;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.blur_on;
      default:
        return Icons.help;
    }
  }

  Color _getBackgroundGradientColor() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (_temperature == null) {
      return themeProvider.isDarkTheme
          ? const Color(0xFF1A1B23)
          : Colors.grey[200]!;
    }
    if (_temperature! >= 30) {
      return themeProvider.isDarkTheme
          ? const Color(0xFF2D1B69)
          : const Color(0xFFFED7D7);
    } else if (_temperature! >= 20) {
      return themeProvider.isDarkTheme
          ? const Color(0xFF1A472A)
          : const Color(0xFFD4EFDF);
    } else if (_temperature! >= 10) {
      return themeProvider.isDarkTheme
          ? const Color(0xFF2C5282)
          : const Color(0xFFBFDBFE);
    } else {
      return themeProvider.isDarkTheme
          ? const Color(0xFF2A4365)
          : const Color(0xFFDBEAFE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkTheme;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? Colors.white12 : Colors.white;
    final errorCardColor = isDark ? Colors.red[700] : Colors.red[50];
    final errorTextColor = isDark ? Colors.white : Colors.red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : null,
        title: Text(
          _cityName.isNotEmpty ? _cityName : 'Weather Hub',
          style: TextStyle(color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: textColor,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: textColor),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getBackgroundGradientColor(),
              isDark ? const Color(0xFF1A1B23) : Colors.grey[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (_, __) => Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isDark ? Colors.white12 : Colors.black12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.menu, size: 28, color: textColor),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _cityName.isNotEmpty ? _cityName : 'Weather Hub',
                        key: ValueKey(_cityName),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.location_on, size: 28, color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Search bar card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Search for a city...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: subTextColor),
                        suffixIcon: AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (_, __) => Transform.rotate(
                            angle: _isLoading ? _rotationAnimation.value : 0,
                            child: IconButton(
                              icon: Icon(
                                _isLoading ? Icons.refresh : Icons.search,
                                color: textColor,
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (_cityController.text.isNotEmpty) {
                                        _fetchWeather(_cityController.text);
                                      }
                                    },
                            ),
                          ),
                        ),
                      ),
                      style: TextStyle(color: textColor),
                      onSubmitted: (v) {
                        if (v.isNotEmpty && !_isLoading) {
                          _fetchWeather(v);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Content area
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage.isNotEmpty)
                  Card(
                    color: errorCardColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: errorTextColor,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              color: errorTextColor,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_temperature != null)
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    color: cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_temperature!.toStringAsFixed(1)}°C',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(_mapIconToIconData(_icon), size: 50, color: textColor),
                                const SizedBox(width: 12),
                                Text(
                                  _description[0].toUpperCase() +
                                      _description.substring(1),
                                  style: TextStyle(fontSize: 20, color: textColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Humidity: $_humidity%',
                              style: TextStyle(fontSize: 16, color: textColor),
                            ),
                            Text(
                              'Wind: ${_windSpeed!.toStringAsFixed(1)} m/s',
                              style: TextStyle(fontSize: 16, color: textColor),
                            ),
                            Divider(
                              height: 32,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                            Text(
                              _showToday
                                  ? "Today's Forecast"
                                  : '5‑Day Forecast',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                children: _forecast.map((day) {
                                  return ListTile(
                                    leading: Icon(
                                      _mapIconToIconData(day['icon']),
                                      color: textColor,
                                    ),
                                    title: Text(day['day'], style: TextStyle(color: textColor)),
                                    subtitle: Text(day['description'], style: TextStyle(color: subTextColor)),
                                    trailing: Text(day['temp'], style: TextStyle(color: textColor)),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () => setState(() => _showToday = true),
                                  child: Text(
                                    'Today',
                                    style: TextStyle(color: isDark ? Colors.lightBlue[200] : Colors.blue),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => setState(() => _showToday = false),
                                  child: Text(
                                    'Forecast',
                                    style: TextStyle(color: isDark ? Colors.lightBlue[200] : Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    elevation: 4,
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 60,
                        horizontal: 20,
                      ),
                      child: Center(
                        child: Text(
                          'Welcome! Please search for a city\nto get weather info.',
                          style: TextStyle(fontSize: 18, color: textColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
