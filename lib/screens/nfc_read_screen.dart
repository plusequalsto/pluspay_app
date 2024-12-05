import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NFCReadScreen extends StatefulWidget {
  @override
  _NFCReadScreenState createState() => _NFCReadScreenState();
}

class _NFCReadScreenState extends State<NFCReadScreen> {
  String _nfcData = "Waiting for NFC...";
  List<String> _ndefRecords = [];

  Future<void> _readNfcTag() async {
    try {
      // Check NFC availability
      var availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        setState(() {
          _nfcData = "NFC is not available. Please enable it in settings.";
        });
        return;
      }

      // Poll for an NFC tag
      var tag = await FlutterNfcKit.poll(
        timeout: Duration(seconds: 10),
        iosMultipleTagMessage: "Multiple tags found!",
        iosAlertMessage: "Hold your device near the NFC tag.",
      );

      setState(() {
        _nfcData = "Tag Detected: ${tag.type}";
      });

      // Read NDEF records if available
      if (tag.ndefAvailable == true) {
        var records = await FlutterNfcKit.readNDEFRecords(cached: false);
        setState(() {
          _ndefRecords = records.map((record) => record.toString()).toList();
        });
      } else {
        setState(() {
          _nfcData += "\nNo NDEF records found on the tag.";
        });
      }
    } catch (e) {
      setState(() {
        _nfcData = "Error: $e";
      });
    } finally {
      // Ensure to finish the NFC session
      await FlutterNfcKit.finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NFC Reader"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _nfcData,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _readNfcTag,
              child: Text("Start NFC Scan"),
            ),
            SizedBox(height: 20),
            if (_ndefRecords.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _ndefRecords.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.nfc),
                      title: Text(_ndefRecords[index]),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}