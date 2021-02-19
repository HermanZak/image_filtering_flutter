import 'package:flutter/material.dart';

import '../../../static/string.dart';

class PickImageButton extends StatelessWidget {
  Future<void> Function(BuildContext) _getImage;

  PickImageButton({
    @required Future<void> Function(BuildContext) getImage,
  }) : _getImage = getImage;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _getImage(context),
      tooltip: AppStrings.fabPickImageTooltip,
      child: Icon(Icons.add_a_photo),
      backgroundColor: Colors.red,
    );
  }
}
