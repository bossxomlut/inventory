import 'package:flutter/material.dart';

import '../../provider/index.dart';
import '../index.dart';

class SearchItemWidget<T> extends StatefulWidget with ShowBottomSheet<T> {
  // Callback for building each list item
  final Widget Function(BuildContext context, T, int) itemBuilder;

  // Callback for filtering items based on search query
  final Future<List<T>> Function(String keyword) searchItems;

  // Callback for handling new item addition
  final VoidCallback? onAddItem;
  final Widget? addItemWidget;

  final String? title;

  final IndexedWidgetBuilder? itemBuilderWithIndex;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;

  const SearchItemWidget({
    super.key,
    required this.itemBuilder,
    required this.searchItems,
    this.onAddItem,
    this.title,
    this.addItemWidget,
    this.itemBuilderWithIndex,
    this.onSubmitted,
    this.textEditingController,
    this.keyboardType,
  });

  @override
  State<SearchItemWidget<T>> createState() => _SearchItemWidgetState<T>();
}

class _SearchItemWidgetState<T> extends State<SearchItemWidget<T>> with SkeletonLoadingState<SearchItemWidget<T>> {
  late final TextEditingController _searchController = widget.textEditingController ?? TextEditingController();

  List<T> items = <T>[];

  String get searchKeyword => _searchController.text;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(onSearch);
    onSearch();
  }

  void onSearch() async {
    try {
      loading();

      final rs = await widget.searchItems(searchKeyword);

      items = rs;
    } catch (e) {
      items = [];
      // Handle error
    } finally {
      setState(() {});
      loaded();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(onSearch);
    if (widget.textEditingController == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          ColoredBox(
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Search bar
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back, size: 18)),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.done,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        // contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        hintText: widget.title ?? 'Tìm kiếm...',
                        hintStyle: theme.textMedium15Subtle,
                        border: InputBorder.none,
                      ),
                      onSubmitted: widget.onSubmitted,
                      keyboardType: widget.keyboardType ?? TextInputType.text,
                    ),
                  ),
                  // Add button
                  if (widget.onAddItem != null)
                    InkWell(
                      onTap: widget.onAddItem,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey.shade300,
                        child: widget.addItemWidget ??
                            const Icon(
                              Icons.add,
                              size: 18,
                            ),
                      ),
                    ),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8), // Dynamic list with custom itemBuilder
          Expanded(child: buildLoadView(context)),
        ],
      ),
    );
  }

  @override
  Widget buildLoaded(BuildContext context) {
    if (items.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40),
          Text(
            'Không có kết quả nào',
            style: context.appTheme.textMedium15Subtle,
          ),
          const SizedBox(height: 16),
          //add button
          if (widget.onAddItem != null)
            widget.addItemWidget ??
                ElevatedButton.icon(
                  onPressed: widget.onAddItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm mới'),
                ),
          const SizedBox(height: 40),
        ],
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return widget.itemBuilder(context, items[index], index);
      },
      separatorBuilder: (BuildContext context, int index) =>
          widget.itemBuilderWithIndex?.call(context, index) ?? const SizedBox(),
    );
  }
}
