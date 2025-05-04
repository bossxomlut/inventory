// Provider để quản lý trạng thái loading
import 'package:riverpod/riverpod.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);
