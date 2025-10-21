import 'package:flutter/material.dart';

class LoadMoreList<T> extends StatelessWidget {
  LoadMoreList({
    required this.items,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.onLoadMore,
    required this.isCanLoadMore,
    this.padding,
  });

  final List<T> items;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int) separatorBuilder;
  final Future<void> Function() onLoadMore;
  final bool isCanLoadMore;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (BuildContext context, int index) {
        if (index == items.length) {
          if (isCanLoadMore) {
            onLoadMore();
            return const SizedBox(
              height: 200,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            );
          }

          return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text('Đã tải hết dữ liệu')));
        }
        return itemBuilder(context, index);
      },
      separatorBuilder: separatorBuilder,
      itemCount: items.length + 1,
      padding: padding,
    );
  }
}
