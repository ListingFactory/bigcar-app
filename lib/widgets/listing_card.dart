import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../api/models/listing.dart';
import '../theme/app_theme.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  final VoidCallback? onFavTap;
  final bool isFavorite;

  const ListingCard({super.key, required this.listing, this.onTap, this.onFavTap, this.isFavorite = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.ink100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: _buildImage(),
                  ),
                  // 배지
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Wrap(
                      spacing: 4,
                      children: [
                        if (listing.isUrgent) _badge('🔥 급매', AppColors.red),
                        if (listing.isFeatured) _badge('⭐ 추천', AppColors.cyan),
                        if (listing.isVerified) _badge('✓ 검증', AppColors.emerald),
                      ],
                    ),
                  ),
                  // 찜
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? AppColors.red : AppColors.ink400,
                          size: 18,
                        ),
                        onPressed: onFavTap,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ),
                  ),
                  if (listing.status == 'sold')
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: const Text('판매완료', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                ],
              ),
            ),
            // 정보
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${listing.categoryName} · ${listing.makeName}',
                    style: const TextStyle(fontSize: 10, color: AppColors.ink400),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.formattedPrice,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (listing.year != null) Text('${listing.year}년', style: const TextStyle(fontSize: 10, color: AppColors.ink600, fontWeight: FontWeight.w600)),
                      if (listing.operatingHours != null) ...[
                        const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.ink400)),
                        Text('${_comma(listing.operatingHours!)}h', style: const TextStyle(fontSize: 10, color: AppColors.ink600)),
                      ] else if (listing.mileageKm != null) ...[
                        const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.ink400)),
                        Text('${_comma(listing.mileageKm!)}km', style: const TextStyle(fontSize: 10, color: AppColors.ink600)),
                      ],
                      const Spacer(),
                      Icon(Icons.location_on_outlined, size: 11, color: AppColors.ink400),
                      const SizedBox(width: 2),
                      Text(listing.region ?? '전국', style: const TextStyle(fontSize: 10, color: AppColors.ink400)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final url = listing.thumbnailUrl;
    if (url.endsWith('.svg')) {
      return SvgPicture.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholderBuilder: (_) => Container(color: AppColors.ink100),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (_, __) => Container(color: AppColors.ink100),
      errorWidget: (_, __, ___) => Container(color: AppColors.ink100, child: const Icon(Icons.image_not_supported, color: AppColors.ink400)),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
      );

  String _comma(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
