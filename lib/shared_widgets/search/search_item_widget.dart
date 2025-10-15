import 'package:flutter/material.dart';

import '../../provider/index.dart';
import '../../provider/load_list.dart';
import '../index.dart';

class SearchItemWidget<T> extends StatefulWidget with ShowBottomSheet<T> {
  // Callback for building each list item
  final Widget Function(BuildContext context, T, int) itemBuilder;

  // Callback for filtering items based on search query
  final Future<List<T>> Function(String keyword, int page, int size)
      searchItems;

  // Callback for handling new item addition
  final VoidCallback? onAddItem;
  final Widget? addItemWidget;

  final String? title;

  final IndexedWidgetBuilder? itemBuilderWithIndex;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final bool enableLoadMore;
  final bool showAddButtonWhenEmpty;

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
    this.enableLoadMore = true,
    this.showAddButtonWhenEmpty = true,
  });

  @override
  State<SearchItemWidget<T>> createState() => _SearchItemWidgetState<T>();
}

class _SearchItemWidgetState<T> extends State<SearchItemWidget<T>>
    with SkeletonLoadingState<SearchItemWidget<T>> {
  late final TextEditingController _searchController =
      widget.textEditingController ?? TextEditingController();

  List<T> items = <T>[];

  String get searchKeyword => _searchController.text;

  String currentSearchKeyword = 'default';

  int page = firstPage;
  int size = defaultPageSize;
  bool _endOfList = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(onSearch);
    onSearch();
  }

  void onSearch() async {
    if (currentSearchKeyword == searchKeyword) {
      // No change in search keyword, no need to reload
      return;
    }

    currentSearchKeyword = searchKeyword;

    try {
      loading();

      page = firstPage;
      _endOfList = false;

      final rs = await widget.searchItems(searchKeyword, page, size);

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
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, size: 18)),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.done,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      // contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      hintText: widget.title ??
                          LKey.searchPlaceholder.tr(context: context),
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
    );
  }

  @override
  Widget buildLoaded(BuildContext context) {
    if (items.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40),
          LText(
            LKey.searchNoResults,
            style: context.appTheme.textMedium15Subtle,
          ),
          const SizedBox(height: 16),
          //add button
          if (widget.onAddItem != null && widget.showAddButtonWhenEmpty)
            widget.addItemWidget ??
                ElevatedButton.icon(
                  onPressed: widget.onAddItem,
                  icon: const Icon(Icons.add),
                  label: LText(LKey.searchAddNew),
                ),
          const SizedBox(height: 40),
        ],
      );
    }

    return LoadMoreList<T>(
      items: items,
      itemBuilder: (context, index) =>
          widget.itemBuilder(context, items[index], index),
      separatorBuilder: (context, index) =>
          widget.itemBuilderWithIndex?.call(context, index) ?? const SizedBox(),
      onLoadMore: () async {
        // Implement load more logic if needed
        page = page + 1;
        final newItems = await widget.searchItems(searchKeyword, page, size);
        if (newItems.isNotEmpty) {
          items.addAll(newItems);
        } else {
          _endOfList = true; // No more items to load
        }
        setState(() {});
      },
      isCanLoadMore: widget.enableLoadMore &&
          !_endOfList, // Set to true if you want to implement load more functionality
      padding: padding,
    );
  }

  EdgeInsets get padding =>
      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
}

class SearchAndConfirmItemWidget<T> extends SearchItemWidget<T> {
  const SearchAndConfirmItemWidget({
    super.key,
    required super.itemBuilder,
    required super.searchItems,
    super.onAddItem,
    super.title,
    super.addItemWidget,
    super.itemBuilderWithIndex,
    super.onSubmitted,
    super.textEditingController,
    super.keyboardType,
    super.enableLoadMore,
    super.showAddButtonWhenEmpty,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  @override
  State<SearchItemWidget<T>> createState() =>
      _SearchAndConfirmItemWidgetState<T>();
}

class _SearchAndConfirmItemWidgetState<T> extends _SearchItemWidgetState<T> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: super.build(context),
      floatingActionButton: FloatingActionButton(
        onPressed: (widget as SearchAndConfirmItemWidget<T>).onConfirm,
        child: const Icon(Icons.check),
      ),
    );
  }

  EdgeInsets get padding => const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 80.0);
}
