import 'package:flutter/material.dart';

import '../../resource/string.dart';
import '../../route/app_router.dart';
import '../../widget/index.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kiêm kê',
              style: theme.textTheme.titleMedium,
            ),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: () {
                        appRouter.goInventory();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          // borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Tồn kho',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
