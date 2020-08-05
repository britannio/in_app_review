import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final InAppReview _inAppReview = InAppReview.instance;
  String _appStoreId = '';

  void _setAppStoreId(String id) => _appStoreId = id;

  Future<void> _requestReview() async {
    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
    }
  }

  Future<void> _openStoreListing() =>
      _inAppReview.openStoreListing(iOSAppStoreId: _appStoreId);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('InAppReview Example')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: _setAppStoreId,
              decoration: InputDecoration(hintText: 'IOS App Store ID'),
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
