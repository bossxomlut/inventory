import 'package:flutter/material.dart';

import '../index.dart';

class SearchItemWidget<T> extends StatefulWidget with ShowBottomSheet<T> {
  // Callback for building each list item
  final Widget Function(BuildContext context, T, int) itemBuilder;

  // Callback for filtering items based on search query
  final Future<List<T>> Function(String keyword) searchItems;

  // Callback for handling new item addition
  final VoidCallback onAddItem;

  const SearchItemWidget({
    super.key,
    required this.itemBuilder,
    required this.searchItems,
    required this.onAddItem,
  });

  @override
  State<SearchItemWidget<T>> createState() => _SearchItemWidgetState<T>();
}

class _SearchItemWidgetState<T> extends State<SearchItemWidget<T>> with SkeletonLoadingState<SearchItemWidget<T>> {
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ColoredBox(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Search bar
                BackButton(),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      // contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      hintText: 'Search items...',
                      hintStyle: TextStyle(fontSize: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // Add button
                InkWell(
                  onTap: widget.onAddItem,
                  child: CircleAvatar(
                    radius: 12,
                    child: const Icon(
                      Icons.add,
                      size: 18,
                    ),
                    backgroundColor: Colors.grey.shade300,
                    // onPressed: widget.onAddItem,
                    // tooltip: 'Add new item',
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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return widget.itemBuilder(context, items[index], index);
      },
    );
  }
}
