import 'package:flutter/material.dart';

void main() {
  runApp(const WattWiseApp());
}

class WattWiseApp extends StatelessWidget {
  const WattWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WattWise - Pemantauan Konsumsi Listrik',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WattWiseHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WattWiseHomePage extends StatefulWidget {
  const WattWiseHomePage({super.key});

  @override
  State<WattWiseHomePage> createState() => _WattWiseHomePageState();
}

class _WattWiseHomePageState extends State<WattWiseHomePage> {
  final double _tarifPerKwh = 1444.70;

  final List<Map<String, dynamic>> _peralatanList = [
    {'id': '1', 'nama': 'Kipas Angin', 'daya': 50, 'durasi': 8},
    {'id': '2', 'nama': 'AC (Air Conditioner)', 'daya': 750, 'durasi': 6},
    {'id': '3', 'nama': 'Kulkas 2 Pintu', 'daya': 120, 'durasi': 24},
    {'id': '4', 'nama': 'TV LED 43 Inch', 'daya': 75, 'durasi': 5},
    {'id': '5', 'nama': 'Mesin Cuci', 'daya': 350, 'durasi': 2},
  ];

  final List<Map<String, dynamic>> _grafikKonsumsi = [
    {'hari': 'Sen', 'kwh': 12.5},
    {'hari': 'Sel', 'kwh': 15.0},
    {'hari': 'Rab', 'kwh': 11.2},
    {'hari': 'Kam', 'kwh': 14.8},
    {'hari': 'Jum', 'kwh': 13.5},
    {'hari': 'Sab', 'kwh': 18.2},
    {'hari': 'Min', 'kwh': 17.0},
  ];

  double _hitungKwhPerHari(int daya, int durasi) {
    return (daya * durasi) / 1000.0;
  }

  double _hitungBiayaBulanan(int daya, int durasi) {
    double kwhHari = _hitungKwhPerHari(daya, durasi);
    return kwhHari * 30 * _tarifPerKwh;
  }

  double get _totalBiayaBulanan {
    return _peralatanList.fold(0.0, (sum, item) {
      return sum + _hitungBiayaBulanan(item['daya'], item['durasi']);
    });
  }

  void _onTapDetail(Map<String, dynamic> item) {
    double kwhHari = _hitungKwhPerHari(item['daya'], item['durasi']);
    double biayaBulan = _hitungBiayaBulanan(item['daya'], item['durasi']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.amber),
            const SizedBox(width: 8),
            Text(item['nama']),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Daya Listrik: ${item['daya']} Watt'),
            Text('• Durasi Pakai: ${item['durasi']} Jam/Hari'),
            Text('• Konsumsi Energi: ${kwhHari.toStringAsFixed(2)} kWh/hari'),
            const Divider(),
            Text(
              '• Est. Biaya Bulanan: Rp ${biayaBulan.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '🌱 SDGs #7: Efisiensi energi untuk masa depan yang berkelanjutan.',
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _onLongPressEdit(int index) {
    final item = _peralatanList[index];
    final namaController = TextEditingController(text: item['nama']);
    final dayaController = TextEditingController(text: item['daya'].toString());
    final durasiController = TextEditingController(
      text: item['durasi'].toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Data Perangkat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Perangkat'),
            ),
            TextField(
              controller: dayaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Daya (Watt)'),
            ),
            TextField(
              controller: durasiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Durasi (Jam/Hari)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _peralatanList[index]['nama'] = namaController.text;
                  _peralatanList[index]['daya'] =
                      int.tryParse(dayaController.text) ?? item['daya'];
                  _peralatanList[index]['durasi'] =
                      int.tryParse(durasiController.text) ?? item['durasi'];
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${namaController.text} berhasil diperbarui!',
                    ),
                  ),
                );
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WattWise ⚡ Hemat Listrik'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Estimasi Biaya Listrik Bulanan',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${_totalBiayaBulanan.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tarif: Rp ${_tarifPerKwh.toStringAsFixed(0)} / kWh',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grafik Konsumsi Listrik Mingguan (kWh)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _grafikKonsumsi.map((data) {
                            final double kwh = data['kwh'];
                            final double heightFactor = (kwh / 20.0).clamp(
                              0.1,
                              1.0,
                            );

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${kwh.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 24,
                                  height: 90 * heightFactor,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade600,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  data['hari'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Perangkat Listrik',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${_peralatanList.length} Item',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Text(
                '• Tap: Lihat Detail | Long Press: Edit | Drag: Urutkan Posisi',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(
              height: 350,
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _peralatanList.length,
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _peralatanList.removeAt(oldIndex);
                    _peralatanList.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final item = _peralatanList[index];
                  double biaya = _hitungBiayaBulanan(
                    item['daya'],
                    item['durasi'],
                  );

                  return Card(
                    key: ValueKey(item['id']),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _onTapDetail(item),
                      onLongPress: () => _onLongPressEdit(index),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Icons.electrical_services,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        title: Text(
                          item['nama'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item['daya']} W • ${item['durasi']} Jam/Hari',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rp ${biaya.toStringAsFixed(0)}/bln',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.drag_handle, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
