import 'package:flutter/material.dart';

import '../../../core/helpers/double_utils.dart';
import '../../../core/index.dart';
import '../../../domain/entities/index.dart';
import '../../../provider/index.dart';
import '../../../resources/index.dart';
import '../../../routes/app_router.dart';
import '../../../shared_widgets/index.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onRemove,
    this.onComplete,
    this.onCancel,
    this.isSelected = false,
    this.onSelectionToggle,
  });

  final Order order;
  final VoidCallback? onRemove;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    String t(String key) => key.tr(context: context);
    final notSet = t(LKey.orderCommonNotSet);
    final customerName = order.customer.isNotNullOrEmpty ? order.customer! : notSet;
    final contactName = order.customerContact.isNotNullOrEmpty ? order.customerContact! : notSet;
    final toggleSelection = onSelectionToggle;
    final enableSelection = toggleSelection != null;
    final backgroundColor =   Colors.white;
    final ValueChanged<bool?>? checkboxOnChanged = toggleSelection == null ? null : (_) => toggleSelection();

    return InkWell(
      onTap: () {
        appRouter.goToOrderDetail(order);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              LKey.orderListOrderCode.tr(
                                namedArgs: {'id': '${order.id}'},
                              ),
                              style: theme.textMedium15Default,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(order.orderDate),
                            style: theme.textRegular14Sublest,
                          ),
                        ],
                      ),
                    ),
                    if (enableSelection)
                      Container(
                        height: 24,
                        width: 24,
                        margin: EdgeInsets.only(left: 12),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            onSelectionToggle?.call();
                          },
                        ),
                      )
                  ],
                ),
                Gap(8),
                Row(
                  children: [
                    Text(
                      LKey.orderListCustomer.tr(
                        namedArgs: {'name': customerName},
                      ),
                      style: theme.textRegular15Default,
                    ),
                    VerticalDivider(),
                    Text(
                      LKey.orderListContact.tr(
                        namedArgs: {'contact': contactName},
                      ),
                      style: theme.textRegular14Sublest,
                    ),
                  ],
                ),
                Gap(8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            t(LKey.orderListProductsLabel),
                            style: theme.textRegular13Subtle,
                          ),
                          Gap(4),
                          Text(
                            '${order.productCount}',
                            style: theme.textRegular15Default,
                          ),
                        ],
                      ),
                      Gap(20),
                      Row(
                        children: [
                          Text(
                            t(LKey.orderListQuantityLabel),
                            style: theme.textRegular13Subtle,
                          ),
                          Gap(4),
                          Text(
                            '${order.totalAmount}',
                            style: theme.textRegular15Default,
                          ),
                        ],
                      ),
                      Gap(20),
                      Row(
                        children: [
                          Text(
                            t(LKey.orderListTotalLabel),
                            style: theme.textRegular13Subtle,
                          ),
                          Gap(4),
                          Text(
                            '${order.totalPrice.priceFormat()}',
                            style: theme.textRegular15Default,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (order.note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      LKey.orderListNoteLabel.tr(namedArgs: {'note': order.note!}),
                      style: theme.textRegular15Subtle,
                    ),
                  ),
              ],
            ),
            const Gap(10),
            const AppDivider(),
            const Gap(4),
            buildTrailing(
              context,
              order.status,
              theme,
              selectionActive: enableSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTrailing(BuildContext context, OrderStatus status, AppThemeData theme, {bool selectionActive = false}) {
    String t(String key) => key.tr(context: context);
    switch (status) {
      case OrderStatus.confirmed:
        final bool canComplete = onComplete != null;
        final bool canCancelOrder = onCancel != null;
        if (!canComplete && !canCancelOrder) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //Button: Hoàn thành
            if (canComplete)
              TextButton(
                onPressed: onComplete,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                  backgroundColor: Colors.green.withOpacity(0.1),
                ),
                child: Text(
                  t(LKey.orderListActionComplete),
                  style: theme.textRegular15Default.copyWith(color: Colors.green),
                ),
              ),
            if (canComplete && canCancelOrder) const Gap(12),
            //Button: Huỷ
            if (canCancelOrder)
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.red.withOpacity(0.1),
                ),
                child: Text(
                  t(LKey.orderListActionCancel),
                  style: theme.textRegular15Default.copyWith(color: Colors.red),
                ),
              ),
          ],
        );
      case OrderStatus.draft:
      case OrderStatus.done:
      case OrderStatus.cancelled:
        if (onRemove == null) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.1),
              ),
              child: Text(
                t(LKey.buttonDelete),
                style: theme.textRegular15Default.copyWith(color: Colors.red),
              ),
            ),
          ],
        );
    }
  }
}
