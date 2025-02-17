import 'package:flutter/material.dart';

const int maxPinLength = 4;

class NumberPad extends StatefulWidget {
  NumberPad({
    super.key,
    required this.onChanged,
    this.maxLength = maxPinLength,
  });

  final ValueChanged<String> onChanged;
  final int maxLength;

  @override
  State<NumberPad> createState() => NumberPadState();
}

class NumberPadState extends State<NumberPad> {
  void resetPad() {
    _pin = '';
  }

  String _pin = '';

  final List<List<NumberKey>> padKeys = [
    [
      NumberKey(key: '1'),
      NumberKey(key: '2'),
      NumberKey(key: '3'),
    ],
    [
      NumberKey(key: '4'),
      NumberKey(key: '5'),
      NumberKey(key: '6'),
    ],
    [
      NumberKey(key: '7'),
      NumberKey(key: '8'),
      NumberKey(key: '9'),
    ],
    [
      NumberKey(key: 'delete'),
      NumberKey(key: '0'),
      NumberKey(key: ''),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondary,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: padKeys.map((row) {
            return Row(
              children: row.map((key) {
                return Expanded(
                  child: NumberKeyBuilder(
                    numberKey: key,
                    onPressed: () {
                      switch (key.key) {
                        case 'delete':
                          if (_pin.isNotEmpty) {
                            _pin = _pin.substring(0, _pin.length - 1);
                          }
                          break;
                        default:
                          if (_pin.length < widget.maxLength) {
                            _pin += key.key;
                          }
                      }
                      widget.onChanged(_pin);
                    },
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NumberKey {
  NumberKey({required this.key});

  final String key;
}

class NumberKeyBuilder extends StatelessWidget {
  const NumberKeyBuilder({
    super.key,
    required this.numberKey,
    required this.onPressed,
  });

  final NumberKey numberKey;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (numberKey.key.isEmpty) {
      return const SizedBox();
    }

    final theme = Theme.of(context);
    if (numberKey.key == 'delete') {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: AspectRatio(
            aspectRatio: 5 / 3,
            child: Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.backspace_outlined,
                size: theme.textTheme.displaySmall?.fontSize,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: AspectRatio(
          aspectRatio: 5 / 3,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              numberKey.key,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
