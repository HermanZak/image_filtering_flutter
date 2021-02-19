import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:photofilters/photofilters.dart';

import '../../static/string.dart';
import '../photo_filter/custom_photo_filter.dart';
import '../pick_image/widgets/pick_image_button.dart';

class PickImageScreen extends StatefulWidget {
  @override
  _PickImageScreenState createState() => _PickImageScreenState();
}

class _PickImageScreenState extends State<PickImageScreen> {
  String fileName;
  List<Filter> filters = presetFiltersList;
  File imageFile;

  Future<void> _getImage(BuildContext context) async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    fileName = basename(imageFile.path);
    var image = imageLib.decodeImage(imageFile.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
    Map imageFileFiltered = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomPhotoFilterSelector(
          title: Text(AppStrings.appName),
          filters: filters,
          image: image,
          filename: fileName,
        ),
      ),
    );

    if (imageFileFiltered != null &&
        imageFileFiltered.containsKey('image_filtered')) {
      setState(() {
        imageFile = imageFileFiltered['image_filtered'];
      });
      print(imageFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
      ),
      body: Center(
        child: Container(
          child: imageFile == null
              ? Center(
                  child: Text(AppStrings.noImageSelected),
                )
              : Image.file(imageFile),
        ),
      ),
      floatingActionButton: PickImageButton(getImage: _getImage),
    );
  }
}
