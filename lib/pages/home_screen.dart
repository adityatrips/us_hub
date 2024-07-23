import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:us_hub/core/global_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  LatLng tajMahal = const LatLng(27.1751, 78.0421);

  void _requestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
  }

  @override
  void initState() {
    _requestPermissions();
    super.initState();
  }

  Future<List<BitmapDescriptor>> _manMarker() async {
    final man = await BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/man.png",
      bitmapScaling: MapBitmapScaling.auto,
      height: 64,
      width: 64,
    );

    final woman = await BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/woman.png",
      bitmapScaling: MapBitmapScaling.auto,
      height: 64,
      width: 64,
    );

    return [man, woman];
  }

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> _controller =
        Completer<GoogleMapController>();

    return Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text(
            "UsHub",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: SlidingUpPanel(
          body: StreamBuilder(
            stream: Geolocator.getCurrentPosition().asStream(),
            builder: (context, snapshot) {
              if (snapshot.data != null &&
                  snapshot.connectionState == ConnectionState.done) {
                final distance = Geolocator.distanceBetween(
                  tajMahal.latitude,
                  tajMahal.longitude,
                  snapshot.data!.latitude,
                  snapshot.data!.longitude,
                );

                final midPoint = distance / 2;

                final midPointMarker = LatLng(
                  tajMahal.latitude +
                      (snapshot.data!.latitude - tajMahal.latitude) / 2,
                  tajMahal.longitude +
                      (snapshot.data!.longitude - tajMahal.longitude) / 2,
                );

                print("Distance: ${distance / 1000}");
                print("MidPoint: ${midPoint / 1000}");

                print(
                  "MidPointMarker: ${midPointMarker.latitude}, ${midPointMarker.longitude}",
                );

                return FutureBuilder(
                  future: _manMarker(),
                  builder: (context, futureSnap) {
                    if (futureSnap.hasData) {
                      return GoogleMap(
                        mapType: MapType.terrain,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          controller.animateCamera(
                            CameraUpdate.newLatLngBounds(
                              LatLngBounds(
                                southwest: LatLng(
                                  min(tajMahal.latitude,
                                      snapshot.data!.latitude),
                                  min(tajMahal.longitude,
                                      snapshot.data!.longitude),
                                ),
                                northeast: LatLng(
                                  max(tajMahal.latitude,
                                      snapshot.data!.latitude),
                                  max(tajMahal.longitude,
                                      snapshot.data!.longitude),
                                ),
                              ),
                              100,
                            ),
                          );
                        },
                        polylines: <Polyline>{
                          Polyline(
                            polylineId: const PolylineId("tajMahal"),
                            points: <LatLng>[
                              tajMahal,
                              LatLng(
                                snapshot.data!.latitude,
                                snapshot.data!.longitude,
                              ),
                            ],
                            jointType: JointType.round,
                            startCap: Cap.roundCap,
                            endCap: Cap.roundCap,
                            color: GlobalColors.primaryColor,
                            width: 5,
                          ),
                        },
                        markers: {
                          Marker(
                            anchor: const Offset(0.5, 0.5),
                            markerId: const MarkerId("tajMahal"),
                            position: tajMahal,
                            icon: futureSnap.data![1],
                            onTap: () {
                              _controller.future.then((controller) {
                                controller.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    tajMahal,
                                    17,
                                  ),
                                );
                              });
                            },
                          ),
                          Marker(
                            anchor: const Offset(0.5, 0.5),
                            markerId: const MarkerId("current_location"),
                            position: LatLng(
                              snapshot.data!.latitude,
                              snapshot.data!.longitude,
                            ),
                            icon: futureSnap.data![0],
                            onTap: () {
                              _controller.future.then((controller) {
                                controller.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(
                                      snapshot.data!.latitude,
                                      snapshot.data!.longitude,
                                    ),
                                    17,
                                  ),
                                );
                              });
                            },
                          ),
                          Marker(
                            anchor: const Offset(0.5, 0.5),
                            markerId: const MarkerId("between"),
                            position: midPointMarker,
                            icon: BitmapDescriptor.defaultMarker,
                            infoWindow: InfoWindow(
                              snippet: "Apart and together ❤️",
                              anchor: const Offset(0.5, 0),
                              title:
                                  "${((distance / 1000).round().toInt())} kms",
                            ),
                          )
                        },
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(0, 0),
                          zoom: 1,
                        ),
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          panel: SizedBox(),
        ));
  }
}
