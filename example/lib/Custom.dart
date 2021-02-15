import 'dart:math' as math;
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flushbar/flushbar.dart';

import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:vector_math/vector_math_64.dart' as vector;



class CustomProject extends StatefulWidget {
  @override
  _CustomProjectState createState() => _CustomProjectState();
}

class _CustomProjectState extends State<CustomProject> {
  ARKitController arkitController;
  ARKitNode node;
  String anchorId;
  int _numberOfAnchors = 0;
  bool placing = false;

  @override
  void dispose() {
    arkitController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          child: ARKitSceneView(
            onARKitViewCreated: onARKitViewCreated,
            planeDetection: ARPlaneDetection.horizontal,
            showFeaturePoints: true,
          ),
        ),
        floatingActionButton: HoldDetector(
          onHold: () {
            placing = true;
          },
          holdTimeout: Duration(milliseconds: 200),
          enableHapticFeedback: true,
          child: FloatingActionButton(
            child: Text(
              '$_numberOfAnchors',
            ),
            onPressed: () {
              placing = false;
            },
          ),
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;

    this.arkitController.add(_createText());
    this.arkitController.add(_createCapsule());
    this.arkitController.add(_createCylinder());
    this.arkitController.add(_createTube());

    this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
  }

  ARKitNode _createText() {
    final text = ARKitText(
      text: 'Object #1',
      extrusionDepth: 1,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty(color: Colors.blue),
        )
      ],
    );
    return ARKitNode(
      geometry: text,
      position: vector.Vector3(0.04, 0.21, -0.5),
      scale: vector.Vector3(0.002, 0.002, 0.002),
    );
  }

  ARKitNode _createCylinder() => ARKitNode(
        geometry: ARKitCylinder(
            radius: 0.04, height: 0.2, materials: _createRandomColorMaterial()),
        position: vector.Vector3(-0, 0.1, -0.5),
      );

  ARKitNode _createTube() => ARKitNode(
        geometry: ARKitTube(
            innerRadius: 0.045,
            outerRadius: 0.05,
            height: 0.1,
            materials: _createRandomColorMaterial()),
        position: vector.Vector3(0, -00, -0.5),
      );

  ARKitNode _createCapsule() => ARKitNode(
        geometry: ARKitCapsule(
            capRadius: 0.02,
            height: 0.06,
            materials: _createRandomColorMaterial()),
        position: vector.Vector3(0, 0.2, -0.5),
      );

  List<ARKitMaterial> _createRandomColorMaterial() {
    return [
      ARKitMaterial(
        lightingModelName: ARKitLightingModel.physicallyBased,
        diffuse: ARKitMaterialProperty(
          color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
              .withOpacity(1.0),
        ),
      )
    ];
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitPlaneAnchor) {
      if (placing == true) {
        //if button is pressed
        _addPlane(arkitController, anchor);
        setState(() {
          _numberOfAnchors++;
        });
        Flushbar(
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(10),
          borderRadius: 8,
          backgroundGradient: LinearGradient(
            colors: [Colors.green.shade800, Colors.greenAccent.shade700],
            stops: [0.6, 1],
          ),
          boxShadows: [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(3, 3),
              blurRadius: 3,
            ),
          ],
          // All of the previous Flushbars could be dismissed by swiping down
          // now we want to swipe to the sides
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
          // The default curve is Curves.easeOut
          forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
          flushbarPosition: FlushbarPosition.TOP,
          title: 'Awesome, you just added another object',
          message:
              'Now we got $_numberOfAnchors objects placed in our environment',
        )..show(context);
      }
    } //if seeing a ground
  }

  void _addPlane(ARKitController controller, ARKitPlaneAnchor anchor) {
    anchorId = anchor.identifier;
    if (node != null) {
      // _numberOfAnchors = _numberOfAnchors-1;
    }
    // node = ARKitReferenceNode(
    //   url: 'models.scnassets/dash.dae',
    //   scale: vector.Vector3.all(1),
    // );
    node = ARKitReferenceNode(
      url: 'models.scnassets/Diplo.dae',
      scale: vector.Vector3.all(0.08),
    );
    controller.add(node, parentNodeName: anchor.nodeName);
  }
}
