import 'dart:async';


import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

//import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../reusable_widgets/circular_button.dart';
import '../reusable_widgets/history.dart';
import '../reusable_widgets/popuo_box.dart';
import '../splash_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  String stAddress = '';
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;

  final _dropdownFormKey = GlobalKey<FormState>();

  List<String> selectedItems = [];

  MapType _currentMapType = MapType.normal;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;
  CollectionReference urlcollections =
      FirebaseFirestore.instance.collection('urls');
  @override
  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }
  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457
    long = position.longitude.toString();
    lat = position.latitude.toString();

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
      });
  }

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

   blackThemeGoogleMap()
  {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  void initState() {
    super.initState();
    checkGps();
    checkIfLocationPermissionAllowed();
  }

  //endregion

  //region Widgets
  Widget _buildMap() {
    return GoogleMap(

      // gestureRecognizers: Set()
      //   ..add(Factory<OneSequenceGestureRecognizer>(
      //       () => new EagerGestureRecognizer()))
      //   ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
      //   ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
      //   ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
      //   ..add(Factory<VerticalDragGestureRecognizer>(
      //       () => VerticalDragGestureRecognizer())),
      padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
      mapType: _currentMapType,
      mapToolbarEnabled: true,
      scrollGesturesEnabled: true,
      myLocationEnabled: true,
      compassEnabled: true,
      zoomControlsEnabled: true,
      
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controllerGoogleMap.complete(controller);
        newGoogleMapController = controller;

        //for black theme google map
       

        setState(() {
          bottomPaddingOfMap = 240;
        });
          blackThemeGoogleMap();
        locateUserPosition();
      },
    );
  }

  Widget _buildBody() {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: width / 30, vertical: height / 30),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircularButton(
                        icon: Icons.qr_code_scanner, onTap: () => _scanQR()
                        //Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>  HomePage(uid: '',)))))
                        ),
                    SizedBox(height: height / 80),
                    CircularButton(
                        icon: Icons.info,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const HistoryPage(
                                  uid: '',
                                )))),
                    SizedBox(height: height / 80),
                    CircularButton(
                        icon: Icons.power_settings_new,
                        onTap: ()=>showExitPopup(context),
//                       {
//  _auth.signOut();
//                   Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const SplashScreen()),
//                       (route) => false);

//                       }
),
                    SizedBox(height: height / 80),
                    CircularButton(
                        icon: Icons.layers, onTap: () => mapetype(context)),
                    SizedBox(height: height / 80),
                    CircularButton(
                        icon: Icons.add_box, onTap: () => dropdown(context)),
                    SizedBox(height: height / 80),
                    
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 300),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: (() => locateUserPosition()),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text("Lon: $long",
                      style: const TextStyle(
                          fontSize: 15,
                          backgroundColor: Colors.white,
                          color: Colors.black)),
                  const SizedBox(width: 5),
                  Text(
                    "Lat: $lat",
                    style: const TextStyle(
                        fontSize: 15,
                        backgroundColor: Colors.white,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [ _buildMap(),
          SizedBox(height: 0,),
           _buildBody()],
),
      ),
    );
  }

  Future mapetype(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              alignment: Alignment.centerRight,
              content: Container(
                height: 400,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.rectangle, color: Colors.white),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.my_location,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          this.setState(() {
                            this._currentMapType=MapType.none;
                            // _currentMapType =
                            //     (_currentMapType == MapType.normal)
                            //         ? MapType.none
                            //         : MapType.normal;
                            Navigator.of(context).pop();
                          });
                        },
                        child:
                            Text("None", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                      ),
                     const  SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        onPressed: () {
                      this.setState(() {
                            // _currentMapType =
                            //     (_currentMapType == MapType.normal)
                            //         ? MapType.normal
                            //         : MapType.normal;
                            this._currentMapType=MapType.normal;
                            Navigator.of(context).pop();
                          });
                        },
                        child: Text("Normal",
                            style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          this.setState(() {
                            // _currentMapType =
                            //     (_currentMapType == MapType.normal)
                            //         ? MapType.satellite
                            //         : MapType.normal;
                             this._currentMapType=MapType.satellite;
                            Navigator.of(context).pop();
                          });
                        },
                      child: Text("Setellite",
                            style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                      ),
                       const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          this.setState(() {
                            // _currentMapType =
                            //     (_currentMapType == MapType.normal)
                            //         ? MapType.terrain
                            //         : MapType.normal;
                            this._currentMapType=MapType.terrain;
                            Navigator.of(context).pop();
                          });
                        },
                       child: Text("Terrain",
                            style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          this.setState(() {
                            // _currentMapType =
                            //     (_currentMapType == MapType.normal)
                            //         ? MapType.hybrid
                            //         : MapType.normal;
                            this._currentMapType=MapType.hybrid;
                            Navigator.of(context).pop();
                          });
                        },
                        child: Text("Hybrid",
                            style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                      ),
                    ]),
              ));
        });
  }

  Future<void> _scanQR() async {
    {
      var qrResult = await BarcodeScanner.scan();
      setState(
        () {
          urlcollections.doc().collection('url').add(
            {
              'url': qrResult.rawContent,
              'time': DateTime.now(),
            },
          );
        },
      );
    }
  }

  Future dropdown(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              alignment: Alignment.topRight,
              content: Container(
                height: 400,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Add Marker',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              const SizedBox(height: 5),
                              TextField(
                                controller: namecontroller,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(9),
                                    // Given Hint Text
                                    hintText: 'Name',
                                    border: OutlineInputBorder(
                                      // Given border to textfield
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                              ),
                              const SizedBox(height: 5),
                              // textfield1 for taking input as latitude
                              TextField(
                                controller: latitudeController,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(9),
                                    // Given Hint Text
                                    hintText: 'Latitude',
                                    border: OutlineInputBorder(
                                      // Given border to textfield
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                              ),
                              const SizedBox(height: 5),

                              // textfield2 for taking input as longitude
                              TextField(
                                controller: longitudeController,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(9),
                                    // Given hint text
                                    hintText: 'Longitude',
                                    border: OutlineInputBorder(
                                      // given border to textfield
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                              ),
                              const SizedBox(height: 5),

                              DropdownButtonFormField(
                                hint: const Text('Projection'),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(9),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: const [
                                   DropdownMenuItem(
                                      child: Text("WGS"), value: '26191'),
                                  DropdownMenuItem(
                                      child: Text("Merch1"), value: '26191'),
                                  DropdownMenuItem(
                                      child: Text("Merch2"), value: "26192"),
                                  DropdownMenuItem(
                                      child: Text("Merch3"), value: "26194"),
                                  DropdownMenuItem(
                                    child: Text("Merch4"), value: "26295"),
                                ],
                                onChanged: (Object? value) {},
                              ),

                              // Given padding to the Container
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  child: Center(
                                    child: Text(stAddress),
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () async {
                                
                                  // String lat = latitudeController.text;
                                  // // stored the value of longitude in lon from textfield
                                  // String lon = longitudeController.text;

                                  // var pointSrc = const Point(
                                  //     x: 17.888058560281515,
                                  //     y: 46.89226406700879);
                                  // var projSrc = Projection.get('EPSG:4326')!;
                                  // // converted the lat from string to double
                                  // var projDst = Projection.get('EPSG:23700') ??
                                  //     Projection.add(
                                  //       'EPSG:23700',
                                  //       '+proj=somerc +lat_0=47.14439372222222 +lon_0=19.04857177777778 +k_0=0.99993 +x_0=650000 +y_0=200000 +ellps=GRS67 +towgs84=52.17,-71.82,-14.9,0,0,0,0 +units=m +no_defs',
                                  //     );
                                  // var pointForward =
                                  //     projSrc.transform(projDst, pointSrc);
                                  // print(
                                  //     'FORWARD: Transform point ${pointSrc.toArray()} from EPSG:4326 to EPSG:23700: ${pointForward.toArray()}');

                                  // var pointInverse =
                                  //     projDst.transform(projSrc, pointForward);
                                  // print(
                                  //     'INVERSE: Transform point ${pointForward.toArray()} from EPSG:23700 to EPSG:4326: ${pointInverse.toArray()}');
                                  // // INVERSE: Transform point [561651.8408065987, 172658.61998377228] from EPSG:23700 to EPSG:4326: [17.888058565574845, 46.89226406698969]

                                  // double lat_data = double.parse(lat);
                                  // // converted the lon from string to double
                                  // double lon_data = double.parse(lon);

                                  // // Passed the coordinates of latitude and longitude
                                  // final coordinates =
                                  //     Coordinates(lat_data, lon_data);
                                  // var address = await Geocoder.local
                                  //     .findAddressesFromCoordinates(
                                  //         coordinates);
                                  // var first = address.first;

                                  
                                  // setState(() {
                                  //   stAddress = first.addressLine.toString();
                                  // });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      // specified color for button
                                      color: Colors.blue,
                                    ),
                                    // given height for button
                                    height: 40,
                                    child: const Center(
                                      // on below line we have given button name
                                      child: Text(
                                        'Add',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      // specified color for button
                                      color: Colors.blue,
                                    ),
                                    // given height for button
                                    height: 40,
                                    child: const Center(
                                      // on below line we have given button name
                                      child: Text(
                                        'Exist',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
              ));
        });
  }
}
