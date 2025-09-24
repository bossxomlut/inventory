import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../../../core/index.dart';
import '../../../domain/index.dart';
import '../../../provider/index.dart';
import '../../../shared_widgets/index.dart';
import '../../../shared_widgets/toast.dart';
import '../../product/widget/index.dart';

class InventoryAdjustBottomSheet extends HookWidget with ShowBottomSheet {
  const InventoryAdjustBottomSheet({
    super.key,
    required this.product,
    required this.onSave,
    this.currentQuantity,
    this.note,
    this.currentCheck,
  });
  final Product product;
  final int? currentQuantity;
  final String? note;
  final CheckedProduct? currentCheck;
  final void Function(int quantity, List<CheckedInventoryLot> lots,
      [String? note]) onSave;

  @override
  Widget build(BuildContext context) {
    final noteController = useTextEditingController(text: note);
    final theme = context.appTheme;
    final dateFormat = useMemoized(() => DateFormat('dd/MM/yyyy'));
    final trackByExpiry = product.enableExpiryTracking;

    List<_LotCheckDraft> buildInitialLots() {
      final drafts = <_LotCheckDraft>[];
      final existingLots = currentCheck?.lots ?? const [];
      final matchedIds = <int>{};

      for (final lot in product.lots) {
        CheckedInventoryLot? existing;
        if (existingLots.isNotEmpty) {
          existing = existingLots.firstWhereOrNull(
            (checkedLot) => checkedLot.inventoryLotId == lot.id,
          );
          existing ??= existingLots.firstWhereOrNull(
            (checkedLot) =>
                checkedLot.inventoryLotId == null &&
                checkedLot.expiryDate == lot.expiryDate &&
                checkedLot.manufactureDate == lot.manufactureDate,
          );
        }

        if (existing != null) {
          matchedIds.add(existing.id);
        }

        drafts.add(
          _LotCheckDraft(
            id: existing?.id ?? undefinedId,
            inventoryLotId: lot.id,
            expiryDate: lot.expiryDate,
            manufactureDate: lot.manufactureDate,
            expectedQuantity: lot.quantity,
            actualQuantity: existing?.actualQuantity ?? lot.quantity,
          ),
        );
      }

      for (final existing in existingLots) {
        if (matchedIds.contains(existing.id)) {
          continue;
        }
        drafts.add(
          _LotCheckDraft(
            id: existing.id,
            inventoryLotId: existing.inventoryLotId,
            expiryDate: existing.expiryDate,
            manufactureDate: existing.manufactureDate,
            expectedQuantity: existing.expectedQuantity,
            actualQuantity: existing.actualQuantity,
          ),
        );
      }

      return drafts;
    }

    final initialLotDrafts =
        useMemoized(buildInitialLots, [product, currentCheck]);
    final lotDrafts = useState<List<_LotCheckDraft>>(initialLotDrafts);
    final quantity = useState<int>(
      trackByExpiry
          ? initialLotDrafts.fold<int>(
              0,
              (sum, lot) =>
                  sum + (lot.actualQuantity < 0 ? 0 : lot.actualQuantity))
          : (currentQuantity ?? product.quantity),
    );

    int actualTotal() => lotDrafts.value.fold<int>(0,
        (sum, lot) => sum + (lot.actualQuantity < 0 ? 0 : lot.actualQuantity));

    void updateLot(int index, _LotCheckDraft updated) {
      if (index < 0 || index >= lotDrafts.value.length) {
        return;
      }
      final updatedLots = [...lotDrafts.value];
      updatedLots[index] = updated;
      lotDrafts.value = updatedLots;
      if (trackByExpiry) {
        quantity.value = actualTotal();
      }
    }

    void updateLotActual(int index, int value) {
      updateLot(index, lotDrafts.value[index].copyWith(actualQuantity: value));
    }

    void updateLotExpiry(int index, DateTime date) {
      updateLot(index, lotDrafts.value[index].copyWith(expiryDate: date));
    }

    void updateLotManufacture(int index, DateTime? date) {
      updateLot(
        index,
        lotDrafts.value[index].copyWith(
            manufactureDate: date, clearManufactureDate: date == null),
      );
    }

    void addManualLot() {
      lotDrafts.value = [
        ...lotDrafts.value,
        _LotCheckDraft(
          id: undefinedId,
          inventoryLotId: null,
          expiryDate: DateTime.now(),
          manufactureDate: null,
          expectedQuantity: 0,
          actualQuantity: 0,
        ),
      ];
      if (trackByExpiry) {
        quantity.value = actualTotal();
      }
    }

    void removeManualLot(int index) {
      if (index < 0 || index >= lotDrafts.value.length) {
        return;
      }
      final lot = lotDrafts.value[index];
      if (lot.inventoryLotId != null) {
        return;
      }
      final updatedLots = [...lotDrafts.value]..removeAt(index);
      lotDrafts.value = updatedLots;
      if (trackByExpiry) {
        quantity.value = actualTotal();
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomProductCard(
                    product: product,
                    subtitleWidget: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.colorSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tồn hệ thống: ${product.quantity.displayFormat()}',
                        style: theme.textRegular13Inverse,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const AppDivider(),
                  const SizedBox(height: 12),
                  TitleBlockWidget(
                    title: 'Số lượng kiểm kê',
                    child: trackByExpiry
                        ? _LotQuantitySummary(context, quantity.value)
                        : PlusMinusInputView(
                            initialValue: quantity.value,
                            minValue: 0,
                            onChanged: (val) => quantity.value = val,
                          ),
                  ),
                  if (trackByExpiry) ...[
                    const SizedBox(height: 12),
                    _LotCheckSection(
                      lots: lotDrafts.value,
                      dateFormat: dateFormat,
                      onActualChanged: updateLotActual,
                      onExpiryChanged: updateLotExpiry,
                      onManufactureChanged: updateLotManufacture,
                      onAddLot: addManualLot,
                      onRemoveLot: removeManualLot,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TitleBlockWidget(
                    title: 'Ghi chú',
                    child: CustomTextField(
                      controller: noteController,
                      hint: 'Nhập ghi chú',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        BottomButtonBar(
          onSave: () {
            final trimmedNote = noteController.text.trim();

            if (trackByExpiry) {
              final validationMessage = _validateLotChecks(lotDrafts.value);
              if (validationMessage != null) {
                showError(message: validationMessage);
                return;
              }
            }

            final lots = trackByExpiry
                ? lotDrafts.value
                    .map(
                      (lot) => CheckedInventoryLot(
                        id: lot.id,
                        inventoryLotId: lot.inventoryLotId,
                        expiryDate: lot.expiryDate,
                        manufactureDate: lot.manufactureDate,
                        expectedQuantity: lot.expectedQuantity,
                        actualQuantity: lot.actualQuantity,
                      ),
                    )
                    .toList()
                : <CheckedInventoryLot>[];

            onSave(
              quantity.value,
              lots,
              trimmedNote.isEmpty ? null : trimmedNote,
            );
          },
          onCancel: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _LotCheckSection extends StatelessWidget {
  const _LotCheckSection({
    required this.lots,
    required this.dateFormat,
    required this.onActualChanged,
    required this.onExpiryChanged,
    required this.onManufactureChanged,
    required this.onAddLot,
    required this.onRemoveLot,
  });

  final List<_LotCheckDraft> lots;
  final DateFormat dateFormat;
  final void Function(int index, int value) onActualChanged;
  final void Function(int index, DateTime date) onExpiryChanged;
  final void Function(int index, DateTime? date) onManufactureChanged;
  final VoidCallback onAddLot;
  final void Function(int index) onRemoveLot;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    Future<void> pickExpiryDate(int index) async {
      final lot = lots[index];
      if (lot.inventoryLotId != null) {
        return;
      }
      final picked = await showDatePicker(
        context: context,
        initialDate: lot.expiryDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        onExpiryChanged(index, picked);
      }
    }

    Future<void> pickManufactureDate(int index) async {
      final lot = lots[index];
      if (lot.inventoryLotId != null) {
        return;
      }
      final picked = await showDatePicker(
        context: context,
        initialDate: lot.manufactureDate ?? lot.expiryDate,
        firstDate: DateTime(2000),
        lastDate: lot.expiryDate,
      );
      if (picked != null) {
        onManufactureChanged(index, picked);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lots.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorBackgroundField,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorBorderSubtle),
            ),
            child: Text(
              'Chưa có lô kiểm kê. Thêm mới để ghi nhận.',
              style: theme.textRegular14Subtle,
            ),
          ),
        ...lots.asMap().entries.map((entry) {
          final index = entry.key;
          final lot = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index == lots.length - 1 ? 0 : 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorBorderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Lô ${index + 1}',
                        style: theme.textMedium15Default,
                      ),
                      const SizedBox(width: 8),
                      if (lot.inventoryLotId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorPrimary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Tồn hệ thống',
                            style: theme.textRegular12Default
                                .copyWith(color: theme.colorPrimary),
                          ),
                        ),
                      const Spacer(),
                      if (lot.inventoryLotId == null)
                        IconButton(
                          tooltip: 'Xoá lô',
                          onPressed: () => onRemoveLot(index),
                          icon: const Icon(Icons.close),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hệ thống: ${lot.expectedQuantity.displayFormat()}',
                    style: theme.textRegular13Subtle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ngày hết hạn: ${dateFormat.format(lot.expiryDate)}',
                    style: theme.textRegular13Default,
                  ),
                  const SizedBox(height: 12),
                  Text('Số lượng thực tế', style: theme.textRegular12Subtle),
                  const SizedBox(height: 8),
                  PlusMinusInputView(
                    initialValue: lot.actualQuantity,
                    minValue: 0,
                    onChanged: (value) => onActualChanged(index, value),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      _LotDateInput(
                        label: 'Hết hạn',
                        value: lot.expiryDate,
                        dateFormat: dateFormat,
                        onTap: lot.inventoryLotId != null
                            ? null
                            : () => pickExpiryDate(index),
                        isRequired: true,
                        readOnly: lot.inventoryLotId != null,
                      ),
                      const SizedBox(height: 12),
                      _LotDateInput(
                        label: 'Sản xuất (tuỳ chọn)',
                        value: lot.manufactureDate,
                        dateFormat: dateFormat,
                        onTap: lot.inventoryLotId != null
                            ? null
                            : () => pickManufactureDate(index),
                        onClear: lot.inventoryLotId == null &&
                                lot.manufactureDate != null
                            ? () => onManufactureChanged(index, null)
                            : null,
                        readOnly: lot.inventoryLotId != null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onAddLot,
          icon: const Icon(Icons.add),
          label: const Text('Thêm lô kiểm kê'),
        ),
      ],
    );
  }
}

class _LotCheckDraft {
  const _LotCheckDraft({
    required this.id,
    this.inventoryLotId,
    required this.expiryDate,
    this.manufactureDate,
    required this.expectedQuantity,
    required this.actualQuantity,
  });

  final int id;
  final int? inventoryLotId;
  final DateTime expiryDate;
  final DateTime? manufactureDate;
  final int expectedQuantity;
  final int actualQuantity;

  _LotCheckDraft copyWith({
    int? id,
    int? inventoryLotId,
    DateTime? expiryDate,
    DateTime? manufactureDate,
    bool clearManufactureDate = false,
    int? expectedQuantity,
    int? actualQuantity,
  }) {
    return _LotCheckDraft(
      id: id ?? this.id,
      inventoryLotId: inventoryLotId ?? this.inventoryLotId,
      expiryDate: expiryDate ?? this.expiryDate,
      manufactureDate: clearManufactureDate
          ? null
          : (manufactureDate ?? this.manufactureDate),
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
    );
  }
}

class _LotDateInput extends StatelessWidget {
  const _LotDateInput({
    required this.label,
    required this.value,
    required this.dateFormat,
    this.onTap,
    this.onClear,
    this.isRequired = false,
    this.readOnly = false,
  });

  final String label;
  final DateTime? value;
  final DateFormat dateFormat;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool isRequired;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final text = value != null ? dateFormat.format(value!) : '$label';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textRegular12Subtle,
              ),
            ),
            if (isRequired)
              Text(
                '*',
                style: theme.textRegular12Subtle
                    .copyWith(color: theme.colorTextSupportRed),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: readOnly ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorBorderSubtle),
              color: theme.colorBackgroundField,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: value != null
                        ? theme.textRegular15Default
                        : theme.textRegular15Subtle,
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: (!readOnly && value != null && onClear != null)
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onClear,
                          splashRadius: 18,
                        )
                      : null,
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color:
                      readOnly ? theme.colorIconDisable : theme.colorIconSubtle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _LotQuantitySummary(BuildContext context, int totalQuantity) {
  final theme = context.appTheme;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: theme.colorBackgroundField,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.colorBorderSubtle),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Tổng số lượng lô',
            style: theme.textRegular14Subtle,
          ),
        ),
        Text(
          '$totalQuantity',
          style: theme.headingSemibold24Default,
        ),
      ],
    ),
  );
}

String? _validateLotChecks(List<_LotCheckDraft> lots) {
  if (lots.isEmpty) {
    return 'Vui lòng thêm ít nhất một lô kiểm kê.';
  }

  final keys = <String>{};

  for (final lot in lots) {
    if (lot.actualQuantity < 0) {
      return 'Số lượng thực tế không được âm.';
    }

    final key =
        '${lot.inventoryLotId ?? 'manual'}|${lot.expiryDate.toIso8601String()}|${lot.manufactureDate?.toIso8601String() ?? 'null'}';
    if (!keys.add(key)) {
      return 'Không thể có hai lô trùng cả ngày sản xuất và ngày hết hạn.';
    }
  }

  return null;
}
