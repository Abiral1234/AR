import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:collection/collection.dart';

import '../widgets/clear_button.dart';

class MeasurePage extends StatefulWidget {
  const MeasurePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MeasurePageState createState() => _MeasurePageState();
}

class _MeasurePageState extends State<MeasurePage> {
  late ARKitController arkitController;
  List<String> allNodeNames = [];
  List<String> allDistanceNodeNames = [];
  List<String> allLineNames = [];
  vector.Vector3? lastPosition;
  bool _isVisible = true; // Controls visibility
  String? cubeName;

  void _toggleVisibility() {
    if (_isVisible) removeCube();
    if (!_isVisible) addCube();
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('AR Measurement App'),
      ),
      body: Stack(
        children: [
          ARKitSceneView(
            enableTapRecognizer: true,
            onARKitViewCreated: onARKitViewCreated,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    ClearButton(
                      deleteAllPoints: deleteAllPoints,
                    ),
                    ElevatedButton(
                      onPressed: _toggleVisibility,
                      child: Text(_isVisible ? 'Hide Object' : 'Show Object'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ));
  addCube() {
    final cube = ARKitBox(
      width: 0.0508, //0.0508 meter = 2 inches
      height: 0.0508,
      length: 0.0508,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(Colors.blue),
        ),
      ],
    );

    final node = ARKitNode(
      geometry: cube,
      position: vector.Vector3(0, 0, -0.5), // Places cube 0.5m in front
    );

    arkitController.add(node);
    cubeName = node.name;
  }

  removeCube() {
    arkitController.remove(cubeName!);
  }

  //This function is called when AR View is created and also this function adds a cube
  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    final cube = ARKitBox(
      width: 0.0508, //0.0508 meter = 2 inches
      height: 0.0508,
      length: 0.0508,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(Colors.blue),
        ),
      ],
    );

    final node = ARKitNode(
      geometry: cube,
      position: vector.Vector3(0, 0, -0.5), // Places cube 0.5m in front
    );

    arkitController.add(node);
    cubeName = node.name;
    this.arkitController.onARTap = (ar) {
      final point = ar.firstWhereOrNull(
        (o) => o.type == ARKitHitTestResultType.featurePoint,
      );
      if (point != null) {
        _onARTapHandler(point);
      }
    };
  }

  void _onARTapHandler(ARKitTestResult point) {
    final position = vector.Vector3(
      point.worldTransform.getColumn(3).x,
      point.worldTransform.getColumn(3).y,
      point.worldTransform.getColumn(3).z,
    );
    final material = ARKitMaterial(
        lightingModelName: ARKitLightingModel.constant,
        diffuse: ARKitMaterialProperty.color(Colors.blue));
    final sphere = ARKitSphere(
      radius: 0.006,
      materials: [material],
    );
    final node = ARKitNode(
      geometry: sphere,
      position: position,
    );
    arkitController.add(node);
    allNodeNames.add(node.name);
    if (lastPosition != null) {
      final line = ARKitLine(
        fromVector: lastPosition!,
        toVector: position,
      );
      final lineNode = ARKitNode(geometry: line);
      arkitController.add(lineNode);
      allLineNames.add(lineNode.name);

      final distance = _calculateDistanceBetweenPoints(position, lastPosition!);
      final point = _getMiddleVector(position, lastPosition!);
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
          diffuse: ARKitMaterialProperty.color(Colors.red),
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
    allDistanceNodeNames.add(node.name);
  }

  deleteAllPoints() {
    for (int k = 0; k < allNodeNames.length; k++) {
      arkitController.remove(allNodeNames[k]);
    }
    for (int j = 0; j < allDistanceNodeNames.length; j++) {
      arkitController.remove(allDistanceNodeNames[j]);
    }
    for (int i = 0; i < allLineNames.length; i++) {
      arkitController.remove(allLineNames[i]);
    }
  }
}
