import 'package:flutter/material.dart';

import '../../provider/index.dart';
import '../index.dart';

class SearchItemWidget<T> extends StatefulWidget with ShowBottomSheet<T> {
  // Callback for building each list item
  final Widget Function(BuildContext context, T, int) itemBuilder;

  // Callback for filtering items based on search query
  final Future<List<T>> Function(String keyword) searchItems;

  // Callback for handling new item addition
  final VoidCallback onAddItem;
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
    required this.onAddItem,
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
    return Column(
      children: [
        ColoredBox(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Search bar
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back, size: 18)),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.done,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      // contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      hintText: widget.title ?? 'Search items...',
                      hintStyle: theme.textMedium15Subtle,
                      border: InputBorder.none,
                    ),
                    onSubmitted: widget.onSubmitted,
                    keyboardType: widget.keyboardType ?? TextInputType.text,
                  ),
                ),
                // Add button
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
    );
  }

  @override
  Widget buildLoaded(BuildContext context) {
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
