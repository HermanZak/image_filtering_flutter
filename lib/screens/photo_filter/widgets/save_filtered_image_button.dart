import 'package:flutter/material.dart';

class SaveFilteredImageButton extends StatelessWidget {
  final Future<void> Function() _saveFilteredImageAndPopNavigator;

  SaveFilteredImageButton({
    @required Future<void> Function() saveFilteredImageAndPopNavigator,
  }) : _saveFilteredImageAndPopNavigator = saveFilteredImageAndPopNavigator;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.check),
      onPressed: _saveFilteredImageAndPopNavigator,
    );
  }
}
