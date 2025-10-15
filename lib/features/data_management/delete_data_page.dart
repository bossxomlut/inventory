import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/theme.dart';
import '../../resources/index.dart';
import '../../shared_widgets/index.dart';
import 'services/index.dart';

enum _DangerLevel { low, medium, high }

@RoutePage()
class DeleteDataPage extends ConsumerWidget {
  const DeleteDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    String t(String key) => key.tr(context: context);

    return Scaffold(
      appBar: CustomAppBar(
        title: t(LKey.dataManagementDeleteTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t(LKey.dataManagementDeleteWarningTitle),
                        style: theme.headingSemibold20Default.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t(LKey.dataManagementDeleteWarningDescription),
                    style: theme.textRegular14Default.copyWith(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 8),
                  _buildWarningItem(t(LKey.dataManagementDeleteWarningIrreversible)),
                  _buildWarningItem(t(LKey.dataManagementDeleteWarningBackup)),
                  _buildWarningItem(t(LKey.dataManagementDeleteWarningDuration)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildDeleteCard(
            context,
            icon: Icons.inventory,
            title: t(LKey.dataManagementDeleteProductsTitle),
            description: t(LKey.dataManagementDeleteProductsDescription),
            dangerLevel: _DangerLevel.medium,
            onPressed: () => _deleteProducts(context, ref),
          ),
          const SizedBox(height: 12),
          _buildDeleteCard(
            context,
            icon: Icons.category,
            title: t(LKey.dataManagementDeleteCategoriesTitle),
            description: t(LKey.dataManagementDeleteCategoriesDescription),
            dangerLevel: _DangerLevel.low,
            onPressed: () => _deleteCategories(context, ref),
          ),
          const SizedBox(height: 12),
          _buildDeleteCard(
            context,
            icon: Icons.straighten,
            title: t(LKey.dataManagementDeleteUnitsTitle),
            description: t(LKey.dataManagementDeleteUnitsDescription),
            dangerLevel: _DangerLevel.low,
            onPressed: () => _deleteUnits(context, ref),
          ),
          const SizedBox(height: 12),
          _buildDeleteCard(
            context,
            icon: Icons.shopping_cart,
            title: t(LKey.dataManagementDeleteOrdersTitle),
            description: t(LKey.dataManagementDeleteOrdersDescription),
            dangerLevel: _DangerLevel.high,
            onPressed: () => _deleteOrders(context, ref),
          ),
          const SizedBox(height: 12),
          _buildDeleteCard(
            context,
            icon: Icons.fact_check,
            title: t(LKey.dataManagementDeleteStocktakeTitle),
            description: t(LKey.dataManagementDeleteStocktakeDescription),
            dangerLevel: _DangerLevel.high,
            onPressed: () => _deleteCheckSessions(context, ref),
          ),
          const SizedBox(height: 12),
          _buildDeleteCard(
            context,
            icon: Icons.history,
            title: t(LKey.dataManagementDeleteTransactionsTitle),
            description: t(LKey.dataManagementDeleteTransactionsDescription),
            dangerLevel: _DangerLevel.high,
            onPressed: () => _deleteProductTransactions(context, ref),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.delete_forever,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t(LKey.dataManagementDeleteAllTitle),
                    style: theme.headingSemibold20Default.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t(LKey.dataManagementDeleteAllDescription),
                    style: theme.textRegular14Default.copyWith(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _deleteAllData(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(t(LKey.dataManagementDeleteAllButton)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.red.shade700),
      ),
    );
  }

  Widget _buildDeleteCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required _DangerLevel dangerLevel,
    required VoidCallback onPressed,
  }) {
    final theme = context.appTheme;
    String t(String key) => key.tr(context: context);

    Color getLevelColor() {
      switch (dangerLevel) {
        case _DangerLevel.low:
          return Colors.orange;
        case _DangerLevel.medium:
          return Colors.deepOrange;
        case _DangerLevel.high:
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String getLevelLabel() {
      switch (dangerLevel) {
        case _DangerLevel.low:
          return t(LKey.dataManagementDeleteLevelLow);
        case _DangerLevel.medium:
          return t(LKey.dataManagementDeleteLevelMedium);
        case _DangerLevel.high:
          return t(LKey.dataManagementDeleteLevelHigh);
      }
    }

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorPrimary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.headingSemibold20Default,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textRegular14Default,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getLevelColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: getLevelColor().withOpacity(0.3)),
                  ),
                  child: Text(
                    LKey.dataManagementDeleteLevelLabel.tr(
                      namedArgs: {'level': getLevelLabel()},
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: getLevelColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.delete),
                label: Text(t(LKey.dataManagementDeleteActionButton)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProducts(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllProductsWithConfirmation(context);
  }

  void _deleteCategories(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllCategoriesWithConfirmation(context);
  }

  void _deleteUnits(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllUnitsWithConfirmation(context);
  }

  void _deleteOrders(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllOrdersWithConfirmation(context);
  }

  void _deleteCheckSessions(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllCheckSessionsWithConfirmation(context);
  }

  void _deleteProductTransactions(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllProductTransactionsWithConfirmation(context);
  }

  void _deleteAllData(BuildContext context, WidgetRef ref) {
    final dataDeletionService = ref.read(dataDeletionServiceProvider);
    dataDeletionService.deleteAllDataWithConfirmation(context);
  }
}
