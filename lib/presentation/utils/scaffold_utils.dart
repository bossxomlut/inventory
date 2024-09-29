import 'package:flutter/material.dart';

import '../common/loading_widget.dart';

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
            return loading ? const LoadingWidget() : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
