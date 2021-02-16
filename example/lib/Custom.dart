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

  vector.Vector3 lastPosition;

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
            enableTapRecognizer: true,
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

    this.arkitController.onAddNodeForAnchor = _handleAddAnchor;

    //3D Mesuring
    this.arkitController.onARTap = (ar) {
      final point = ar.firstWhere(
        (o) => o.type == ARKitHitTestResultType.featurePoint,
        orElse: () => null,
      );
      if (point != null) {
        _onARTapHandler(point);
      }
    };
  }

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
        print(anchor);
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
    }
    ;
    //if seeing a ground
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
    print(node.geometry);
    controller.add(node, parentNodeName: anchor.nodeName);

  }

  // Adding messuring system
  void _onARTapHandler(ARKitTestResult point) {
    final position = vector.Vector3(
      point.worldTransform.getColumn(3).x,
      point.worldTransform.getColumn(3).y,
      point.worldTransform.getColumn(3).z,
    );
    print(point.distance);
    final material = ARKitMaterial(
        lightingModelName: ARKitLightingModel.constant,
        diffuse: ARKitMaterialProperty(color: Colors.blue));
    final sphere = ARKitSphere(
      radius: 0.006,
      materials: [material],
    );
    final node = ARKitNode(
      geometry: sphere,
      position: position,
    );
    arkitController.add(node);

    if (lastPosition != null) {
      final line = ARKitLine(
        fromVector: lastPosition,
        toVector: position,
      );
      final lineNode = ARKitNode(geometry: line);
      arkitController.add(lineNode);

      final distance = _calculateDistanceBetweenPoints(position, lastPosition);
      final point = _getMiddleVector(position, lastPosition);
      _drawText(distance, point);
    }
    lastPosition = position;
  }

  String _calculateDistanceBetweenPoints(vector.Vector3 A, vector.Vector3 B) {
    final length = A.distanceTo(B);
    return '${(length * 100).toStringAsFixed(2)} cm';
  }

  vector.Vector3 _getMiddleVector(vector.Vector3 A, vector.Vector3 B) {
    return vector.Vector3((A.x + B.x) / 2, (A.y + B.y) / 2, (A.z + B.z) / 2);
  }

  void _drawText(String text, vector.Vector3 point) {
    final textGeometry = ARKitText(
      text: text,
      extrusionDepth: 1,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty(color: Colors.red),
        )
      ],
    );
    const scale = 0.001;
    final vectorScale = vector.Vector3(scale, scale, scale);
    final node = ARKitNode(
      geometry: textGeometry,
      position: point,
      scale: vectorScale,
    );
    arkitController.add(node);
  }
}
