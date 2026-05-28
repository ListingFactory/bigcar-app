import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/models/listing.dart';
import '../theme/app_theme.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Listing> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final slugs = prefs.getStringList('favorites') ?? [];
    if (slugs.isEmpty) {
      setState(() { items = []; loading = false; });
      return;
    }
    // 각 매물 상세 정보를 받아옴 (간단히 슬러그별 호출)
    final List<Listing> loaded = [];
    for (final slug in slugs) {
      try {
        final l = await apiClient.listing(slug);
        loaded.add(l);
      } catch (_) {}
    }
    if (mounted) setState(() { items = loaded; loading = false; });
  }

  Future<void> _remove(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    favs.remove(slug);
    await prefs.setStringList('favorites', favs);
    if (mounted) setState(() => items.removeWhere((l) => l.slug == slug));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 매물'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('favorites');
                if (mounted) setState(() => items = []);
              },
              child: const Text('전체 삭제', style: TextStyle(color: AppColors.red, fontSize: 13)),
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.cyanDark))
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: AppColors.ink100, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite_border, size: 36, color: AppColors.ink400),
                      ),
                      const SizedBox(height: 14),
                      const Text('찜한 매물이 없어요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      const Text('마음에 드는 매물을 하트로 저장하세요', style: TextStyle(color: AppColors.ink400, fontSize: 13)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.cyanDark,
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.66,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => ListingCard(
                      listing: items[i],
                      isFavorite: true,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailPage(slug: items[i].slug))),
                      onFavTap: () => _remove(items[i].slug),
                    ),
                  ),
                ),
    );
  }
}
