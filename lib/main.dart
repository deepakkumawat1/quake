import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:geolocator/geolocator.dart';

//place,
class LatLong {
  double lattitude;
  double longitude;
  LatLong({this.lattitude, this.longitude});
}

void main() {
  runApp(MaterialApp(title: "quake", home: Myapp()));
}

class Myapp extends StatefulWidget {
  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  bool isLoading = true;
  @override
  void initState() {
    print("GOING TO THE CALLBCK FUNCTION");
    callbck();
    print("AFTER CALLBACK----------------------------------------");
    super.initState();
  }

  void callbck() async {
    await requestLocationPermission(context);
    print("INIIT");
    print("AFTER REQUEST LOCATION");
    clculatedstanfn();
    print("CAL");
    await fetchingdatafromjson();
    print("FETCHING DATA");
    setState(() {
      isLoading = false;
      print("you are in the set state");
    });
  }

  Position position = null;
  List<Position> obj = new List();

  Future<void> requestLocationPermission(BuildContext context) async {
    Position currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    position = currentPosition;
    //  setState(() {
    //     position = currentPosition;
    //   });
    //double distanceInMeters = await Geolocator().distanceBetween(28.628919, 77.0818569, 34.0476667, -117.291);
    //print("distance between delhi and california= $distanceInMeters");
    obj.add(position);
    int i;
    i = obj.length;
    print("Position latuiude =${obj[i - 1].longitude}");
    print(position.toString());
  }

  void clculatedstanfn() {
    print(
        "1..distance=${calculateDistance(28.7041, 77.1025, 19.0760, 72.8777)}");
  }

  List _detail = new List();
  var dateArray = [];
  DateTime date;

  List<LatLong> list = new List();
  Future<void> fetchingdatafromjson() async {
    //---------------rough-------------
    double distanceInMeters = await Geolocator()
        .distanceBetween(28.6289369, 77.0819007, 2.095, 125.4146);
    print("distance using geolocation =${(distanceInMeters / 1000)}");
    //calculateDistance(28.6289369,77.0819007,2.095,125.4146);
    print(
        "distance using formula= ${calculateDistance(28.6289369, 77.0819007, 2.095, 125.4146)}");

    //--------------rough-------------
    var details = await data();
    _detail = details['features'];
    print("all is good 3");

    var detailedInfo;
    //List<LatLong> list = new List();
    for (int i = 0; i < 5; i++) {
      detailedInfo = await data1(_detail[i]['properties']['detail']);
      // print(detailedInfo['properties']["place"]);// print("latitiude=");// print(detailedInfo['properties']['products']["origin"][0]["properties"]["latitude"]);
      LatLong latLong = new LatLong(
          lattitude: (double.parse(detailedInfo['properties']['products']
              ['origin'][0]['properties']['latitude'])),
          longitude: (double.parse(detailedInfo['properties']['products']
              ['origin'][0]['properties']['longitude'])));
      list.add(latLong);
    }
    print(
        "------------------------------------SUCCESSFULLY STORED LAT AND LONG IN THE OBJECT ---------------------");
    //print latittude and longityyude-------------------------------------------------------
    for (int i = 0; i < 5; i++) {
      print(
          "list lattitude=${list[i].lattitude} LONGITUDE= ${list[i].longitude}");
    }
    //calculate date and time from timestamp-------------------------------
    int i;

    for (int j = 0; j < _detail.length; j++) {
      for (i = 0; i < (_detail.length); i++) {
        date = new DateTime.fromMicrosecondsSinceEpoch(
            (_detail[j]["properties"]["time"] * 1000));
        //print(date.toString());
        dateArray.add(date);
        //print(dateArray);
      }
    }
    print(dateArray);

    print("successfull printed the method but not going to build method");
  }

  //print(details);
  //print("\n\n 2.. LENGTH ${_detail.length}   $_detail \n\n  \n\n");
//for data2 from detailes list-------------------------------------------------------------------------------------------

  int deta = 5;
  // print(deta);
  //print(date);
  @override
  Widget build(BuildContext context) {
    print("you are in the build method");
    print(dateArray);
    return Scaffold(
        appBar: AppBar(
          title: Text("Quake"),
          centerTitle: true,
          backgroundColor: Colors.red[500],
        ),
        body: isLoading
            ? Container()
            : ListView.builder(
                itemCount: deta,
                padding: EdgeInsets.all(10),
                itemBuilder: (BuildContext context, int index) {
                  // int i = 0;
                  // i++;
                  // print("RENDERING $i");
                  //dd=_detail[index] ["properties"]["place"];
                  return Column(
                    children: <Widget>[
                      //Text("datanjhbugg"),
                      ListTile(
                        title: Text(
                          dateArray[index].toString(),
                          //Text(_detail[index] ["properties"]["place"],

                          style: TextStyle(
                            fontSize: 17.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          _detail[index]["properties"]["place"],
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Text(
                              _detail[index]["properties"]["mag"].toString()),
                        ),
                        onTap: () {
                          setState(() {
                            requestLocationPermission(context);
                            showTapMassage(context, list[index].lattitude,
                                list[index].lattitude);
                          });
                        },
                      ),
                      Divider(
                        height: 10,
                        //thickness: 4,
                        color: Colors.red,
                      ),
                    ],
                  );
                },
              ));
  }

  void showTapMassage(BuildContext context, double lat, double long) async {
    int i = obj.length;
    double distanceInMeters = await Geolocator()
        .distanceBetween(obj[i - 1].latitude, obj[i - 1].longitude, lat, long);
    distanceInMeters = (distanceInMeters / 1000);
    var alertDialog = new AlertDialog(
      title: Text(
          "${distanceInMeters.toStringAsFixed(2)} KM FROM CURRENT LOCATION"),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("OK"),
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<Map> data() async {
    String apiurl =
        "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson";
    http.Response response = await http.get(apiurl);
    return json.decode(response.body);
  }

  Future<Map> data1(String ver) async {
    String apiurl = ver;
    http.Response response = await http.get(apiurl);
    return json.decode(response.body);
  }
}
