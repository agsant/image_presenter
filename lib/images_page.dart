import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_zoom/const/images.dart';

class ImagesPage extends StatefulWidget {
  @override
  _ImagesPageState createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  int selectedIndex = -1;
  bool _pagingEnabled = true;
  late PageController pageController;
  late TransformationController viewerController;

  @override
  void initState() {
    super.initState();
    viewerController = TransformationController();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              physics: _pagingEnabled
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: Images.images
                  .asMap()
                  .map((i, value) {
                    return MapEntry(i, _getInteractiveImageView(value));
                  })
                  .values
                  .toList(),
              onPageChanged: (int page) {
                setState(() {
                  selectedIndex = page;
                });
              },
            ),
          ),
          _getBottomList(),
        ],
      ),
    );
  }

  Widget _getInteractiveImageView(String imageUrl) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        color: Colors.black,
        height: double.infinity,
        width: double.infinity,
        child: InteractiveViewer(
          transformationController: viewerController,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
          ),
          onInteractionEnd: (details) {
            double scale = viewerController.value.getMaxScaleOnAxis();
            setState(() {
              _pagingEnabled = scale <= 1.0;
            });
          },
        ),
      ),
    );
  }

  Widget _getBottomList() {
    double _maxWidth = MediaQuery.of(context).size.width / 5;
    return Container(
      height: _maxWidth,
      child: ListView(
        children: Images.images
            .asMap()
            .map((i, value) {
              return MapEntry(
                i,
                _getBottomListItem(value, i),
              );
            })
            .values
            .toList(),
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget _getBottomListItem(String imageUrl, int index) {
    double _maxWidth = MediaQuery.of(context).size.width / 5;
    bool isSelected = index == selectedIndex;

    Widget _item = _getImageWidget(imageUrl);

    if (isSelected) {
      _item = Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10, width: 2),
        ),
        child: _getImageWidget(imageUrl),
      );
    }

    return InkWell(
      child: Container(
        width: _maxWidth,
        height: _maxWidth,
        child: _item,
      ),
      onTap: () {
        pageController.animateToPage(
          index,
          duration: Duration(seconds: 1),
          curve: Curves.ease,
        );
      },
    );
  }

  Widget _getImageWidget(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
    );
  }
}
