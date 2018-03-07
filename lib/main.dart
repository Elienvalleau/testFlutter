import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraExampleHome extends StatefulWidget {
  @override
  _CameraExampleHomeState createState() {
    return new _CameraExampleHomeState();
  }
}

IconData cameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw new ArgumentError('Unknown lens direction');
}

class _CameraExampleHomeState extends State<CameraExampleHome> {
  bool opening = false;
  CameraController controller;
  String imagePath;
  int pictureCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> headerChildren = <Widget>[];

    final List<Widget> cameraList = <Widget>[];

    if (cameras.isEmpty) {
      cameraList.add(const Text('No cameras found'));
    } else {
      for (CameraDescription cameraDescription in cameras) {
        cameraList.add(
          new SizedBox(
            width: 90.0,
            child: new RadioListTile<CameraDescription>(
              title: new Icon(cameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: (CameraDescription newValue) async {
                final CameraController tempController = controller;
                controller = null;
                await tempController?.dispose();
                controller =
                new CameraController(newValue, ResolutionPreset.high);
                await controller.initialize();
                setState(() {});
              },
            ),
          ),
        );
      }
    }

    headerChildren.add(new Column(children: cameraList));
    if (controller != null) {
      headerChildren.add(playPauseButton());
    }
    if (imagePath != null) {
      headerChildren.add(imageWidget());
    }

    final List<Widget> columnChildren = <Widget>[];
    columnChildren.add(new Row(children: headerChildren));
    if (controller == null || !controller.value.initialized) {
      columnChildren.add(const Text('Tap a camera'));
    } else if (controller.value.hasError) {
      columnChildren.add(
        new Text('Camera error ${controller.value.errorDescription}'),
      );
    } else {
      columnChildren.add(
        new Expanded(
          child: new Padding(
            padding: const EdgeInsets.all(5.0),
            child: new Center(
              child: new AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: new CameraPreview(controller),
              ),
            ),
          ),
        ),
      );
    }
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Camera example'),
      ),
      body: new Column(children: columnChildren),
      floatingActionButton: (controller == null)
          ? null
          : new FloatingActionButton(
        child: const Icon(Icons.camera),
        onPressed: controller.value.isStarted ? capture : null,
      ),
    );
  }

  Widget imageWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.centerRight,
        child: new SizedBox(
          child: new Image.file(new File(imagePath)),
          width: 64.0,
          height: 64.0,
        ),
      ),
    );
  }

  Widget playPauseButton() {
    return new FlatButton(
      onPressed: () {
        setState(
              () {
            if (controller.value.isStarted) {
              controller.stop();
            } else {
              controller.start();
            }
          },
        );
      },
      child:
      new Icon(controller.value.isStarted ? Icons.pause : Icons.play_arrow),
    );
  }

  Future<Null> capture() async {
    if (controller.value.isStarted) {
      final Directory tempDir = await getTemporaryDirectory();
      if (!mounted) {
        return;
      }
      final String tempPath = tempDir.path;
      final String path = '$tempPath/picture${pictureCount++}.jpg';
      await controller.capture(path);
      if (!mounted) {
        return;
      }
      setState(
            () {
          imagePath = path;
        },
      );
    }
  }
}

List<CameraDescription> cameras;

Future<Null> main() async {
  cameras = await availableCameras();
  runApp(new MaterialApp(home: new CameraExampleHome()));
}



//import 'dart:async';
//import 'package:flutter/material.dart';
//import 'package:camera/camera.dart';
//
//
////void main() => runApp(new MyApp());
////
////class MyApp extends StatelessWidget {
////  @override
////  Widget build(BuildContext context) {
////    return new MaterialApp(
////      title: 'Welcome to Flutter',
////      home: new Scaffold(
////        appBar: new AppBar(
////          title: new Text('Welcome to Flutter'),
////        ),
////        body: new Center(
////          child: new Text('Hello World'),
////        ),
////      ),
////    );
////  }
////}

//List<CameraDescription> cameras;
//
//Future<Null> main() async {
//  cameras = await availableCameras();
//  runApp(new CameraApp());
//}
//
//class CameraApp extends StatefulWidget {
//  @override
//  _CameraAppState createState() => new _CameraAppState();
//}
//
//
//class _CameraAppState extends State<CameraApp> {
//  CameraController controller;
//
//  @override
//  void initState() {
//    super.initState();
////    controller = new CameraController(cameras[0], ResolutionPreset.medium);  0 -> back / 1 -> front
//    controller = new CameraController(cameras[1], ResolutionPreset.medium);
//    controller.initialize().then((_) {
//      if (!mounted) {
//        return;
//      }
//      setState(() {});
//    });
//  }
//
//  @override
//  void dispose() {
//    controller?.dispose();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    if (!controller.value.initialized) {
//      return new Container();
//    }
//    return new AspectRatio(
//        aspectRatio:
//        controller.value.aspectRatio,
//        child: new CameraPreview(controller));
//  }
//}