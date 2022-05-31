import 'dart:convert';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:http/http.dart' as http;

class Point {
  final String jrs;
  final int taux;
  final MaterialColor couleur;

  Point({required this.jrs, required this.taux, required this.couleur});
}

class Stats extends StatefulWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  List<Point> pointsData = [];

  String? blad;
  double mlat = 51.5;
  double mlng = -0.09;

  final GeocodingPlatform _geocodingPlatform = GeocodingPlatform.instance;
  String _isoCountryCode = "";

  Future<String?> _getLocationAddress(double latitude, double longitude) async {
    try {
      List<Placemark> newPlace = await _geocodingPlatform
          .placemarkFromCoordinates(latitude, longitude);
      Placemark placeMark = newPlace[0];
      String? country = placeMark.country;
      _isoCountryCode = placeMark.isoCountryCode!;
      return "$country";
    } catch (e) {
      return e.toString();
    }

    //String? name = placeMark.name;
    // String subLocality = placeMark.subLocality;
    ////String? locality = placeMark.locality;
    ////String? administrativeArea = placeMark.administrativeArea;
    // String subAdministrativeArea = placeMark.administrativeArea;
    ////String? postalCode = placeMark.postalCode;

    // String subThoroughfare = placeMark.subThoroughfare;
    ////String? thoroughfare = placeMark.thoroughfare;

    //print("$name, $country");
    ////print("$name, $thoroughfare, $locality, $administrativeArea, $postalCode, $country");
    ////return "$name, $thoroughfare, $locality, $administrativeArea, $postalCode, $country";
  }

  Future<void> getData(String country) async {
    var response = await http
        .get(Uri.https('api.covid19api.com', 'live/country/' + country));
    var jsonData = jsonDecode(response.body);
    pointsData.clear();
    for (int i = 0, j = 8; i < 8; i++, j--) {
      var s = jsonData[i];
      if (j == 1) {
        pointsData.insert(
            i, Point(jrs: "j", taux: s['Confirmed'], couleur: Colors.blue));
      } else {
        pointsData.insert(
            i, Point(jrs: "j-$j", taux: s['Confirmed'], couleur: Colors.blue));
      }
    }
    for (int i1 = 0; i1 < pointsData.length; i1++) {
      print(pointsData[i1].taux);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Series<Point, String>> series = [
      Series(
          data: pointsData,
          domainFn: (Point p, _) => p.jrs,
          id: 'Confirmed',
          measureFn: (Point p, _) => p.taux),
    ];

    return GestureDetector(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: BarChart(series,animate: true,),
            ),
            Expanded(
              flex: 2,
              child: FlutterMap(
                options: MapOptions(
                  boundsOptions: const FitBoundsOptions(),
                  onTap: (pos, ll) {
                    mlat = ll.latitude;
                    mlng = ll.longitude;
                    _getLocationAddress(ll.latitude, ll.longitude).then((value) {
                      blad = value.toString();
                      getData(blad!).then((value) {
                        setState(() {
                          print("DONE");
                        });
                      });
                    });
                  },
                  center: latLng.LatLng(51.5, -0.09),
                  zoom: 3.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: "https://api.mapbox.com/styles/v1/aminov31/"
                        "cl0xukyvu009p14oe0k372e4s/tiles/256/{z}/{x}/{y}@2x?access_token="
                        "pk.eyJ1IjoiYW1pbm92MzEiLCJhIjoiY2wweHR3am9uMTdnazNpa2J4ZjAzcWd5aiJ9.VSf81zt3xC4O_5smvvAc8w",
                    additionalOptions: {
                      'accessToken':
                          'pk.eyJ1IjoiYW1pbm92MzEiLCJhIjoiY2wweHR3am9uMTdnazNpa2J4ZjAzcWd5aiJ9.VSf81zt3xC4O_5smvvAc8w',
                      'id': 'mapbox.country-boundaries-v1'
                    }, /*
                    attributionBuilder: (_) {
                      return const Text("© OpenStreetMap contributors");
                    },*/
                  ),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: latLng.LatLng(mlat, mlng),
                        builder: (ctx) => const Icon(
                          Icons.pin_drop,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
