import 'dart:async';

import 'package:dikouba/model/evenement_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ShowEventLocationDialog extends StatefulWidget {
  EvenementModel evenementModel;

  ShowEventLocationDialog(this.evenementModel);

  @override
  ShowEventLocationDialogState createState() => ShowEventLocationDialogState();
}

class ShowEventLocationDialogState extends State<ShowEventLocationDialog> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kGooglePlex;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  LatLng eventLatLng;

  void _addEventMarker() {
    var markerIdVal = new DateTime.now().millisecondsSinceEpoch;
    final MarkerId markerId = MarkerId(markerIdVal.toString());

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: eventLatLng,
      infoWindow: InfoWindow(
          title: 'Lieu de l\'evenement',
          snippet: '${widget.evenementModel.title}'),
      onTap: () {
        // print("_addEventMarker");
      },
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  @override
  void initState() {
    super.initState();

    eventLatLng = LatLng(double.parse(widget.evenementModel.location.latitude),
        double.parse(widget.evenementModel.location.longitude));
    _kGooglePlex = CameraPosition(
      target: eventLatLng,
      zoom: 16,
    );
    _addEventMarker();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new Scaffold(
      /*appBar: new AppBar(
        title: Text("Localisation de l'evenement",
            style: themeData.appBarTheme.textTheme.headline6),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Material(
                child: InkWell(
                    onTap: () {
                      saveForm(context);
                    },
                    child: Icon(MdiIcons.check))),
          )
        ],
      ),*/
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 6, right: 6),
        child: GoogleMap(
          mapType: MapType.normal,
          buildingsEnabled: true,
          compassEnabled: true,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          markers: Set<Marker>.of(markers.values),
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }

  void saveForm(BuildContext buildContext) {
    Navigator.of(buildContext).pop();
  }
}
