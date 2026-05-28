import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_theme.dart';

class ServiceShopsPage extends StatefulWidget {
  const ServiceShopsPage({super.key});
  @override
  State<ServiceShopsPage> createState() => _ServiceShopsPageState();
}

class _ServiceShopsPageState extends State<ServiceShopsPage> {
  List<dynamic> shops = [];
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await apiClient.serviceShops();
    if (mounted) setState(() { shops = r; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('정비소 찾기', style: TextStyle(fontWeight: FontWeight.w900)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.ink100),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('전국 ${shops.length}개 검증 정비소', style: const TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 10),
                    Row(children: const [
                      Text('정비소 ', style: TextStyle(color: AppColors.ink, fontSize: 22, fontWeight: FontWeight.w900)),
                      Text('찾기', style: TextStyle(color: AppColors.emerald, fontSize: 22, fontWeight: FontWeight.w900)),
                    ]),
                    const SizedBox(height: 4),
                    const Text('출장 점검 · 검증 리포트 · 견적 비교', style: TextStyle(color: AppColors.ink600, fontSize: 12)),
                  ],
                ),
              ),
              Container(height: 1, color: AppColors.ink100),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: shops.length,
                  itemBuilder: (_, i) {
                    final s = shops[i] as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.ink100)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.build, color: AppColors.emerald, size: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(child: Text(s['name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      if (s['is_featured'] == true) Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: const Text('추천', style: TextStyle(color: AppColors.emerald, fontSize: 9, fontWeight: FontWeight.w700))),
                                    ]),
                                    const SizedBox(height: 2),
                                    Text('${s['region'] ?? ''} · ${s['address'] ?? ''}', style: const TextStyle(color: AppColors.ink400, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ]),
                            if ((s['intro'] ?? '').toString().isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(s['intro'], style: const TextStyle(fontSize: 12, color: AppColors.ink800), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                            const SizedBox(height: 10),
                            Row(children: [
                              const Icon(Icons.star, color: Colors.amber, size: 13),
                              const SizedBox(width: 2),
                              Text('${s['rating']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              Text(' (${s['review_count']})', style: const TextStyle(fontSize: 10, color: AppColors.ink400)),
                              const Spacer(),
                              if ((s['specialties'] as List?)?.isNotEmpty == true)
                                Text('${(s['specialties'] as List).length}종 전문', style: const TextStyle(fontSize: 10, color: AppColors.ink400)),
                            ]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
    );
  }
}
