import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile.dart';
import 'home.dart';



void main() {
  runApp(MaterialApp(home: MyApp()));
}

class BelajarFlutter extends StatefulWidget {
  const BelajarFlutter({super.key});

  @override
  State<BelajarFlutter> createState() => _BelajarFlutterState();
}

class _BelajarFlutterState extends State<BelajarFlutter> {
  int _selectedIndex = 0;

  // daftar halaman untuk tiap menu
  static List<Widget> _pages = <Widget>[
    SingleChildScrollView( // biar bisa scroll kalau teks panjang
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image(
            image: AssetImage("assets/gedungbmkg.jpg"),
            fit: BoxFit.cover,
            height: 300,
            width: double.infinity,
          ),
          SizedBox(height: 20),

          // judul + bintang
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gedung  BMKG Kemayoran",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      Text(
                        "Kemayoran, Jakarta Pusat",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.star, color: Colors.amber, size: 30),
                SizedBox(width: 4),
                Text("120"),
              ],
            ),
          ),

          // tombol Call, Route, Share
          Padding(
            padding: EdgeInsets.only(left: 16, top: 20, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [Icon(Icons.phone), Text("Call")]),
                // ROUTE -> buka Google Maps
    InkWell(
      onTap: () async {
        final Uri url = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=-6.1525,106.8650"
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Column(
        children: const [
          Icon(Icons.navigation),
          Text("Route"),
        ],
      ),
    ),
                Column(children: [Icon(Icons.share), Text("Share")]),
              ],
            ),
          ),

          // deskripsi panjang
          Padding(
            padding: EdgeInsets.only(left: 16, top: 20, right: 16),
            child: Text(
              """Indeks tahunan tersebut menilai lebih dari 100 kota global berdasarkan 70 indikator yang terbagi dalam empat kategori utama: pengelolaan destinasi, rantai pasokan, keberlanjutan sosial, dan kinerja lingkungan. Indikatornya mencakup manajemen wisatawan, dampak lingkungan dari transportasi, keselamatan, hingga komitmen terhadap perubahan iklim. "Helsinki terus menetapkan standar baru dalam pengelolaan destinasi regeneratif. Melalui aksi iklim yang progresif, strategi berkelanjutan yang inovatif, dan komitmen kuat terhadap transparansi, kota ini menunjukkan visi yang luar biasa," CEO GDS-Movement, Guy Bigwood.

Indeks tahunan tersebut menilai lebih dari 100 kota global berdasarkan 70 indikator yang terbagi dalam empat kategori utama: pengelolaan destinasi, rantai pasokan, keberlanjutan sosial, dan kinerja lingkungan. Indikatornya mencakup manajemen wisatawan, dampak lingkungan dari transportasi, keselamatan, hingga komitmen terhadap perubahan iklim. "Helsinki terus menetapkan standar baru dalam pengelolaan destinasi regeneratif. Melalui aksi iklim yang progresif, strategi berkelanjutan yang inovatif, dan komitmen kuat terhadap transparansi, kota ini menunjukkan visi yang luar biasa," CEO GDS-Movement, Guy Bigwood.""",
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    ),
    Center(child: Text("Halaman Booking", style: TextStyle(fontSize: 20))),
    Center(child: Text("Halaman Profile", style: TextStyle(fontSize: 20))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Gedung BMKG"),
          centerTitle: true,
        ),
        body: Center(
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: "Booking",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
