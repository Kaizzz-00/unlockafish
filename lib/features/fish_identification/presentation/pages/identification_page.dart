import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../services/ml/fish_classifier.dart';
import '../../../../services/ai/cloud_fish_api.dart';
import '../../../../services/ai/local_server_api.dart';

enum CloudProvider { iNaturalist, local }

class IdentificationPage extends StatefulWidget {
  const IdentificationPage({super.key});

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  late final FishClassifier _classifier;
  bool _modelReady = false;
  bool _running = false;
  Uint8List? _imageBytes;
  List<FishPrediction> _predictions = const [];
  // 云端识别客户端与模式开关（Web 默认启用云端）
  String? _inatJwt; // iNaturalist JWT，用于云端识别
  late CloudFishApi _cloudApi;
  late LocalServerApi _localApi;
  String _localBaseUrl = 'http://localhost:8000';
  bool _useCloud = kIsWeb;
  CloudProvider _provider = CloudProvider.iNaturalist;

  @override
  void initState() {
    super.initState();
    _classifier = createClassifier();
    // 配置 iNaturalist JWT（如已获取，可填入字符串）
    _inatJwt = null; // 例如: 'eyJhbGciOiJI...'
    _cloudApi = CloudFishApi(jwt: _inatJwt);
    _localApi = LocalServerApi(baseUrl: _localBaseUrl);
    _initModel();
  }

  Future<void> _initModel() async {
    if (kIsWeb) {
      // Web 默认使用云端识别，不加载本地模型
      setState(() => _modelReady = true);
      return;
    }
    try {
      await _classifier.load();
      setState(() => _modelReady = true);
    } catch (e) {
      // 模型加载失败，仍允许选择图片但不进行推理
      setState(() => _modelReady = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('模型加载失败：$e')),
      );
    }
  }

  Future<void> _pickAndClassify() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _running = true;
      _predictions = const [];
    });

    try {
      List<FishPrediction> preds;
      if (_useCloud) {
        switch (_provider) {
          case CloudProvider.iNaturalist:
            preds = await _cloudApi.predictFromBytes(bytes, topK: 3);
            break;
          case CloudProvider.local:
            preds = await _localApi.predictFromBytes(bytes, topK: 3);
            break;
        }
      } else {
        preds = await _classifier.classifyBytes(bytes, topK: 3);
      }
      setState(() => _predictions = preds);
    } catch (e) {
      final msg = _useCloud
          ? (_provider == CloudProvider.iNaturalist
              ? '推理失败（云端需要 iNaturalist JWT）：$e'
              : '推理失败（请确认本地服务在 $_localBaseUrl 运行）：$e')
          : '推理失败：$e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      setState(() => _running = false);
    }
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.identifyTab),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (kIsWeb)
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '当前为 Web 预览，默认使用云端识别。\n提供商可选：iNaturalist（需JWT）或本地服务（默认 http://localhost:8000）。',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(height: AppConstants.paddingMedium),

            // 识别模式切换
            SwitchListTile(
              title: const Text('云端识别'),
              subtitle: const Text('开启则使用在线模型，关闭则使用本地模型（设备离线）'),
              value: _useCloud,
              onChanged: (v) => setState(() => _useCloud = v),
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            // 云端提供商选择与本地服务地址
            if (_useCloud) ...[
              Row(
                children: [
                  const Text('提供商：'),
                  const SizedBox(width: 8),
                  DropdownButton<CloudProvider>(
                    value: _provider,
                    onChanged: (p) => setState(() => _provider = p ?? CloudProvider.iNaturalist),
                    items: const [
                      DropdownMenuItem(
                        value: CloudProvider.iNaturalist,
                        child: Text('iNaturalist'),
                      ),
                      DropdownMenuItem(
                        value: CloudProvider.local,
                        child: Text('本地服务'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              if (_provider == CloudProvider.iNaturalist)
                Text('鉴权：${_inatJwt == null ? '未配置 JWT（可能 401）' : '已配置 JWT'}', style: const TextStyle(fontSize: 12))
              else
                Row(
                  children: [
                    const Text('服务地址：'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: _localBaseUrl,
                        decoration: const InputDecoration(hintText: 'http://localhost:8000'),
                        onChanged: (v) {
                          _localBaseUrl = v.trim();
                          _localApi = LocalServerApi(baseUrl: _localBaseUrl);
                        },
                      ),
                    ),
                  ],
                ),
            ],
            const SizedBox(height: AppConstants.paddingSmall),

            // 选择图片按钮
            ElevatedButton.icon(
              onPressed: _running ? null : _pickAndClassify,
              icon: const Icon(Icons.photo_library),
              label: const Text('选择图片并识别'),
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            // 预览所选图片
            if (_imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _imageBytes!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: AppConstants.paddingMedium),

            // 识别结果
            if (_running)
              const Center(child: CircularProgressIndicator())
            else if (_predictions.isEmpty)
              const Center(child: Text('暂无识别结果'))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _predictions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = _predictions[index];
                    return Container(
                      padding: const EdgeInsets.all(AppConstants.paddingSmall),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.biotech, size: 32),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '置信度: ${(p.confidence * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}