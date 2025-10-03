import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key}); // <- ini betul

  @override
  Widget build(BuildContext context) {
    var data_kota = [
      "Cirebon",
      "Jakarta",
      "Bogor",
      "Depok",
      "Bekasi",
      "Bandung",
      "Karawang",
    ];
    return Scaffold( // jangan bungkus MaterialApp lagi
      appBar: AppBar(title: const Text("Halaman Baru")),
      body: ListView.separated(
        itemBuilder: (_, idx) {
          return ListTile(
            title: Text(data_kota[idx]),
            subtitle: const Text("Jawa Barat, Indonesia"),
            leading: const Icon(Icons.location_on, color: Colors.red),
          );
        },
        separatorBuilder: (_, idx) => const Divider(),
        itemCount: data_kota.length,
      ),
    );
  }
}
