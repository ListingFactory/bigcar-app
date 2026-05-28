import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../api/api_client.dart';
import '../api/models/listing.dart';
import '../theme/app_theme.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_page.dart';
import 'listings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? data;
  List<CategoryModel> rootCats = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([apiClient.home(), apiClient.categories()]);
      if (mounted) {
        setState(() {
          data = results[0] as Map<String, dynamic>;
          rootCats = results[1] as List<CategoryModel>;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  List<Listing> _list(String key) {
    final raw = (data?[key] as List?) ?? [];
    return raw.map((j) => Listing.fromJson(j)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stats = data?['stats'] as Map<String, dynamic>?;
    final urgent = _list('urgent');
    final featured = _list('featured');
    final verified = _list('verified');
    final latest = _list('latest');
    final allChildren = rootCats.expand((r) => r.children).toList();

    return Scaffold(
      backgroundColor: AppColors.ink50,
      body: RefreshIndicator(
        color: AppColors.cyanDark,
        onRefresh: _load,
        child: loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.cyanDark))
            : CustomScrollView(
                slivers: [
                  // 다크 헤로 SliverAppBar
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: false,
                    backgroundColor: AppColors.ink,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.ink, Color(0xFF164E63), AppColors.ink],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.cyan.withValues(alpha: 0.15),
                                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle)),
                                      const SizedBox(width: 6),
                                      const Text('실시간 거래 진행중', style: TextStyle(color: AppColors.cyan, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text('중고 중장비,', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.1)),
                                const Text('한 번에', style: TextStyle(color: AppColors.cyan, fontSize: 28, fontWeight: FontWeight.w900, height: 1.1)),
                                const SizedBox(height: 8),
                                Text('검증 매물 ${stats?['verified'] ?? 0}건 · 전체 ${stats?['total'] ?? 0}건',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                                const SizedBox(height: 16),
                                // 통계 3개
                                Row(
                                  children: [
                                    _statCard('${stats?['total'] ?? 0}', '매물'),
                                    const SizedBox(width: 8),
                                    _statCard('${stats?['verified'] ?? 0}', '검증'),
                                    const SizedBox(width: 8),
                                    _statCard('${stats?['today'] ?? 0}', '오늘'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 카테고리 가로 스크롤
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('카테고리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingsPage())),
                            child: const Text('전체보기 →', style: TextStyle(color: AppColors.cyanDark, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: allChildren.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final c = allChildren[i];
                          return InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingsPage(categorySlug: c.slug, categoryName: c.name))),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 80,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.ink100),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(color: AppColors.cyan.withValues(alpha: 0.1), shape: BoxShape.circle),
                                    child: const Icon(Icons.precision_manufacturing, color: AppColors.cyanDark, size: 20),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(c.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  if (urgent.isNotEmpty) _section('🔥 오늘의 급매물', urgent.take(4).toList()),
                  if (featured.isNotEmpty) _section('⭐ 추천 매물', featured.take(4).toList()),
                  if (verified.isNotEmpty) _section('✓ 검증 매물', verified.take(4).toList()),
                  if (latest.isNotEmpty) _section('📰 신규 등록', latest.take(6).toList()),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.w900)),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Listing> items) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.66),
              itemCount: items.length,
              itemBuilder: (_, i) => ListingCard(
                listing: items[i],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailPage(slug: items[i].slug))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
