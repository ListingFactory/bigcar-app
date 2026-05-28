import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/models/listing.dart';
import '../theme/app_theme.dart';

class ListingDetailPage extends StatefulWidget {
  final String slug;
  const ListingDetailPage({super.key, required this.slug});
  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  Listing? listing;
  bool loading = true;
  int currentImage = 0;
  bool isFavorite = false;
  final pageController = PageController();

  @override
  void initState() {
    super.initState();
    _load();
    _loadFavorite();
  }

  Future<void> _load() async {
    try {
      final l = await apiClient.listing(widget.slug);
      if (mounted) setState(() { listing = l; loading = false; });
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    if (mounted) setState(() => isFavorite = favs.contains(widget.slug));
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    setState(() {
      if (favs.contains(widget.slug)) { favs.remove(widget.slug); isFavorite = false; }
      else { favs.add(widget.slug); isFavorite = true; }
    });
    await prefs.setStringList('favorites', favs);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.cyanDark)));
    if (listing == null) return const Scaffold(body: Center(child: Text('매물을 찾을 수 없습니다')));

    final l = listing!;
    final images = l.media.isNotEmpty ? l.media.map((m) => {'url': m.url, 'label': m.roleLabel}).toList() : [{'url': l.thumbnailUrl, 'label': '대표'}];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.ink,
            foregroundColor: Colors.white,
            actions: [
              IconButton(icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? AppColors.red : Colors.white), onPressed: _toggleFavorite),
              IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: pageController,
                    onPageChanged: (i) => setState(() => currentImage = i),
                    itemCount: images.length,
                    itemBuilder: (_, i) {
                      final url = images[i]['url']!;
                      if (url.endsWith('.svg')) {
                        return SvgPicture.network(url, fit: BoxFit.cover, placeholderBuilder: (_) => Container(color: AppColors.ink100));
                      }
                      return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, placeholder: (_, __) => Container(color: AppColors.ink100));
                    },
                  ),
                  // 카운터 + 라벨
                  Positioned(
                    bottom: 60, left: 12,
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                        child: Text('${currentImage + 1} / ${images.length}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.cyan.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)),
                        child: Text(images[currentImage]['label']!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                  // 썸네일
                  Positioned(
                    bottom: 6, left: 0, right: 0, height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 4),
                      itemBuilder: (_, i) {
                        final isActive = i == currentImage;
                        return GestureDetector(
                          onTap: () => pageController.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                          child: Container(
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isActive ? AppColors.cyan : Colors.white.withValues(alpha: 0.3), width: isActive ? 2 : 1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: images[i]['url']!.endsWith('.svg')
                                  ? SvgPicture.network(images[i]['url']!, fit: BoxFit.cover, placeholderBuilder: (_) => Container(color: AppColors.ink400))
                                  : CachedNetworkImage(imageUrl: images[i]['url']!, fit: BoxFit.cover),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(spacing: 4, children: [
                    if (l.isUrgent) _badge('🔥 급매', AppColors.red),
                    if (l.isFeatured) _badge('⭐ 추천', AppColors.cyan),
                    if (l.isVerified) _badge('✓ 검증완료', AppColors.emerald),
                  ]),
                  const SizedBox(height: 10),
                  Text('${l.categoryName} · ${l.makeName}${l.modelName != null ? " · ${l.modelName}" : ""}',
                      style: const TextStyle(color: AppColors.ink400, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(l.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.3)),
                  const SizedBox(height: 16),
                  const Text('판매가', style: TextStyle(color: AppColors.ink400, fontSize: 11)),
                  Text(l.formattedPrice, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.ink)),
                  const SizedBox(height: 20),
                  Container(height: 1, color: AppColors.ink100),
                  const SizedBox(height: 16),
                  if (l.year != null) _info('연식', '${l.year}년'),
                  if (l.operatingHours != null) _info('가동시간', '${_comma(l.operatingHours!)}h'),
                  if (l.mileageKm != null) _info('주행거리', '${_comma(l.mileageKm!)}km'),
                  if (l.region != null) _info('지역', l.region!),
                  _info('상태', l.status == 'active' ? '게시중' : l.status),
                ],
              ),
            ),
          ),
          if (l.description != null && l.description!.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('상세 설명', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Text(l.description!, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.ink800)),
                  ],
                ),
              ),
            ),
          if (l.specs.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('상세 스펙', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    ...l.specs.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(width: 100, child: Text(s.label, style: const TextStyle(color: AppColors.ink400, fontSize: 13))),
                          Expanded(child: Text('${s.value}${s.unit != null ? " ${s.unit}" : ""}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), offset: const Offset(0, -2), blurRadius: 8)]),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: _toggleFavorite,
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? AppColors.red : AppColors.ink600, size: 18),
              label: const SizedBox.shrink(),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14), side: const BorderSide(color: AppColors.ink200), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showInquirySheet(),
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('문의 작성'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyanDark, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('전화'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.ink, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInquirySheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('문의하기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '이름')),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: '연락처'), keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            TextField(controller: msgCtrl, decoration: const InputDecoration(labelText: '문의 내용'), maxLines: 4),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || msgCtrl.text.isEmpty) return;
                  final ok = await apiClient.sendInquiry(widget.slug, name: nameCtrl.text, phone: phoneCtrl.text, message: msgCtrl.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? '문의가 접수되었습니다' : '실패'), backgroundColor: ok ? AppColors.emerald : AppColors.red));
                },
                child: const Text('문의 보내기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.ink400, fontSize: 13))),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
  );

  String _comma(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
