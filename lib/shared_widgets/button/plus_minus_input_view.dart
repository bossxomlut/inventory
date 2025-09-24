import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/index.dart';
import '../../provider/index.dart';
import '../index.dart';

class PlusMinusInputView extends StatefulWidget {
  const PlusMinusInputView({
    super.key,
    this.initialValue,
    this.onChanged,
    this.minValue = 0,
    this.maxValue,
  });

  final int? initialValue;
  final void Function(int)? onChanged;
  final int? minValue;
  final int? maxValue;

  @override
  State<PlusMinusInputView> createState() => _PlusMinusInputViewState();
}

class _PlusMinusInputViewState extends State<PlusMinusInputView> {
  late int number;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    number = _applyBounds(widget.initialValue ?? 0);
  }

  @override
  void didUpdateWidget(covariant PlusMinusInputView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bounded = _applyBounds(number);
    if (bounded != number) {
      setState(() {
        number = bounded;
      });
      widget.onChanged?.call(number);
    }
  }

  bool get _canIncrement =>
      widget.maxValue == null || number < widget.maxValue!;
  bool get _canDecrement =>
      widget.minValue == null || number > widget.minValue!;

  void _increment() {
    if (widget.maxValue == null || number < widget.maxValue!) {
      setState(() {
        number++;
        widget.onChanged?.call(number);
      });
    }
  }

  void _decrement() {
    if (widget.minValue == null || number > widget.minValue!) {
      setState(() {
        number--;
        widget.onChanged?.call(number);
      });
    }
  }

  void _startAutoIncrement() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _increment();
    });
  }

  void _startAutoDecrement() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _decrement();
    });
  }

  void _stopAutoIncrement() {
    _timer?.cancel();
  }

  int _applyBounds(int value) {
    final minValue = widget.minValue ?? 0;
    final maxValue = widget.maxValue;

    var result = value < minValue ? minValue : value;

    if (maxValue != null) {
      final effectiveMax = maxValue < minValue ? minValue : maxValue;
      if (result > effectiveMax) {
        result = effectiveMax;
      }
    }

    return result;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final minValue = widget.minValue ?? 0;
    final maxValue = widget.maxValue;
    final pickerMaxValue = maxValue != null
        ? (maxValue < minValue ? minValue : maxValue)
        : ((number > minValue ? number : minValue) + 1000);

    return SizedBox(
      height: 54,
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: GestureDetector(
              onTap: _decrement,
              onLongPressStart:
                  _canDecrement ? (_) => _startAutoDecrement() : null,
              onLongPressEnd: (_) => _stopAutoIncrement(),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorBackgroundField,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: _canDecrement
                        ? theme.colorBorderField
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  HugeIcons.strokeRoundedMinusSign,
                  size: 24,
                  color:
                      _canDecrement ? theme.colorIcon : theme.colorIconDisable,
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: InkWell(
              onTap: () {
                NumberInputWithList(
                  maxValue: pickerMaxValue,
                  onChanged: (int value) {
                    Navigator.pop(context);
                    final boundedValue = _applyBounds(value);
                    setState(() {
                      number = boundedValue;
                    });
                    widget.onChanged?.call(number);
                  },
                ).show(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorBackgroundField,
                  border: Border.all(
                    color: theme.colorBorderField,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: context.appTheme.textRegular15Default.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            width: 54,
            height: 54,
            child: GestureDetector(
              onTap: _increment,
              onLongPressStart:
                  _canIncrement ? (_) => _startAutoIncrement() : null,
              onLongPressEnd: (_) => _stopAutoIncrement(),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorBackgroundField,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: _canIncrement
                        ? theme.colorBorderField
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  HugeIcons.strokeRoundedPlusSign,
                  size: 24,
                  color:
                      _canIncrement ? theme.colorIcon : theme.colorIconDisable,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//create a plus/minus button widget
class PlusMinusButton extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int? maxValue;

  const PlusMinusButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue,
  });

  bool get canIncrement {
    if (maxValue == null) {
      return true;
    }
    return value < maxValue!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: theme.colorBackground,
          radius: 16,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 20,
            icon: const Icon(Icons.remove),
            onPressed: value > minValue
                ? () {
                    onChanged(value - 1);
                  }
                : null,
          ),
        ),
        GestureDetector(
          onTap: () {
            NumberInputWithList(
              maxValue: maxValue ?? 100,
              onChanged: (int value) {
                Navigator.pop(context);
                onChanged(value);
              },
            ).show(context);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            constraints: BoxConstraints(
              minWidth: 30,
            ),
            decoration: BoxDecoration(
              //border in bottom
              border: Border(
                bottom: BorderSide(
                  color: theme.colorBorderField,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              value.displayFormat(),
              style: theme.textMedium15Default,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        CircleAvatar(
          backgroundColor: theme.colorBackground,
          radius: 16,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 20,
            icon: const Icon(Icons.add),
            onPressed: !canIncrement ? null : () {
              onChanged(value + 1);
            },
          ),
        ),
      ],
    );
  }
}

class NumberInputWithList extends HookWidget with ShowBottomSheet<int> {
  final int minValue;
  final int maxValue;
  final ValueChanged<int>? onChanged;

  const NumberInputWithList({
    super.key,
    this.minValue = 1,
    this.maxValue = 100,
    this.onChanged,
  });

  List<int> get numbers {
    if (maxValue < minValue) {
      return [minValue];
    }
    return List.generate(
        (maxValue - minValue) +1, (index) {
          return minValue + index;
    });
  }

  int _clampValue(int value) {
    if (value < minValue) {
      return minValue;
    }
    if (value > maxValue) {
      return maxValue;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();

    //create method get number from text input
    void getNumberFromText() {
      //value
      final String value = textController.text.trim();
      final int? number = int.tryParse(value);
      //check if number is valid
      if (number != null) {
        if (onChanged != null) {
          onChanged!(_clampValue(number));
        }
      }
    }

    return SearchItemWidget<int>(
      keyboardType: TextInputType.number,
      textEditingController: textController,
      onSubmitted: (String value) {
        getNumberFromText();
      },
      itemBuilder: (BuildContext item, int number, int index) {

        return ListTile(
          title: Text('$number'),
          onTap: () {
            if (onChanged != null) {
              onChanged!(_clampValue(number));
            }
          },
        );
      },
      onAddItem: () {
        //value
        final String value = textController.text.trim();
        final int? number = int.tryParse(value);
        //check if number is valid
        if (number != null) {
          if (onChanged != null) {
            onChanged!(_clampValue(number));
          }
        }
      },
      searchItems: (keyword, page, size) async {
        return numbers
            .where((number) => number.toString().contains(keyword))
            .toList();
      },
      title: 'Nhập số lượng',
      addItemWidget: Icon(
        Icons.navigate_next_sharp,
        color: context.appTheme.colorIcon,
      ),
      itemBuilderWithIndex: (BuildContext context, int index) =>
          const AppDivider(),
      enableLoadMore: false,
    );
  }
}
