import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/providers/fish_providers.dart';
import '../../../../models/fish.dart';

class EncyclopediaPage extends StatelessWidget {
  const EncyclopediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.encyclopediaTab),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: _EncyclopediaContent(),
      ),
    );
  }
}

class _EncyclopediaContent extends ConsumerWidget {
  const _EncyclopediaContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fishListAsync = ref.watch(fishListFutureProvider);
    final query = ref.watch(searchQueryProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchAndFilters(query: query, selectedRegion: selectedRegion),
        const SizedBox(height: AppConstants.paddingMedium),
        Expanded(
          child: fishListAsync.when(
            data: (list) {
              final filtered = _applyFilters(list, query, selectedRegion);
              if (filtered.isEmpty) {
                return const Center(child: Text('未找到匹配的鱼类'));
              }
              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final fish = filtered[index];
                  return _FishListItem(fish: fish);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('加载失败: $e')),
          ),
        ),
      ],
    );
  }

  List<Fish> _applyFilters(List<Fish> list, String query, String? region) {
    return list.where((f) {
      final q = query.trim().toLowerCase();
      final matchQuery = q.isEmpty ||
          f.scientificName.toLowerCase().contains(q) ||
          f.commonNames.any((n) => n.toLowerCase().contains(q)) ||
          f.family.toLowerCase().contains(q);
      final matchRegion = region == null || f.regions.contains(region);
      return matchQuery && matchRegion;
    }).toList();
  }
}

class _SearchAndFilters extends ConsumerWidget {
  final String query;
  final String? selectedRegion;
  const _SearchAndFilters({required this.query, required this.selectedRegion});

  static const regions = [
    {'code': null, 'name': '全部'},
    {'code': 'EA', 'name': '东大西洋'},
    {'code': 'IO', 'name': '印度洋'},
    {'code': 'WP', 'name': '西太平洋'},
    {'code': 'WA', 'name': '西大西洋'},
    {'code': 'CA', 'name': '加勒比海'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: '搜索鱼类（学名/俗名/科）',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: regions.map((r) {
              final code = r['code'] as String?;
              final name = r['name'] as String;
              final selected = selectedRegion == code;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: selected,
                  label: Text(name),
                  onSelected: (_) => ref.read(selectedRegionProvider.notifier).state = code,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FishListItem extends StatelessWidget {
  final Fish fish;
  const _FishListItem({required this.fish});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            child: (fish.image != null && fish.image!.isNotEmpty)
                ? Image.asset(
                    fish.image!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  )
                : Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fish.scientificName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (fish.commonNames.isNotEmpty)
                  Text(
                    fish.commonNames.join(' / '),
                    style: const TextStyle(color: Colors.grey),
                  ),
                Text(
                  '科：${fish.family}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}