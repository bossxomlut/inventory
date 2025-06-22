import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// A widget to display and manage a collection of images
/// with a large preview at the top and a scrollable list of thumbnails at the bottom.
/// Supports image zooming, rotating, and deleting images.
class ImagePresentView extends StatefulWidget {
  const ImagePresentView({
    super.key,
    this.initialIndex = 0,
    required this.imageUrls,
    this.deleteMode = false,
    this.onSave,
  });

  final int initialIndex;
  final List<String> imageUrls;
  final bool deleteMode;
  final ValueChanged<List<String>>? onSave;

  @override
  State<ImagePresentView> createState() => _ImagePresentViewState();
}

class _ImagePresentViewState extends State<ImagePresentView> {
  final List<String> _listImages = [];
  late PageController _pageController;
  late int _currentIndex;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _listImages.addAll(widget.imageUrls);
    _currentIndex = widget.initialIndex.clamp(0, _listImages.isEmpty ? 0 : _listImages.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Build the main zoomable image view
  Widget _buildZoomableImage(String imageUrl) {
    final ImageProvider imageProvider = _getImageProvider(imageUrl);

    return Container(
      color: Colors.black,
      child: PhotoView(
        imageProvider: imageProvider,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        enableRotation: true,
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error, color: Colors.red, size: 48),
        ),
      ),
    );
  }

  /// Build a thumbnail image with selection indicator
  Widget _buildThumbnail(int index) {
    final String imageUrl = _listImages[index];
    final bool isSelected = index == _currentIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image(
                image: _getImageProvider(imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            if (widget.deleteMode)
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () => _deleteImage(index),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0x66000000),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFFEBEBEB),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Get the appropriate ImageProvider based on the imageUrl
  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    } else {
      return FileImage(File(imageUrl));
    }
  }

  /// Delete an image from the list
  void _deleteImage(int index) {
    if (index < 0 || index >= _listImages.length) return;

    setState(() {
      _hasChanges = true;
      _listImages.removeAt(index);

      // Adjust currentIndex if needed
      if (_listImages.isEmpty) {
        _currentIndex = 0;
      } else if (_currentIndex >= _listImages.length) {
        _currentIndex = _listImages.length - 1;
      }

      // If we deleted the current image, update the page controller
      if (_listImages.isNotEmpty && index == _currentIndex) {
        _pageController.jumpToPage(_currentIndex);
      }
    });
  }

  /// Build a gallery of zoomable images
  Widget _buildPhotoViewGallery() {
    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      pageController: _pageController,
      itemCount: _listImages.length,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: _getImageProvider(_listImages[index]),
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          heroAttributes: PhotoViewHeroAttributes(tag: "image_$index"),
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.error, color: Colors.red, size: 48),
          ),
        );
      },
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      backgroundDecoration: const BoxDecoration(
        color: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_listImages.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Xem ảnh'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: widget.deleteMode
              ? [
                  TextButton.icon(
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Xong',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      _hasChanges = false;
                      widget.onSave?.call(_listImages);
                      Navigator.of(context).pop();
                    },
                  ),
                ]
              : null,
        ),
        body: const Center(
          child: Text(
            'Không có ảnh nào',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Xem ảnh'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.deleteMode && _hasChanges) {
              _showUnsavedChangesDialog(context);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (widget.deleteMode)
            TextButton.icon(
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Xong',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _hasChanges = false;
                widget.onSave?.call(_listImages);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Main image display area with zoom capability
          Expanded(
            flex: 4,
            child: _buildPhotoViewGallery(),
          ),

          // Image counter
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${_currentIndex + 1}/${_listImages.length}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          // Thumbnail list at the bottom
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _listImages.length,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemBuilder: (context, index) {
                return _buildThumbnail(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Show a dialog when there are unsaved changes
  void _showUnsavedChangesDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chưa lưu thay đổi'),
        content: const Text('Bạn có thay đổi chưa được lưu. Bạn có muốn lưu trước khi thoát không?'),
        actions: [
          TextButton(
            child: const Text('Bỏ qua'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Lưu'),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSave?.call(_listImages);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
