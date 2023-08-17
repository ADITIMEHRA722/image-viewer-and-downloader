
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Downloader and Sharer',
      home: ImageDownloader(),
    );
  }
}

class ImageDownloader extends StatefulWidget {
  @override
  _ImageDownloaderState createState() => _ImageDownloaderState();
}

class _ImageDownloaderState extends State<ImageDownloader> {
  TextEditingController _urlController = TextEditingController();
   String? _downloadedImagePath;

  void _downloadAndShareImage() async {
    final response = await http.get(Uri.parse(_urlController.text));
    final bytes = response.bodyBytes;

    final appDir = await getApplicationDocumentsDirectory();
    final imageFile = File('${appDir.path}/downloaded_image.png');
    await imageFile.writeAsBytes(bytes);

    setState(() {
      _downloadedImagePath = imageFile.path;
    });

    Share.shareFiles([_downloadedImagePath!], text: 'Check out this image!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Downloader')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _urlController, decoration: InputDecoration(labelText: 'Enter URL')),
            SizedBox(height: 16.0),
            ElevatedButton(onPressed: _downloadAndShareImage, child: Text('Download and Share')),
            SizedBox(height: 16.0),
            if (_downloadedImagePath != null)
              Image.file(File(_downloadedImagePath!)),
          ],
        ),
      ),
    );
  }
}
