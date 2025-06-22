import 'dart:convert';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../domain/entities/get_id.dart';
import '../../domain/entities/image.dart';
import '../../features/product/widget/image_manager_picker_page.dart';
import '../../provider/theme.dart';
import '../../resources/theme.dart';
import '../camera/camera_view.dart';
import '../index.dart';
import 'image_present_view.dart';

/// Layout options for the image picker
enum ImagePickerLayout {
  /// Images displayed in a horizontal row
  horizontal,

  /// Images displayed in a grid
  grid,
}

/// A common widget for handling image selection and display in the application.
/// This widget can be used for selecting images from camera, gallery, or stored product images.
class CommonImagePicker extends StatelessWidget {
  const CommonImagePicker({
    Key? key,
    required this.title,
    required this.onImagesSelected,
    this.onImagesChanged,
    this.images,
    this.onImageRemoved,
    this.height = 100.0,
    this.maxImages,
    this.cameraLabel = 'Máy ảnh',
    this.galleryLabel = 'Thư viện',
    this.productImagesLabel = 'Sản phẩm',
    this.showRemoveButton = true,
    this.layout = ImagePickerLayout.grid,
    this.showOptions = true,
    this.showCamera = true,
    this.showGallery = true,
    this.showProductLibrary = true,
  }) : super(key: key);

  /// Title displayed in the add image placeholder
  final String title;

  /// Current list of images
  final List<ImageStorageModel>? images;

  /// Callback when new images are selected
  final ValueChanged<List<ImageStorageModel>> onImagesSelected;

  final ValueChanged<List<ImageStorageModel>>? onImagesChanged;

  /// Callback when an image is removed
  final ValueChanged<ImageStorageModel>? onImageRemoved;

  /// Height of the image items
  final double height;

  /// Maximum number of images allowed
  final int? maxImages;

  /// Label for camera option
  final String cameraLabel;

  /// Label for gallery option
  final String galleryLabel;

  /// Label for product images option
  final String productImagesLabel;

  /// Whether to show remove button on images
  final bool showRemoveButton;

  /// Layout of the images (horizontal or grid)
  final ImagePickerLayout layout;

  /// Whether to show the three selection options directly or use a selector dialog
  final bool showOptions;

  /// Whether to show the camera option
  final bool showCamera;

  /// Whether to show the gallery option
  final bool showGallery;

  /// Whether to show the product library option
  final bool showProductLibrary;

  bool get _hasImages => images != null && images!.isNotEmpty;
  bool get _canAddMoreImages => maxImages == null || (images?.length ?? 0) < maxImages!;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    // When we have images and are using a horizontal layout
    if (_hasImages && layout == ImagePickerLayout.horizontal) {
      return Row(
        children: [
          if (_canAddMoreImages) _buildAddButton(context, theme),
          if (_canAddMoreImages) const Gap(8),
          Expanded(
            child: SizedBox(
              height: height,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images!.length,
                itemBuilder: (context, index) => _buildImageItem(context, images![index], theme),
                separatorBuilder: (context, index) => const Gap(8),
              ),
            ),
          ),
        ],
      );
    }

    // When we have images and are using a grid layout
    else if (_hasImages && layout == ImagePickerLayout.grid) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  context: context,
                  icon: HugeIcons.strokeRoundedCamera02,
                  label: cameraLabel,
                  onTap: () => _pickFromCamera(context),
                  theme: theme,
                ),
              ),
              const Gap(10),
              Expanded(
                child: _buildOptionButton(
                  context: context,
                  icon: HugeIcons.strokeRoundedImage03,
                  label: galleryLabel,
                  onTap: () => _pickFromGallery(context),
                  theme: theme,
                ),
              ),
              const Gap(10),
              Expanded(
                child: _buildOptionButton(
                  context: context,
                  icon: HugeIcons.strokeRoundedGooglePhotos,
                  label: productImagesLabel,
                  onTap: () => _pickFromProductImages(context),
                  theme: theme,
                ),
              ),
            ],
          ),
          const Gap(10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...images!.map((image) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _buildImageItem(context, image, theme),
                    )),
              ],
            ),
          )
        ],
      );
    }

    // When we don't have images and want to show all options
    else if (showOptions) {
      return Row(
        children: [
          Expanded(
            child: _buildOptionButton(
              context: context,
              icon: HugeIcons.strokeRoundedCamera02,
              label: cameraLabel,
              onTap: () => _pickFromCamera(context),
              theme: theme,
            ),
          ),
          const Gap(10),
          Expanded(
            child: _buildOptionButton(
              context: context,
              icon: HugeIcons.strokeRoundedImage03,
              label: galleryLabel,
              onTap: () => _pickFromGallery(context),
              theme: theme,
            ),
          ),
          const Gap(10),
          Expanded(
            child: _buildOptionButton(
              context: context,
              icon: HugeIcons.strokeRoundedGooglePhotos,
              label: productImagesLabel,
              onTap: () => _pickFromProductImages(context),
              theme: theme,
            ),
          ),
        ],
      );
    }

    // When we don't have images and want to use a selector dialog
    else {
      return _buildAddButton(context, theme);
    }
  }

  // Build a button to add more images
  Widget _buildAddButton(BuildContext context, AppThemeData theme) {
    return InkWell(
      onTap: () => _showImagePickerOptions(context),
      child: DottedBorder(
        color: theme.colorBorderField,
        radius: const Radius.circular(8),
        dashPattern: const [6, 6],
        strokeCap: StrokeCap.butt,
        child: Container(
          constraints: BoxConstraints(
            minHeight: height,
            minWidth: height,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Gap(16),
              Icon(
                Icons.add_photo_alternate_outlined,
                color: theme.colorIconSubtle,
                size: 30,
              ),
              const Gap(8),
              Text(
                title,
                style: theme.textMedium13Default,
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  // Build an option button for camera, gallery, or product images
  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      child: DottedBorder(
        color: theme.colorBorderField,
        radius: const Radius.circular(16),
        dashPattern: const [6, 6],
        strokeCap: StrokeCap.butt,
        child: ClipRRect(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: theme.colorIconSubtle,
                ),
                const Gap(10),
                Text(
                  label,
                  style: theme.textMedium13Subtle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build an image item with an optional remove button
  Widget _buildImageItem(BuildContext context, ImageStorageModel image, AppThemeData theme) {
    final index = images?.indexOf(image) ?? 0;

    return GestureDetector(
      onTap: () {
        if (images != null && images!.isNotEmpty) {
          // Navigate to ImagePresentView with the images
          final validPaths = images!.map((img) => img.path ?? '').where((path) => path.isNotEmpty).toList();

          if (validPaths.isEmpty) return;

          context.hideKeyboard();

          Navigator.of(context).push<List<String>>(
            MaterialPageRoute<List<String>>(
              builder: (context) => ImagePresentView(
                imageUrls: validPaths,
                initialIndex: index.clamp(0, validPaths.length - 1),
                deleteMode: true,
                onSave: (updatedPaths) {
                  // Convert back to ImageStorageModel
                  final List<ImageStorageModel> updatedImages = [];
                  for (final path in updatedPaths) {
                    // Try to find the original image with this path
                    final originalImage = images!.firstWhere(
                      (img) => img.path == path,
                      orElse: () => ImageStorageModel(id: undefinedId, path: path),
                    );
                    updatedImages.add(originalImage);
                  }
                  onImagesChanged?.call(updatedImages);
                },
              ),
            ),
          );
        }
      },
      child: Container(
        height: height,
        width: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorBorderField,
            width: 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              child: AppImage.file(
                url: image.path ?? '',
                fit: BoxFit.cover,
                // height: height,
              ),
            ),
            if (showRemoveButton && onImageRemoved != null)
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: () => onImageRemoved?.call(image),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
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

  // Show a dialog to pick image source
  void _showImagePickerOptions(BuildContext context) {
    context.hideKeyboard();

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _ImageSourceSelector(
        cameraLabel: cameraLabel,
        galleryLabel: galleryLabel,
        productImagesLabel: productImagesLabel,
        onCameraSelected: () {
          Navigator.pop(context);
          _pickFromCamera(context);
        },
        onGallerySelected: () {
          Navigator.pop(context);
          _pickFromGallery(context);
        },
        onProductImagesSelected: () {
          Navigator.pop(context);
          _pickFromProductImages(context);
        },
      ),
    );
  }

  // Pick image from camera
  void _pickFromCamera(BuildContext context) {
    // Ensure keyboard is dismissed
    context.hideKeyboard();

    CameraView.show(context).then((files) {
      if (files != null && files.isNotEmpty) {
        final images = files.map((file) => ImageStorageModel(id: undefinedId, path: file.path)).toList();
        onImagesSelected(images);
      }
    });
  }

  // Pick image from gallery
  void _pickFromGallery(BuildContext context) {
    // Ensure keyboard is dismissed
    context.hideKeyboard();

    AppFilePicker.image().pickMultiFiles().then((files) {
      if (files != null && files.isNotEmpty) {
        final images = files.map((file) => ImageStorageModel(id: undefinedId, path: file.path)).toList();
        onImagesSelected(images);
      }
    });
  }

  // Pick image from product images
  void _pickFromProductImages(BuildContext context) {
    // Ensure keyboard is dismissed
    context.hideKeyboard();

    // Use the ImageManagerPickerPage
    ImageManagerPickerPage.showPicker(context).then((files) {
      if (files != null) {
        onImagesSelected(files);
      }
    });
  }
}

/// A widget for selecting an image source
class _ImageSourceSelector extends StatelessWidget {
  const _ImageSourceSelector({
    Key? key,
    required this.cameraLabel,
    required this.galleryLabel,
    required this.productImagesLabel,
    required this.onCameraSelected,
    required this.onGallerySelected,
    required this.onProductImagesSelected,
  }) : super(key: key);

  final String cameraLabel;
  final String galleryLabel;
  final String productImagesLabel;
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;
  final VoidCallback onProductImagesSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chọn nguồn ảnh',
              style: theme.headingSemibold20Default,
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: _buildOptionTile(
                    context: context,
                    icon: HugeIcons.strokeRoundedCamera02,
                    label: cameraLabel,
                    onTap: onCameraSelected,
                    theme: theme,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: _buildOptionTile(
                    context: context,
                    icon: HugeIcons.strokeRoundedImage03,
                    label: galleryLabel,
                    onTap: onGallerySelected,
                    theme: theme,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: _buildOptionTile(
                    context: context,
                    icon: HugeIcons.strokeRoundedGooglePhotos,
                    label: productImagesLabel,
                    onTap: onProductImagesSelected,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorBackgroundField,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: theme.colorIconSubtle,
            ),
            const Gap(8),
            Text(
              label,
              style: theme.textMedium13Default,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget for displaying a base64 encoded image
class Base64ImageDisplay extends StatelessWidget {
  const Base64ImageDisplay({
    Key? key,
    required this.data,
    this.onRemove,
    this.height = 120.0,
  }) : super(key: key);

  final String data;
  final VoidCallback? onRemove;
  final double height;

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = base64Decode(data);
    final theme = context.appTheme;

    return Container(
      height: height,
      width: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorBorderField,
          width: 1,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              height: height,
            ),
          ),
          if (onRemove != null)
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: onRemove,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0x66000000),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFFEBEBEB),
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
