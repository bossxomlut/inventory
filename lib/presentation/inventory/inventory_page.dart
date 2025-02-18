import 'package:flutter/material.dart';

import '../../widget/index.dart';
import '../../widget/scanner_page.dart';
import '../utils/index.dart';

@RoutePage()
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with StateTemplate<InventoryPage> {
  List<String> barcodes = [];

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return const CustomAppBar(
      title: 'Kiểm kê',
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return InnerScannerPage(
      onBarcodeScanned: (String value) {
        setState(() {
          barcodes.insert(0, value);
        });
      },
      child: ListView(
        children: [
          ...barcodes.map(
            (e) => ListTile(
              title: Text(e),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    );
  }
}

class InnerScannerPage extends StatelessWidget with ShowDialog {
  const InnerScannerPage({
    super.key,
    required this.onBarcodeScanned,
    required this.child,
  });

  final ValueChanged<String> onBarcodeScanned;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 3,
          child: ScannerPage(
            onBarcodeScanned: (String value) {
              onBarcodeScanned(value);
            },
          ),
        ),
        const AppDivider(),
        Expanded(
          flex: 5,
          child: child,
        ),
      ],
    );
  }
}
