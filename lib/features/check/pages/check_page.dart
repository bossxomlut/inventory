// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
//
// import '../../../domain/entities/check/inventory_check.dart';
// import '../../../domain/entities/get_id.dart';
// import '../../../domain/entities/product/inventory.dart';
// import '../../../shared_widgets/bottom_sheet.dart';
// import '../../../shared_widgets/button/plus_minus_input_view.dart';
// import '../../../shared_widgets/scanner_page.dart';
// import '../../../shared_widgets/search/search_item_widget.dart';
// import '../../product/widget/product_card.dart';
// import '../providers/inventory_check_provider.dart';
//
// class InventoryCheckPage extends ConsumerStatefulWidget {
//   const InventoryCheckPage({super.key});
//
//   @override
//   ConsumerState<InventoryCheckPage> createState() => _InventoryCheckPageState();
// }
//
// class _InventoryCheckPageState extends ConsumerState<InventoryCheckPage> {
//   Product? selectedProduct;
//
//   void _openProductDetailBTS(Product product) async {
//     final result = await InventoryAdjustBottomSheet(product: product).show(context);
//     if (result != null) {
//       final sessionNotifier = ref.read(activeInventoryCheckSessionProvider.notifier);
//       final session = ref.read(activeInventoryCheckSessionProvider);
//
//       if (session != null) {
//         final check = CheckedProduct(
//           id: undefinedId,
//           product: product,
//           expectedQuantity: product.quantity,
//           actualQuantity: result.quantity,
//           checkDate: DateTime.now(),
//           checkedBy: session.createdBy,
//           note: result.note.isEmpty ? null : result.note,
//           barcode: product.barcode,
//         );
//         await sessionNotifier.addInventoryCheck(check);
//       }
//     }
//   }
//
//   void _onBarcodeScanned(Barcode barcode) async {
//     final searchNotifier = ref.read(productSearchProvider.notifier);
//     final product = await searchNotifier.findByBarcode(barcode.rawValue ?? '');
//
//     if (product != null) {
//       _openProductDetailBTS(product);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Không tìm thấy sản phẩm với mã: ${barcode.rawValue}')),
//       );
//     }
//   }
//
//   void _onSearchProduct() async {
//     final product = await SearchItemWidget<Product>(
//       itemBuilder: (context, product, index) {
//         return ProductCard(
//           product: product,
//           onTap: () => Navigator.pop(context, product),
//         );
//       },
//       searchItems: (keyword) async {
//         final searchNotifier = ref.read(productSearchProvider.notifier);
//         await searchNotifier.searchProducts(keyword);
//         final searchState = ref.read(productSearchProvider);
//         return searchState.maybeWhen(
//           data: (products) => products,
//           orElse: () => <Product>[],
//         );
//       },
//       onAddItem: () {
//         // TODO: Navigate to add product page if needed
//       },
//     ).show(context);
//
//     if (product != null) {
//       _openProductDetailBTS(product);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Kiểm kê sản phẩm')),
//       body: Column(
//         children: [
//           SizedBox(
//             height: 300,
//             child: ScannerView(
//               onBarcodeScanned: _onBarcodeScanned,
//               singleScan: true,
//             ),
//           ),
//           Expanded(child: Consumer(
//             builder: (context, ref, child) {
//               final session = ref.watch(activeInventoryCheckSessionProvider);
//               if (session == null) {
//                 return const Center(child: Text('Chưa có phiên kiểm kê nào'));
//               }
//
//               return ListView.builder(
//                 itemCount: session.checks.length,
//                 itemBuilder: (context, index) {
//                   final check = session.checks[index];
//                   return ProductCard(
//                       product: check.product,
//                       onTap: () {
//                         // _openProductDetailBTS(check.product);
//                       });
//                 },
//               );
//             },
//           )),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.search),
//         onPressed: _onSearchProduct,
//       ),
//     );
//   }
// }
//
// class InventoryAdjustBottomSheet extends StatefulWidget with ShowBottomSheet<_InventoryAdjustResult> {
//   final Product product;
//   const InventoryAdjustBottomSheet({super.key, required this.product});
//
//   @override
//   State<InventoryAdjustBottomSheet> createState() => _InventoryAdjustBottomSheetState();
// }
//
// class _InventoryAdjustBottomSheetState extends State<InventoryAdjustBottomSheet> {
//   late int quantity;
//   final TextEditingController noteController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     quantity = widget.product.quantity;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(widget.product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               const Text('Số lượng kiểm kê:', style: TextStyle(fontSize: 16)),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: PlusMinusInputView(
//                   initialValue: quantity,
//                   minValue: 0,
//                   onChanged: (val) => setState(() => quantity = val),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: noteController,
//             decoration: const InputDecoration(
//               labelText: 'Ghi chú (tuỳ chọn)',
//               border: OutlineInputBorder(),
//             ),
//             minLines: 1,
//             maxLines: 3,
//           ),
//           const SizedBox(height: 18),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Huỷ'),
//               ),
//               const SizedBox(width: 12),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context, _InventoryAdjustResult(quantity, noteController.text));
//                 },
//                 child: const Text('Lưu'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _InventoryAdjustResult {
//   final int quantity;
//   final String note;
//   _InventoryAdjustResult(this.quantity, this.note);
// }
//
// // Dummy search bottom sheet for demo - REMOVE THIS
// // class DummyProductSearchBottomSheet extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     final demoProducts = [
// //       Product(id: 1, name: 'Sản phẩm A', quantity: 10, price: 10000),
// //       Product(id: 2, name: 'Sản phẩm B', quantity: 5, price: 20000),
// //     ];
// //     return SafeArea(
// //       child: ListView.separated(
// //         shrinkWrap: true,
// //         itemCount: demoProducts.length,
// //         separatorBuilder: (_, __) => const Divider(),
// //         itemBuilder: (context, index) {
// //           final product = demoProducts[index];
// //           return ListTile(
// //             title: Text(product.name),
// //             subtitle: Text('Tồn kho: ${product.quantity}'),
// //             onTap: () => Navigator.pop(context, product),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
