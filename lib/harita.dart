import 'package:depremharita/Firebase%C4%B0slemler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as Ltlng;



class harita extends StatefulWidget {
  const harita({Key? key}) : super(key: key);

  @override
  State<harita> createState() => _haritaState();
}

class _haritaState extends State<harita> {
  bool devammi = true;
  FirebaseIslemler firestoreIslemler = FirebaseIslemler ();

  List<Polygon> poligonlar = [];
  List<Marker> markers = [];
  List<Ltlng.LatLng> polygonPoints = [];
  List<String> hasarDurum = ['Ağır Hasarlı', 'Orta Hasarlı', 'Hasarsız'];
  String dropdownValue = 'Ağır Hasarlı';
  TextEditingController binaAdiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPolygons();
  }

  Future<void> _fetchPolygons() async {
    List<Polygon> polygons = await polygonlarrrr();
    setState(() {
      poligonlar = polygons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(

        title: Center(
          child: Text(
            'Turan Ayhan(02220201909)',
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.yellow,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.location_pin),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(

        child: ListView(

          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.yellow,
              ),
              child: Text(
                'Bina bilgileri',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
            ),
            ListTile(
              title: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'İşaretli Yerleri Kaldır',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 16.0,
                    ),
                  ],
                ),
              ),
              onTap: () {
                markerReset();
              },
            ),
            ListTile(
              title: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'İşaretli Yerleri Kaydet',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Icon(
                      Icons.save,
                      color: Colors.green,
                      size: 16,
                    ),
                  ],
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    actions: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: binaAdiController,
                              decoration: InputDecoration(
                                labelText: 'Bina Adı',
                              ),
                            ),
                            SizedBox(height: 10),
                            DropdownButton<String>(
                              value: dropdownValue,
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownValue = value!;
                                });
                              },
                              items: hasarDurum.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              hint: Text('Hasar Durumu Seçiniz'),
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24.0,
                              isExpanded: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        child: ElevatedButton(
                          onPressed: () {
                            if (polygonPoints.isNotEmpty &&
                                dropdownValue.isNotEmpty &&
                                binaAdiController.text.isNotEmpty) {
                              _showConfirmationDialog(context);
                            } else {
                              print(
                                'Lütfen haritaya tıklayın, hasar durumu ve bina adını girin',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          child: Text("Kaydet", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                    title: const Text("Kaydetme İşlemi"),
                    contentPadding: const EdgeInsets.all(20.0),
                  ),
                );
              },
            ),

          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 80,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: FlutterMap(
                    options: MapOptions(
                      center: Ltlng.LatLng(38.329788, 38.447503),
                      zoom: 9.2,
                      onTap: haritadaTiklama,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      PolygonLayer(
                        polygons: poligonlar +
                            [
                              Polygon(
                                points: polygonPoints,
                                color: Colors.blue,
                                isFilled: true,
                              ),
                            ],
                      ),
                      MarkerLayer(
                        markers: markers,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Hayır"),
          ),
          ElevatedButton(
            onPressed: () {
              firestoreIslemler.veriEkle(
                binaAdi: binaAdiController.text,
                hasarDurumu: dropdownValue,
                konum: formatLatLngList(polygonPoints),
              );
              setState(() {
                _fetchPolygons();
              });
              markerReset();
              Navigator.of(context).pop();
            },
            child: Text("Evet"),
          ),
        ],
        title: const Text("Kaydetme İşlemi"),
        contentPadding: const EdgeInsets.all(20.0),
        content: const Text(
          "Kaydetmek istediğinize emin misiniz?",
        ),
      ),
    );
  }

  void haritadaTiklama(TapPosition tapPosition, Ltlng.LatLng tiklananNokta) {
    setState(() {
      polygonPoints
          .add(Ltlng.LatLng(tiklananNokta.latitude, tiklananNokta.longitude));
      markers.add(Marker(
        point: Ltlng.LatLng(tiklananNokta.latitude, tiklananNokta.longitude),
        width: 20.0,
        height: 20.0,
        child: const Icon(
          Icons.location_on,
          color: Colors.purple,
          size: 15.0,
        ),
      ));
    });
  }

  String parseLatLng(Ltlng.LatLng latLng) {
    return '${latLng.latitude},${latLng.longitude}';
  }

  String formatLatLngList(List<Ltlng.LatLng> points) {
    List<String> formattedPoints = [];
    for (Ltlng.LatLng point in points) {
      formattedPoints.add('${point.latitude},${point.longitude}');
    }
    return formattedPoints.join(',');
  }

  Future<List<Polygon>> polygonlarrrr() async {
    List<Map<String, dynamic>> result =
        await firestoreIslemler.hasarEkle();
    List<Polygon> bosDizi = [];
    if (result.isNotEmpty) {
      for (int i = 0; i < result.length; i++) {
        Map<String, dynamic> values = result[i];

        String hasarDurumu = values['hasarDurumu'];
        List<dynamic> coordinatesList = values['konum'];
        bosDizi.add(Polygon(
          points: pointDonder(coordinatesList),
          color: renkBelirle(hasarDurumu),
          isFilled: true,
        ));
      }
      return bosDizi;
    } else {
      return bosDizi;
    }
  }

  List<Ltlng.LatLng> pointDonder(List<dynamic> polygonlar) {
    List<Ltlng.LatLng> bosdizi = [];
    for (int i = 0; i < polygonlar.length; i += 2) {
      bosdizi.add(Ltlng.LatLng(polygonlar[i], polygonlar[i + 1]));
    }
    return bosdizi;
  }

  void markerReset() {
    setState(() {
      markers.clear();
      polygonPoints.clear();
    });
  }

  Color renkBelirle(String durum) {
    if (durum == "Ağır Hasarlı") {
      return Colors.redAccent;
    } else if (durum == "Orta Hasarlı") {
      return Colors.amberAccent;
    } else if (durum == "Hasarsız") {
      return Colors.greenAccent;
    } else {
      return Colors.brown;
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: harita(),
  ));
}
