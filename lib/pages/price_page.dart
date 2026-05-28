import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_theme.dart';

class PricePage extends StatefulWidget {
  const PricePage({super.key});
  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  List<dynamic> summaries = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await apiClient.priceIndex();
    if (mounted) setState(() { summaries = r; loading = false; });
  }

  String _fmt(int p) => p >= 100000000 ? '${(p/100000000).toStringAsFixed(1)}억' : '${(p/10000).floor()}만';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('시세 분석', style: TextStyle(fontWeight: FontWeight.w900)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.ink100),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.cyanDark))
          : Column(
              children: [
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
                          color: AppColors.cyan.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('실거래 기반 분석', style: TextStyle(color: AppColors.cyanDarker, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 10),
                      Row(children: const [
                        Text('중장비 ', style: TextStyle(color: AppColors.ink, fontSize: 22, fontWeight: FontWeight.w900)),
                        Text('시세 인사이트', style: TextStyle(color: AppColors.cyanDark, fontSize: 22, fontWeight: FontWeight.w900)),
                      ]),
                      const SizedBox(height: 4),
                      Text('${summaries.length}개 카테고리 · 실시간 가격 분석', style: const TextStyle(color: AppColors.ink600, fontSize: 12)),
                    ],
                  ),
                ),
                Container(height: 1, color: AppColors.ink100),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: summaries.length,
                    itemBuilder: (_, i) {
                      final s = summaries[i] as Map<String, dynamic>;
                      final cat = s['category'] as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.ink100)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(child: Text(cat['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900))),
                                Text('${s['count']}건', style: const TextStyle(color: AppColors.ink400, fontSize: 11)),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                _priceBox('최저', _fmt(s['min']), AppColors.emerald),
                                const SizedBox(width: 6),
                                _priceBox('평균', _fmt(s['avg']), AppColors.cyanDark),
                                const SizedBox(width: 6),
                                _priceBox('최고', _fmt(s['max']), AppColors.red),
                              ]),
                              const SizedBox(height: 8),
                              Row(children: [
                                const Text('중간값: ', style: TextStyle(color: AppColors.ink400, fontSize: 11)),
                                Text(_fmt(s['p50']), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              ]),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _priceBox(String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    ),
  );
}
