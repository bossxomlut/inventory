import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../domain/models/shop_type.dart';
import '../../provider/theme.dart';
import '../../resources/index.dart';
import '../../shared_widgets/index.dart';
import 'data_import_test_page.dart';
import 'product_selection_page.dart';

@RoutePage()
class CreateSampleDataPage extends ConsumerWidget {
  const CreateSampleDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    String t(String key) => key.tr(context: context);

    return Scaffold(
      appBar: CustomAppBar(
        title: t(LKey.dataManagementSampleTitle),
        actions: [
          IconButton(
            onPressed: () => _navigateToTestPage(context),
            icon: Icon(
              HugeIcons.strokeRoundedTestTube,
              color: Colors.white,
            ),
            tooltip: t(LKey.dataManagementSampleTestTooltip),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedInformationCircle,
                          color: theme.colorPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t(LKey.dataManagementSampleChooseTitle),
                          style: theme.headingSemibold20Default,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t(LKey.dataManagementSampleChooseDescription),
                      style: theme.textRegular14Default,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: ShopType.predefinedTypes.length,
                itemBuilder: (context, index) {
                  final shopType = ShopType.predefinedTypes[index];
                  return Card(
                    color: Colors.white,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.colorPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            shopType.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        shopType.name,
                        style: theme.headingSemibold20Default,
                      ),
                      subtitle: Text(
                        shopType.description,
                        style: theme.textRegular14Default,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: theme.colorPrimary,
                        size: 16,
                      ),
                      onTap: () => _navigateToProductSelection(context, shopType),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProductSelection(BuildContext context, ShopType shopType) {
    // Navigate to product selection page
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ProductSelectionPage(shopType: shopType),
      ),
    );
  }

  void _navigateToTestPage(BuildContext context) {
    // Navigate to test page
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const DataImportTestPage(),
      ),
    );
  }
}
