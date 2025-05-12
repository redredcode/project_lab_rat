import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _cachedImageFile;
  bool _isDownloading = false;

  Future<void> _saveAndDisplayImage(String imageUrl) async {
    setState(() => _isDownloading = true);

    try {
      // download image bytes
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      // Get CACHE directory (temporary storage)
      final cacheDirectory = await getTemporaryDirectory();

      // create file name from url
      final fileName = 'cached_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print(fileName);
      final filePath = '${cacheDirectory.path}/$fileName';
      print(filePath);

      // save to cache
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _cachedImageFile = file;
        _isDownloading = false;
      });
    } catch (e) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Image Example'),
        backgroundColor: Colors.grey,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: _cachedImageFile != null
                ? Image.file(
                    _cachedImageFile!,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey,
                  ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _saveAndDisplayImage('https://th.bing.com/th/id/R.d898ba3fa0a2c24b96878ee407c256dd?rik=Ty5nx%2boQFjhZsw&riu=http%3a%2f%2fwww.maacindia.com%2fblog%2fwp-content%2fuploads%2f2016%2f08%2f69939.jpeg&ehk=07rJnqOxlj9rqlQUzTagPzjQyXcodDbz7DW%2fyMdREJA%3d&risl=&pid=ImgRaw&r=0'),
            child: Text(_isDownloading ? 'Downloading...' : 'Download & Cache'),
          ),
          if (_cachedImageFile != null)
            TextButton(
              onPressed: () {
                _cachedImageFile?.delete();
                setState(
                  () {
                    _cachedImageFile = null;
                  },
                );
              },
              child: const Text('Clear Cache'),
            ),
        ],
      ),
    );
  }
}
