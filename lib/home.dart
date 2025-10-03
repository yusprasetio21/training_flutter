import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  bool isSearching = false;
  List<Map<String, dynamic>> searchResults = [];

  // Default lokasi: Jakarta
  double latitude = -6.2088;
  double longitude = 106.8456;
  String currentLocation = "Jakarta";

  final searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Geocoding API untuk mencari koordinat dari nama daerah
  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    final url = "http://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=id&format=json";

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = List<Map<String, dynamic>>.from(data['results'] ?? []);
          isSearching = false;
        });
      } else {
        setState(() {
          isSearching = false;
          searchResults = [];
        });
      }
    } catch (e) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
    }
  }

  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
    });

    final url = "http://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,relative_humidity_2m,precipitation,precipitation_probability,rain,wind_speed_10m,wind_direction_10m,cloud_cover&timezone=auto";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Gagal mengambil data cuaca');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackbar('Terjadi kesalahan: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gradient
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Weather Forecast",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[700]!, Colors.lightBlue[400]!],
                  ),
                ),
              ),
            ),
          ),

          // Konten utama
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 🔎 Search Bar Modern
                _buildSearchCard(),
                const SizedBox(height: 20),

                // Lokasi saat ini
                _buildCurrentLocationCard(),
                const SizedBox(height: 20),

                // 📊 Tampilan Data
                if (isLoading) _buildLoadingShimmer(),
                if (!isLoading && weatherData != null) _buildWeatherContent(),
                if (!isLoading && weatherData == null) _buildEmptyState(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: "Cari nama kota atau daerah...",
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: searchLocation,
            ),
            
            // Hasil pencarian
            if (isSearching)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            
            if (searchResults.isNotEmpty)
              ...searchResults.map((location) => ListTile(
                leading: Icon(Icons.location_on, color: Colors.blue[700]),
                title: Text(
                  "${location['name']}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  "${location['country']} • ${location['latitude'].toStringAsFixed(2)}°, ${location['longitude'].toStringAsFixed(2)}°",
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  setState(() {
                    latitude = location['latitude'];
                    longitude = location['longitude'];
                    currentLocation = location['name'];
                    searchController.clear();
                    searchResults = [];
                    _searchFocusNode.unfocus();
                  });
                  fetchWeather();
                },
              )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[600]!, Colors.lightBlue[300]!],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.location_on, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              currentLocation,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(3, (index) => 
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 14,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
      ],
    );
  }

  Widget _buildWeatherContent() {
    final times = weatherData!['hourly']['time'] as List;
    final temps = weatherData!['hourly']['temperature_2m'] as List;
    final humidity = weatherData!['hourly']['relative_humidity_2m'] as List;
    final precipitation = weatherData!['hourly']['precipitation'] as List;
    final precipitationProb = weatherData!['hourly']['precipitation_probability'] as List;
    final rain = weatherData!['hourly']['rain'] as List;
    final windSpeed = weatherData!['hourly']['wind_speed_10m'] as List;
    final windDirection = weatherData!['hourly']['wind_direction_10m'] as List;
    final cloudCover = weatherData!['hourly']['cloud_cover'] as List;

    // ambil hanya 12 jam pertama
    final chartData = List.generate(12, (i) => temps[i].toDouble());
    final timeLabels = List.generate(12, (i) {
      final timeStr = times[i].toString().replaceAll("T", " ");
      return timeStr.substring(11, 16); // Ambil hanya jam:menit
    });

    // Data saat ini (jam pertama)
    final currentTemp = temps[0];
    final currentHumidity = humidity[0];
    final currentPrecipitation = precipitation[0];
    final currentPrecipitationProb = precipitationProb[0];
    final currentRain = rain[0];
    final currentWindSpeed = windSpeed[0];
    final currentWindDirection = windDirection[0];
    final currentCloudCover = cloudCover[0];

    return Column(
      children: [
        // Card Kondisi Saat Ini
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.today_rounded, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      "Kondisi Saat Ini",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Suhu utama
                Center(
                  child: Text(
                    "${currentTemp}°C",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Grid parameter cuaca
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3,
                  children: [
                    _buildWeatherParameter("💧 Kelembaban", "$currentHumidity%", Colors.blue),
                    _buildWeatherParameter("🌧️ Prob. Hujan", "$currentPrecipitationProb%", Colors.purple),
                    _buildWeatherParameter("💨 Angin", "${currentWindSpeed} km/h", Colors.green),
                    _buildWeatherParameter("☁️ Awan", "$currentCloudCover%", Colors.grey),
                    _buildWeatherParameter("🌧️ Curah Hujan", "${currentRain} mm", Colors.blueAccent),
                    _buildWeatherParameter("🧭 Arah Angin", "${currentWindDirection}°", Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Grafik suhu
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights_rounded, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      "Grafik Suhu 12 Jam ke Depan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: chartData.reduce((a, b) => a < b ? a : b) - 2,
                      maxY: chartData.reduce((a, b) => a > b ? a : b) + 2,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey[300],
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                "${value.toInt()}°",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 25,
                            getTitlesWidget: (value, meta) {
                              int i = value.toInt();
                              if (i >= timeLabels.length) return const Text("");
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  timeLabels[i],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          spots: List.generate(
                            chartData.length,
                            (i) => FlSpot(i.toDouble(), chartData[i]),
                          ),
                          dotData: FlDotData(show: true),
                          color: Colors.blueAccent,
                          gradient: LinearGradient(
                            colors: [Colors.blue[700]!, Colors.lightBlue[400]!],
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [Colors.blue[50]!, Colors.lightBlue[50]!],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // List data detail per jam
        Text(
          "Prediksi Per Jam",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(12, (index) => 
          Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.lightBlue[400]!],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getWeatherIcon(temps[index].toDouble(), humidity[index].toDouble(), precipitationProb[index].toDouble()),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                timeLabels[index],
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🌡️ ${temps[index]}°C • 💧 ${humidity[index]}%"),
                  Text("🌧️ ${precipitationProb[index]}% • 💨 ${windSpeed[index]} km/h"),
                  Text("☁️ ${cloudCover[index]}% • 🌧️ ${rain[index]} mm"),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${temps[index]}°",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    _getWindDirection(windDirection[index].toDouble()),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        )
      ],
    );
  }

  Widget _buildWeatherParameter(String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            _getParameterIcon(title),
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getParameterIcon(String title) {
    switch (title) {
      case "💧 Kelembaban":
        return Icons.water_drop;
      case "🌧️ Prob. Hujan":
        return Icons.beach_access;
      case "💨 Angin":
        return Icons.air;
      case "☁️ Awan":
        return Icons.cloud;
      case "🌧️ Curah Hujan":
        return Icons.water_damage;
      case "🧭 Arah Angin":
        return Icons.explore;
      default:
        return Icons.info;
    }
  }

  String _getWindDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'U';
    if (degrees >= 22.5 && degrees < 67.5) return 'TL';
    if (degrees >= 67.5 && degrees < 112.5) return 'T';
    if (degrees >= 112.5 && degrees < 157.5) return 'TG';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'BD';
    if (degrees >= 247.5 && degrees < 292.5) return 'B';
    if (degrees >= 292.5 && degrees < 337.5) return 'BL';
    return '-';
  }

  IconData _getWeatherIcon(double temp, double humidity, double precipitationProb) {
    if (precipitationProb > 70) return Icons.thunderstorm;
    if (precipitationProb > 40) return Icons.beach_access;
    if (temp > 30) return Icons.wb_sunny;
    if (temp > 25) return Icons.wb_cloudy;
    if (humidity > 80) return Icons.water_drop;
    return Icons.cloud;
  }

  Widget _buildEmptyState() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Data cuaca tidak tersedia",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Coba cari lokasi lain atau periksa koneksi internet",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: fetchWeather,
              icon: Icon(Icons.refresh),
              label: Text("Coba Lagi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}