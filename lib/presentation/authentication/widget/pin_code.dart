import 'package:flutter/material.dart';

class PinCodeWidget extends StatelessWidget {
  const PinCodeWidget(
    this.pin, {
    super.key,
    this.showPin = false,
    this.isDisabled = false,
  });

  final String pin;
  final bool showPin;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int length = pin.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 46,
            height: 46,
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDisabled
                    ? theme.disabledColor
                    : index <= length
                        ? theme.primaryColor
                        : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.inversePrimary,
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(-2, 3),
                ),
              ],
              color: theme.cardColor,
            ),
            child: Builder(builder: (context) {
              if (index >= length) {
                return const SizedBox();
              }

              return Center(
                child: showPin
                    ? Text(
                        pin[index],
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      )
                    : Icon(
                        Icons.circle,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
              );
            }),
          );
        },
      ),
    );
  }
}
