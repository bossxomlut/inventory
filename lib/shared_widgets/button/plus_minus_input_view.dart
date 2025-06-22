import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../provider/index.dart';
import '../index.dart';

class PlusMinusInputView extends StatefulWidget {
  const PlusMinusInputView({
    super.key,
    this.initialValue,
    this.onChanged,
    this.minValue = 0,
    this.maxValue = 100,
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
    number = widget.initialValue ?? 0;
  }

  bool get _canIncrement => widget.maxValue == null || number < widget.maxValue!;
  bool get _canDecrement => widget.minValue == null || number > widget.minValue!;

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: GestureDetector(
              onTap: _decrement,
              onLongPressStart: _canDecrement ? (_) => _startAutoDecrement() : null,
              onLongPressEnd: (_) => _stopAutoIncrement(),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorBackgroundField,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: _canDecrement ? theme.colorBorderField : Colors.transparent,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  HugeIcons.strokeRoundedMinusSign,
                  size: 24,
                  color: _canDecrement ? theme.colorIcon : theme.colorIconDisable,
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: InkWell(
              onTap: () {
                NumberInputWithList(
                  onChanged: (int value) {
                    Navigator.pop(context);
                    number = value;
                    setState(() {});
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
              onLongPressStart: _canIncrement ? (_) => _startAutoIncrement() : null,
              onLongPressEnd: (_) => _stopAutoIncrement(),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorBackgroundField,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: _canIncrement ? theme.colorBorderField : Colors.transparent,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  HugeIcons.strokeRoundedPlusSign,
                  size: 24,
                  color: _canIncrement ? theme.colorIcon : theme.colorIconDisable,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NumberInputWithList extends HookWidget with ShowBottomSheet<int> {
  final int minValue;
  final int maxValue;
  final ValueChanged<int>? onChanged;

  const NumberInputWithList({
    super.key,
    this.minValue = 0,
    this.maxValue = 100,
    this.onChanged,
  });

  List<int> get numbers => List.generate((maxValue - minValue) + 1, (index) => minValue + index);

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
          onChanged!(number);
        }
      }
    }

    return SearchItemWidget<int>(
      keyboardType: TextInputType.number,
      textEditingController: textController,
      onSubmitted: (String value) {
        getNumberFromText();
      },
      itemBuilder: (BuildContext item, int index, int p2) {
        final number = minValue + index;
        return ListTile(
          title: Text('$number'),
          onTap: () {
            if (onChanged != null) {
              onChanged!(number);
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
            onChanged!(number);
          }
        }
      },
      searchItems: (String keyword) async {
        return numbers.where((number) => number.toString().contains(keyword)).toList();
      },
      title: 'Input a number',
      addItemWidget: Icon(
        Icons.navigate_next_sharp,
        color: context.appTheme.colorIcon,
      ),
      itemBuilderWithIndex: (BuildContext context, int index) => const AppDivider(),
    );
  }
}
