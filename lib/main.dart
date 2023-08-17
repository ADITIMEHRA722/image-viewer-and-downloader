

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:img_app/screens/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:io';

import 'package:share/share.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Viewer & Downloader',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: ImageDownloader(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imageUrl = "";
  String imagePath = "";

  Future<void> downloadImage() async {
    if (imageUrl.isEmpty) {
      return;
    }

    var response = await http.get(Uri.parse(imageUrl));
    var status = await Permission.storage.request();

    if (status.isGranted) {
      var appDir = await getExternalStorageDirectory();
      var file = File("${appDir!.path}/downloaded_image.jpg");
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        imagePath = file.path;
      }); 
    } else {
      print("Permission denied");
    }
  }

  // Future<void> shareImage() async {
  //   if (imagePath.isNotEmpty) {
  //     await Share.file(
  //       'Share via',
  //       'downloaded_image.jpg',
  //       File(imagePath).readAsBytesSync(),
  //       'image/jpeg',
  //       text: 'Check out this image!',
  //     );
  //   }
  // }
Future<void> shareImage() async {
  if (imagePath.isNotEmpty) {
    final file = File(imagePath);
    await Share.shareFiles(
      [file.path],
      text: 'Check out this image!',
      subject: 'Image Shared',
    );
  }
}


// Future<void> shareImage() async {
//   if (imagePath.isNotEmpty) {
//     final imageFile = File(imagePath);
//     await Share.share(
//       'Check out this image!',
//       subject: 'Image Shared',
//       // You can share a single file or a list of files
//       // Here we are sharing a single image file
//       sharePositionOrigin: Rect.fromCenter(
//         center: Offset(0, 0),
//         width: 100,
//         height: 100,
//       ),
//       // Here, you need to provide a list of files, even if it's a single file
//       // In this case, we're sharing just one image file
//       files: [imageFile.path],
//     );
//   }
// }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Viewer & Downloader"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: imagePath.isNotEmpty
                  ? Image.file(File(imagePath), fit: BoxFit.cover)
                  : imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Placeholder(),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    imageUrl = value;
                    imagePath = "";
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => downloadImage(),
                  child: Text("Download Image"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => shareImage(),
                  child: Text("Share Image"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
