import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models/listing.dart';
import '../theme/app_theme.dart';
import 'listings_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryModel> cats = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await apiClient.categories();
    if (mounted) setState(() { cats = r; loading = false; });
  }

  IconData _iconFor(String key) {
    if (key.contains('truck')) return Icons.local_shipping;
    if (key == 'excavator') return Icons.construction;
    if (key == 'forklift') return Icons.precision_manufacturing;
    if (key == 'crane' || key == 'cargo_crane') return Icons.height;
    if (key == 'tractor' || key == 'combine') return Icons.agriculture;
    if (key.contains('loader') || key == 'bulldozer') return Icons.front_loader;
    return Icons.build_circle;
  }

  Color _colorFor(String rootKey) {
    switch (rootKey) {
      case 'heavy_equipment': return Colors.amber;
      case 'special_vehicle': return Colors.indigo;
      case 'truck': return Colors.blue;
      case 'farming': return Colors.green;
    }
    return AppColors.cyanDark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('전체 카테고리')),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.cyanDark))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: cats.map((root) => Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(width: 4, height: 18, decoration: BoxDecoration(color: _colorFor(root.key), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Text(root.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 6),
                      Text('${root.children.length}종', style: const TextStyle(color: AppColors.ink400, fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.4),
                      itemCount: root.children.length,
                      itemBuilder: (_, i) {
                        final c = root.children[i];
                        return InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingsPage(categorySlug: c.slug, categoryName: c.name))),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.ink100)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_iconFor(c.key), color: _colorFor(root.key), size: 22),
                                const SizedBox(height: 6),
                                Text(c.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )).toList(),
            ),
    );
  }
}
