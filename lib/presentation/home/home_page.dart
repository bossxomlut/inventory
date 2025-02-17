import 'package:flutter/material.dart';

import '../../resource/string.dart';
import '../utils/index.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with StateTemplate<HomePage> {
  @override
  Widget buildBody(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverMultilineAppBar(
            title: LKey.home.tr(),
          ),
        ];
      },
      body: Container(),
    );
  }
}

class SliverMultilineAppBar extends StatelessWidget {
  final String title;

  SliverMultilineAppBar({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    double availableWidth = mediaQuery.size.width - 160;

    final theme = Theme.of(context);

    return SliverAppBar(
      forceElevated: true,
      pinned: true,
      expandedHeight: 64,
      backgroundColor: theme.scaffoldBackgroundColor,
      foregroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: availableWidth,
          ),
          child: Text(
            title,
            textScaleFactor: .68,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.start,
          ),
        ),
      ),
    );
  }
}
