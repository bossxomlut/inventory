import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../provider/index.dart';
import '../app_divider.dart';
import '../bottom_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = useTextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Enter a number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    final number = int.tryParse(controller.text) ?? minValue;
                    if (onChanged != null) {
                      onChanged!(number);
                    }
                  },
                  icon: Icon(Icons.navigate_next))
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: (maxValue - minValue) + 1,
            itemBuilder: (context, index) {
              final number = minValue + index;
              return ListTile(
                title: Text('$number'),
                onTap: () {
                  controller.text = '$number';
                  if (onChanged != null) {
                    onChanged!(number);
                  }
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) => const AppDivider(),
          ),
        ),
      ],
    );
  }
}
