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
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('매입 요청 (역경매)', style: TextStyle(fontWeight: FontWeight.w900)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.ink100),
        ),
      ),
      body: Column(children: [
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
                  color: Colors.purple.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('💰 역경매', style: TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
              const Text('팔고 싶으세요?', style: TextStyle(color: AppColors.ink, fontSize: 22, fontWeight: FontWeight.w900)),
              Row(children: const [
                Text('딜러가 ', style: TextStyle(color: AppColors.ink, fontSize: 22, fontWeight: FontWeight.w900)),
                Text('먼저 찾아옵니다', style: TextStyle(color: Colors.purple, fontSize: 22, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 4),
              const Text('희망 조건만 등록하시면 견적이 옵니다', style: TextStyle(color: AppColors.ink600, fontSize: 12)),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.ink100),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('매입 요청 등록은 웹/앱 로그인 후 사용 가능')));
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
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.ink100)),
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
                                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.ink400),
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
