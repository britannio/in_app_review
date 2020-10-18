import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final InAppReview _inAppReview = InAppReview.instance;
  String _appStoreId = '';
  String _windowsProductId = '';
  bool _isAvailable;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isIOS || Platform.isMacOS || Platform.isWindows) {
        _inAppReview.isAvailable().then((bool isAvailable) {
          setState(() {
            _isAvailable = isAvailable;
          });
        });
      } else {
        setState(() {
          _isAvailable = false;
        });
      }
    });
  }

  void _setAppStoreId(String id) => _appStoreId = id;

  void _setWindowsProductId(String id) => _windowsProductId = id;

  Future<void> _requestReview() => _inAppReview.requestReview();

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: _appStoreId,
        windowsProductId: _windowsProductId,
      );

  @override
  Widget build(BuildContext context) {
    const loadingMessage = 'LOADING';
    const availableMessage = 'AVAILABLE';
    const unavailableMessage = 'UNAVAILABLE';

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('InAppReview Example')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'InAppReview status: ${_isAvailable == null ? loadingMessage : _isAvailable ? availableMessage : unavailableMessage}',
            ),
            TextField(
              onChanged: _setAppStoreId,
              decoration: InputDecoration(hintText: 'App Store ID'),
            ),
            TextField(
              onChanged: _setWindowsProductId,
              decoration: InputDecoration(hintText: 'Windows Product ID'),
            ),
            RaisedButton(
              onPressed: _requestReview,
              child: Text('Request Review'),
            ),
            RaisedButton(
              onPressed: _openStoreListing,
              child: Text('Open Store Listing'),
            ),
          ],
        ),
      ),
    );
  }
}
