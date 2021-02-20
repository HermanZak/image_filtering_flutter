import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';

import './widgets/filtered_image.dart';
import './widgets/save_filtered_image_button.dart';

///The PhotoFilterSelector Widget for apply filter from a selected set of filters
class CustomPhotoFilterSelector extends StatefulWidget {
  final Widget title;
  final List<Filter> filters;
  final imageLib.Image image;
  final Widget loader;
  final BoxFit fit;
  final String filename;
  final bool circleShape;

  const CustomPhotoFilterSelector({
    Key key,
    @required this.title,
    @required this.filters,
    @required this.image,
    this.loader = const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
      ),
    ),
    this.fit = BoxFit.fill,
    @required this.filename,
    this.circleShape = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomPhotoFilterSelectorState();
}

class _CustomPhotoFilterSelectorState extends State<CustomPhotoFilterSelector> {
  String filename;
  Map<String, List<int>> cachedFilters = {};
  Filter _filter;
  imageLib.Image image;
  bool loading;

  @override
  void initState() {
    super.initState();
    loading = false;
    _filter = widget.filters[0];
    filename = widget.filename;
    image = widget.image;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filtered_${_filter?.name ?? "_"}_$filename');
  }

  Future<File> _saveFilteredImage() async {
    var imageFile = await _localFile;
    await imageFile.writeAsBytes(cachedFilters[_filter?.name ?? "_"]);
    return imageFile;
  }

  Future<void> _saveFilteredImageAndPop() async {
    setState(() {
      loading = true;
    });
    var imageFile = await _saveFilteredImage();

    Navigator.pop(context, {'image_filtered': imageFile});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: widget.title,
          backgroundColor: Theme.of(context).primaryColor,
          actions: <Widget>[
            loading
                ? SizedBox.shrink()
                : SaveFilteredImageButton(
                    saveFilteredImageAndPopNavigator: _saveFilteredImageAndPop,
                  ),
          ],
        ),
        body: loading ? widget.loader : _buildFilterSelectorOnOrientation(),
      ),
    );
  }

  Widget _buildPortraitFilterSelectorLayout() => Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          FilteredImage(
            filteredImage: _buildFilteredImage(
              _filter,
              image,
              filename,
            ),
          ),
          _buildFiltersList(),
        ],
      );

  Widget _buildLandscapeFilterSelectorLayout() {
    return Row(
      children: [
        FilteredImage(
          filteredImage: _buildFilteredImage(
            _filter,
            image,
            filename,
          ),
        ),
        _buildFiltersList(
          scrollDirection: Axis.vertical,
        ),
      ],
    );
  }

  Widget _buildFilterSelectorOnOrientation() {
    return Container(
      color: Color(0xFFFCEBDA),
      child: OrientationBuilder(builder: (context, orientation) {
        print(orientation);
        return orientation == Orientation.portrait
            ? _buildPortraitFilterSelectorLayout()
            : _buildLandscapeFilterSelectorLayout();
      }),
    );
  }

  Widget _buildFiltersList({
    Axis scrollDirection = Axis.horizontal,
  }) =>
      Expanded(
        flex: 2,
        child: Container(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: scrollDirection,
            itemCount: widget.filters.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildFilterThumbnail(
                          widget.filters[index], image, filename),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        widget.filters[index].name,
                      )
                    ],
                  ),
                ),
                onTap: () => setState(() {
                  _filter = widget.filters[index];
                }),
              );
            },
          ),
        ),
      );

  Widget _buildFilterThumbnail(
      Filter filter, imageLib.Image image, String filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return CircleAvatar(
                radius: 50.0,
                child: Center(
                  child: widget.loader,
                ),
                backgroundColor: Colors.white,
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return CircleAvatar(
                radius: 50.0,
                backgroundImage: MemoryImage(
                  snapshot.data,
                ),
                backgroundColor: Colors.white,
              );
          }
          return null; // unreachable
        },
      );
    } else {
      return CircleAvatar(
        radius: 50.0,
        backgroundImage: MemoryImage(
          cachedFilters[filter?.name ?? "_"],
        ),
        backgroundColor: Colors.white,
      );
    }
  }

  Widget _buildFilteredImage(
      Filter filter, imageLib.Image image, String filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return widget.loader;
            case ConnectionState.active:
            case ConnectionState.waiting:
              return widget.loader;
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return widget.circleShape
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width / 3,
                      width: MediaQuery.of(context).size.width / 3,
                      child: Center(
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 3,
                          backgroundImage: MemoryImage(
                            snapshot.data,
                          ),
                        ),
                      ),
                    )
                  : Image.memory(
                      snapshot.data,
                      fit: BoxFit.contain,
                    );
          }
          return null; // unreachable
        },
      );
    } else {
      return widget.circleShape
          ? SizedBox(
              height: MediaQuery.of(context).size.width / 3,
              width: MediaQuery.of(context).size.width / 3,
              child: Center(
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 3,
                  backgroundImage: MemoryImage(
                    cachedFilters[filter?.name ?? "_"],
                  ),
                ),
              ),
            )
          : Image.memory(
              cachedFilters[filter?.name ?? "_"],
              fit: widget.fit,
            );
    }
  }
}

///The global applyfilter function
List<int> applyFilter(Map<String, dynamic> params) {
  Filter filter = params["filter"];
  imageLib.Image image = params["image"];
  String filename = params["filename"];
  List<int> _bytes = image.getBytes();

  if (filter != null) {
    filter.apply(_bytes, image.width, image.height);
  }

  imageLib.Image _image =
      imageLib.Image.fromBytes(image.width, image.height, _bytes);
  _bytes = imageLib.encodeNamedImage(_image, filename);

  return _bytes;
}

///The global buildThumbnail function
List<int> buildThumbnail(Map<String, dynamic> params) {
  int width = params["width"];
  params["image"] = imageLib.copyResize(params["image"], width: width);
  return applyFilter(params);
}
