import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../widget/index.dart';
import '../../widget/scanner_page.dart';
import '../utils/index.dart';

@RoutePage()
class AnalyzeScannerPage extends StatefulWidget {
  const AnalyzeScannerPage({super.key});

  @override
  State<AnalyzeScannerPage> createState() => _AnalyzeScannerPageState();
}

class _AnalyzeScannerPageState extends State<AnalyzeScannerPage> with StateTemplate<AnalyzeScannerPage> {
  Stopwatch stopwatch = Stopwatch();

  bool isProcessing = true;

  int countScan = 0;

  int maxCount = 100;

  List<Barcode> barcodes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return const CustomAppBar(
      title: 'Analyze Scanner',
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return InnerScannerPage(
      onBarcodeScanned: (value) {
        if (!isProcessing) {
          return;
        }

        if (countScan == 0) {
          stopwatch.reset();
          stopwatch.start();
        }

        countScan++;

        barcodes.add(value);

        if (countScan >= maxCount) {
          stopwatch.stop();
          setState(() {
            isProcessing = false;
          });
        }
      },
      child: Builder(
        builder: (BuildContext context) {
          if (isProcessing) {
            return const Center(
              child: Column(
                children: [
                  Text('Hãy đặt mã vạch vào khung quét'),
                  SizedBox(height: 20),
                  Text('Đang xử lý...'),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
            );
          }

          return ListView(
            children: [
              ListTile(
                title: Text('Tổng thời gian scan ${maxCount} barcodes: ${getTotalScanTime()} ms'),
              ),
              ListTile(
                title: Text('Thời gian trung bình: ${getTotalScanTime() / maxCount} ms'),
              ),
              ListTile(
                title: Text('Loại Barcodes được tìm thấy: ${barcodes.map((e) => e.type.name).toSet().join(', ')}'),
              ),

              //danh sách barcodes
              ...barcodes.mapIndexed(
                (i, e) => ListTile(
                  title: Text('${i + 1}: [${e.type.name}] - ${e.displayValue}'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        //restart
        setState(() {
          isProcessing = true;
          countScan = 0;
          barcodes.clear();
        });
      },
      child: const Icon(Icons.restart_alt),
    );
  }

  int getTotalScanTime() {
    return stopwatch.elapsedMilliseconds;
  }
}
