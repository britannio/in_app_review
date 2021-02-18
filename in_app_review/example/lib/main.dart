import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

void main() => runApp(MyApp());

enum Availability { LOADING, AVAILABLE, UNAVAILABLE }

extension on Availability {
  String stringify() => this.toString().split('.').last;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final InAppReview _inAppReview = InAppReview.instance;
  String _appStoreId = '';
  String _microsoftStoreId = '';
  Availability _availability = Availability.LOADING;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      try {
        final isAvailable = await _inAppReview.isAvailable();

        setState(() {
          _availability = isAvailable && !Platform.isAndroid
              ? Availability.AVAILABLE
              : Availability.UNAVAILABLE;
        });
      } catch (e) {
        setState(() => _availability = Availability.UNAVAILABLE);
      }
    });
  }

  void _setAppStoreId(String id) => _appStoreId = id;

  void _setMicrosoftStoreId(String id) => _microsoftStoreId = id;

  Future<void> _requestReview() => _inAppReview.requestReview();

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: _appStoreId,
        microsoftStoreId: _microsoftStoreId,
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('InAppReview Example')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('InAppReview status: ${_availability.stringify()}'),
            TextField(
              onChanged: _setAppStoreId,
              decoration: InputDecoration(hintText: 'App Store ID'),
            ),
            TextField(
              onChanged: _setMicrosoftStoreId,
              decoration: InputDecoration(hintText: 'Microsoft Store ID'),
            ),
            ElevatedButton(
              onPressed: _requestReview,
              child: Text('Request Review'),
            ),
            ElevatedButton(
              onPressed: _openStoreListing,
              child: Text('Open Store Listing'),
            ),
          ],
        ),
      ),
    );
  }
}
