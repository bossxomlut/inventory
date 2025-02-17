import 'package:flutter/material.dart';

import '../../widget/index.dart';

mixin StatelessTemplate on StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  Widget buildBody(BuildContext context) {
    return const Placeholder();
  }
}

mixin StateTemplate<T extends StatefulWidget> on State<T> {
  bool get isScaffold => true;

  ThemeData get theme => Theme.of(context);

  Color get backgroundColor => theme.scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    if (isScaffold) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: buildAppBar(context),
        body: buildBody(context),
        floatingActionButton: buildFloatingActionButton(context),
      );
    } else {
      return buildBody(context);
    }
  }

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  Widget buildBody(BuildContext context) {
    return const Placeholder();
  }

  Widget? buildFloatingActionButton(BuildContext context) => null;
}

mixin LoadingState<T extends StatefulWidget> on State<T> {
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);

  void showLoading() {
    _loadingNotifier.value = true;
  }

  void hideLoading() {
    _loadingNotifier.value = false;
  }

  @override
  void dispose() {
    _loadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        super.build(context),
        ValueListenableBuilder<bool>(
          valueListenable: _loadingNotifier,
          builder: (_, bool loading, __) {
            return loading ? buildLoading(context) : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget buildLoading(BuildContext context) {
    return const LoadingWidget();
  }
}
