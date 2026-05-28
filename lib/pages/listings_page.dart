import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models/listing.dart';
import '../theme/app_theme.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_page.dart';

class ListingsPage extends StatefulWidget {
  final String? categorySlug;
  final String? categoryName;
  const ListingsPage({super.key, this.categorySlug, this.categoryName});
  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  List<Listing> items = [];
  bool loading = true;
  String sort = 'latest';
  bool verified = false;
  bool urgent = false;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final params = <String, dynamic>{'sort': sort};
    if (widget.categorySlug != null) params['category'] = widget.categorySlug;
    if (verified) params['verified'] = 1;
    if (urgent) params['urgent'] = 1;
    if (searchController.text.isNotEmpty) params['q'] = searchController.text;
    final r = await apiClient.listings(params: params);
    if (mounted) setState(() { items = r; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? '매물 검색', style: const TextStyle(fontWeight: FontWeight.w900)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onSubmitted: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: '모델·키워드 검색',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { searchController.clear(); _load(); })
                        : null,
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('최신순', sort == 'latest', () => setState(() { sort = 'latest'; _load(); })),
                  _chip('인기순', sort == 'popular', () => setState(() { sort = 'popular'; _load(); })),
                  _chip('저가순', sort == 'price_low', () => setState(() { sort = 'price_low'; _load(); })),
                  _chip('고가순', sort == 'price_high', () => setState(() { sort = 'price_high'; _load(); })),
                  _chip('최신연식', sort == 'year_new', () => setState(() { sort = 'year_new'; _load(); })),
                  const SizedBox(width: 8),
                  _toggleChip('✓ 검증', verified, AppColors.emerald, () => setState(() { verified = !verified; _load(); })),
                  _toggleChip('🔥 급매', urgent, AppColors.red, () => setState(() { urgent = !urgent; _load(); })),
                ],
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.cyanDark))
                : items.isEmpty
                    ? const Center(child: Text('매물이 없습니다', style: TextStyle(color: AppColors.ink400)))
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
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailPage(slug: items[i].slug))),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.ink600, fontWeight: FontWeight.w600)),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.ink50,
      selectedColor: AppColors.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
      showCheckmark: false,
    ),
  );

  Widget _toggleChip(String label, bool selected, Color color, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : color, fontWeight: FontWeight.w700)),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: color.withValues(alpha: 0.08),
      selectedColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: color.withValues(alpha: 0.3))),
      showCheckmark: false,
    ),
  );
}
