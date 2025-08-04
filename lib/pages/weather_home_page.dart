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

    const String apiKey =
        'beb68caa757def4aad48a4d473795f8a'; // Use your own API key
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
          _errorMessage = '';
          _isLoading = false;

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
          _cityName = '';
          _temperature = null;
          _description = '';
          _icon = '';
          _humidity = null;
          _windSpeed = null;
          _forecast = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather data';
        _cityName = '';
        _temperature = null;
        _description = '';
        _icon = '';
        _humidity = null;
        _windSpeed = null;
        _forecast = [];
        _isLoading = false;
      });
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
      case '04d':
      case '04n':
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_cityName.isNotEmpty ? _cityName : 'Weather Hub'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
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
              themeProvider.isDarkTheme
                  ? const Color(0xFF1A1B23)
                  : Colors.grey[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with animated icon and title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkTheme
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          _cityName.isNotEmpty ? _cityName : 'Weather Hub',
                          key: ValueKey(_cityName),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkTheme
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Search input
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: themeProvider.isDarkTheme
                            ? [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ]
                            : [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.05),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: themeProvider.isDarkTheme
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'Search for a city...',
                        labelStyle: TextStyle(
                          color: themeProvider.isDarkTheme
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        suffixIcon: AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _isLoading ? _rotationAnimation.value : 0,
                              child: IconButton(
                                icon: Icon(
                                  _isLoading ? Icons.refresh : Icons.search,
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_cityController.text.isNotEmpty) {
                                          _fetchWeather(_cityController.text);
                                        }
                                      },
                              ),
                            );
                          },
                        ),
                      ),
                      style: TextStyle(
                        color: themeProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty && !_isLoading) {
                          _fetchWeather(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Content
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _temperature != null
                      ? WeatherContent(
                          temperature: _temperature!,
                          description: _description,
                          icon: _icon,
                          humidity: _humidity ?? 0,
                          windSpeed: _windSpeed ?? 0,
                          showToday: _showToday,
                          forecast: _forecast,
                          fadeAnimation: _fadeAnimation,
                          slideAnimation: _slideAnimation,
                          temperatureAnimation: _temperatureAnimation,
                          cardAnimation: _cardAnimation,
                          mapIconToIconData: _mapIconToIconData,
                          onToggleToday: () {
                            setState(() {
                              _showToday = true;
                            });
                          },
                          onToggleForecast: () {
                            setState(() {
                              _showToday = false;
                            });
                          },
                        )
                      : const WelcomeContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WeatherContent extends StatelessWidget {
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final bool showToday;
  final List<Map<String, dynamic>> forecast;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> temperatureAnimation;
  final Animation<double> cardAnimation;
  final IconData Function(String) mapIconToIconData;
  final VoidCallback onToggleToday;
  final VoidCallback onToggleForecast;

  const WeatherContent({
    super.key,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.showToday,
    required this.forecast,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.temperatureAnimation,
    required this.cardAnimation,
    required this.mapIconToIconData,
    required this.onToggleToday,
    required this.onToggleForecast,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temperature: ${temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            'Description: $description',
            style: const TextStyle(fontSize: 18),
          ),
          Icon(mapIconToIconData(icon), size: 50),
          Text('Humidity: $humidity%'),
          Text('Wind Speed: ${windSpeed.toStringAsFixed(1)} m/s'),
          const SizedBox(height: 20),
          Text(showToday ? 'Today\'s Forecast' : '5-Day Forecast'),
          ...forecast.map(
            (day) => ListTile(
              leading: Icon(mapIconToIconData(day['icon'])),
              title: Text(day['day']),
              subtitle: Text(day['description']),
              trailing: Text(day['temp']),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: onToggleToday, child: const Text('Today')),
              TextButton(
                onPressed: onToggleForecast,
                child: const Text('Forecast'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Welcome! Please search for a city to get weather info.',
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
