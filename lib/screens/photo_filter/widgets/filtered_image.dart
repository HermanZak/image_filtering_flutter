import 'package:flutter/material.dart';

class FilteredImage extends StatelessWidget {
  const FilteredImage({
    Key key,
    @required this.filteredImage,
  }) : super(key: key);

  final Widget filteredImage;

  @override
  Widget build(BuildContext context) => Expanded(
        flex: 6,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(12.0),
          child: filteredImage,
        ),
      );
}
