import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_theme.dart';

class PurchaseRequestsPage extends StatefulWidget {
  const PurchaseRequestsPage({super.key});
  @override
  State<PurchaseRequestsPage> createState() => _PurchaseRequestsPageState();
}

class _PurchaseRequestsPageState extends State<PurchaseRequestsPage> {
  List<dynamic> reqs = [];
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await apiClient.purchaseRequests();
    if (mounted) setState(() { reqs = r; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B0764),
        foregroundColor: Colors.white,
        title: const Text('매입 요청 (역경매)', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF3B0764), AppColors.ink])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('💰 역경매', style: TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
              const Text('팔고 싶으세요?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const Text('딜러가 먼저 찾아옵니다', style: TextStyle(color: Colors.purpleAccent, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('희망 조건만 등록하시면 견적이 옵니다', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('매입 요청 등록은 웹/앱 로그인 후 사용 가능 (곧 출시)')));
              },
              icon: const Icon(Icons.add),
              label: const Text('새 매입 요청 등록'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : reqs.isEmpty
                  ? const Center(child: Text('진행중 요청이 없습니다', style: TextStyle(color: AppColors.ink400)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: reqs.length,
                      itemBuilder: (_, i) {
                        final r = reqs[i] as Map<String, dynamic>;
                        final price = r['desired_price'] as int? ?? 0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(r['category'] ?? '', style: const TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.w700))),
                                  const SizedBox(width: 6),
                                  if (r['make'] != null) Text(r['make'], style: const TextStyle(fontSize: 11, color: AppColors.ink400)),
                                  const Spacer(),
                                  Text('견적 ${r['bid_count']}', style: const TextStyle(color: AppColors.cyanDark, fontSize: 11, fontWeight: FontWeight.w700)),
                                ]),
                                const SizedBox(height: 8),
                                Text(r['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                                if (price > 0) ...[
                                  const SizedBox(height: 8),
                                  Text('희망가 ${(price / 10000).floor()}만원', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.purple)),
                                ],
                                const SizedBox(height: 8),
                                Row(children: [
                                  Icon(Icons.location_on_outlined, size: 12, color: AppColors.ink400),
                                  Text(' ${r['region'] ?? '전국'}', style: const TextStyle(color: AppColors.ink400, fontSize: 11)),
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
