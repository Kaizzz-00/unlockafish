import 'dart:typed_data';
import 'package:dio/dio.dart';

import '../ml/fish_classifier.dart';

/// 本地自建推理服务客户端
/// 约定接口：POST {baseUrl}/predict
/// 请求：multipart/form-data，字段 image（jpg/png 二进制）
/// 响应：{"predictions": [{"label": "Ocellaris clownfish", "score": 0.92}, ...]}
class LocalServerApi {
  final Dio _dio;
  final String baseUrl;
  LocalServerApi({String? baseUrl, Dio? dio})
      : baseUrl = baseUrl ?? 'http://localhost:8000',
        _dio = dio ?? Dio();

  Future<List<FishPrediction>> predictFromBytes(
    Uint8List bytes, {
    int topK = 3,
  }) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: 'image.jpg'),
    });

    final resp = await _dio.post(
      '$baseUrl/predict',
      data: formData,
      options: Options(headers: {
        'Accept': 'application/json',
      }),
    );

    final data = resp.data;
    if (data is! Map || data['predictions'] is! List) {
      return [];
    }
    final results = (data['predictions'] as List).cast<Map>();
    final preds = results.map((r) {
      final score = (r['score'] as num?)?.toDouble() ?? 0.0;
      final label = (r['label']?.toString() ?? 'Unknown');
      return FishPrediction(label: label, confidence: score);
    }).toList();

    preds.sort((a, b) => b.confidence.compareTo(a.confidence));
    return preds.take(topK).toList();
  }
}