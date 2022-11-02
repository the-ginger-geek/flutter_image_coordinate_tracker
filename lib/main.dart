import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_coordinate_tracker/measure_size_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image tracker demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Size imageWidgetSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset('assets/test.png');
    return Scaffold(
      appBar: AppBar(
        title: Text('Image tracker demo'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {},
          onTapDown: (details) async {
            if (imageWidgetSize != Size.zero) {
              final tapPosition = details.localPosition;
              final assetSize = await _getImageSize(imageWidget);
              final transformSize = _getTransformSize(assetSize, imageWidgetSize);

              print('widgetSize [$imageWidgetSize]');
              print('widgetTapPosition [$tapPosition]');
              print('imageSize [$assetSize]');

              final transformedX = tapPosition.dx * transformSize.width;
              final transformedY = tapPosition.dy * transformSize.height;
              print('transformedPosition[$transformedX, $transformedY]');

              setState(() {});
            }
          },
          child: MeasureSize(
            onChange: (size) {
              imageWidgetSize = size;
            },
            child: imageWidget,
          ),
        ),
      ),
    );
  }

  Future<Size> _getImageSize(Image imageWidget) async {
    Completer<ui.Image> completer = new Completer<ui.Image>();
    imageWidget.image
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));

    final ui.Image image = await completer.future;
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  Size _getTransformSize(Size assetSize, Size imageWidgetSize) {
    if (!_assetIsLarger(assetSize, imageWidgetSize)) {
      return Size(imageWidgetSize.width / assetSize.width, imageWidgetSize.height / assetSize.height);
    } else {
      return Size(assetSize.width / imageWidgetSize.width, assetSize.height / imageWidgetSize.height);
    }
  }

  bool _assetIsLarger(Size assetSize, Size imageWidgetSize) {
    return assetSize.width > imageWidgetSize.width && assetSize.height > imageWidgetSize.height;
  }
}
