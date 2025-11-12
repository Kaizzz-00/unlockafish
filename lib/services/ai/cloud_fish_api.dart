import 'dart:typed_data';
import 'package:dio/dio.dart';

import '../ml/fish_classifier.dart';

/// iNaturalist 计算机视觉 API 客户端
class CloudFishApi {
  final Dio _dio;
  final String? jwt; // iNaturalist Node API 需要 JWT 鉴权
  CloudFishApi({Dio? dio, this.jwt}) : _dio = dio ?? Dio();

  /// 发送图片字节到 iNaturalist CV，返回 Top-K 预测
  /// 401 处理：当未提供或无效 JWT 时，服务会返回 401
  Future<List<FishPrediction>> predictFromBytes(
    Uint8List bytes, {
    int topK = 3,
    double? lat,
    double? lng,
    String? observedOn, // YYYY-MM-DD
  }) async {
    final Map<String, dynamic> formMap = {
      'image': MultipartFile.fromBytes(bytes, filename: 'image.jpg'),
    };
    if (lat != null) formMap['lat'] = lat.toString();
    if (lng != null) formMap['lng'] = lng.toString();
    if (observedOn != null && observedOn.isNotEmpty) formMap['observed_on'] = observedOn;

    final formData = FormData.fromMap(formMap);

    final headers = {
      'Accept': 'application/json',
      if (jwt != null && jwt!.isNotEmpty) 'Authorization': 'Bearer ${jwt!}',
    };

    final resp = await _dio.post(
      'https://api.inaturalist.org/v1/computervision/score_image',
      data: formData,
      options: Options(headers: headers),
    );

    final data = resp.data;
    if (data is! Map || data['results'] is! List) {
      return [];
    }

    final results = (data['results'] as List).cast<Map>();
    final preds = results.map((r) {
      final score = (r['score'] as num?)?.toDouble() ?? 0.0;
      final taxon = r['taxon'] as Map?;
      final sci = taxon?['name']?.toString();
      final common = taxon?['preferred_common_name']?.toString();
      final label = [common, sci].where((e) => e != null && e!.isNotEmpty).join(' / ');
      return FishPrediction(label: label.isEmpty ? 'Unknown' : label, confidence: score);
    }).toList();

    preds.sort((a, b) => b.confidence.compareTo(a.confidence));
    return preds.take(topK).toList();
  }
}