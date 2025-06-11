import 'package:flutter_riverpod/flutter_riverpod.dart';

final textSearchProvider = StateProvider.autoDispose<String>((ref) => '');
final isSearchVisibleProvider = StateProvider.autoDispose<bool>((ref) => false);
