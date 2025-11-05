import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/fish_repository.dart';
import '../../models/fish.dart';

final fishRepositoryProvider = Provider<FishRepository>((ref) {
  return FishRepository();
});

final fishListFutureProvider = FutureProvider<List<Fish>>((ref) async {
  final repo = ref.read(fishRepositoryProvider);
  return repo.getAll();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedRegionProvider = StateProvider<String?>((ref) => null); // null表示全部