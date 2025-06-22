import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/helpers/app_image_manager.dart';
import '../../../domain/entities/image.dart';

class ImageManagerPickerPage extends StatefulWidget {
  final void Function(List<ImageStorageModel> images) onSelected;
  const ImageManagerPickerPage({super.key, required this.onSelected});

  @override
  State<ImageManagerPickerPage> createState() => _ImageManagerPickerPageState();

  /// Helper method to show the picker with keyboard dismissal
  static Future<List<ImageStorageModel>?> showPicker(BuildContext context) {
    // Ensure keyboard is dismissed
    FocusScope.of(context).unfocus();

    return Navigator.of(context).push<List<ImageStorageModel>>(
      MaterialPageRoute(
        builder: (context) => ImageManagerPickerPage(
          onSelected: (List<ImageStorageModel> selectedImages) {
            Navigator.of(context).pop(selectedImages);
          },
        ),
      ),
    );
  }
}

class _ImageManagerPickerPageState extends State<ImageManagerPickerPage> {
  List<ImageStorageModel> images = [];
  final Set<int> selectedIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => isLoading = true);
    final manager = AppImageManager();
    final imgs = await manager.listImages();
    setState(() {
      images = imgs;
      isLoading = false;
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Images from Storage'),
        actions: [
          TextButton(
            onPressed: selectedIds.isEmpty
                ? null
                : () {
                    final selected = images.where((img) => selectedIds.contains(img.id)).toList();
                    widget.onSelected(selected);
                    Navigator.of(context).pop(selected);
                  },
            child: const Text('Done'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : images.isEmpty
              ? const Center(child: Text('No images in storage.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final img = images[index];
                    final isSelected = selectedIds.contains(img.id);
                    return GestureDetector(
                      onTap: () => _toggleSelect(img.id),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: img.path != null
                                ? Image.file(
                                    File(img.path!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 14,
                                child: const Icon(Icons.check, color: Colors.white, size: 18),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
