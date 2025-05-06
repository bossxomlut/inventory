import 'package:flutter/material.dart';

import '../../shared_widgets/index.dart';

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
      onBarcodeScanned: (value) {
        setState(() {
          barcodes.insert(0, value.displayValue ?? '');
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
