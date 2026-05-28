class Listing {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String categoryName;
  final String categorySlug;
  final String makeName;
  final String? modelName;
  final int? year;
  final int price;
  final String? priceType;
  final String formattedPrice;
  final int? operatingHours;
  final int? mileageKm;
  final String? region;
  final String thumbnailUrl;
  final bool isVerified;
  final bool isFeatured;
  final bool isUrgent;
  final String status;
  final int viewCount;
  final int inquiryCount;
  final List<ListingMedia> media;
  final List<ListingSpec> specs;

  Listing({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    required this.categoryName,
    required this.categorySlug,
    required this.makeName,
    this.modelName,
    this.year,
    required this.price,
    this.priceType,
    required this.formattedPrice,
    this.operatingHours,
    this.mileageKm,
    this.region,
    required this.thumbnailUrl,
    this.isVerified = false,
    this.isFeatured = false,
    this.isUrgent = false,
    this.status = 'active',
    this.viewCount = 0,
    this.inquiryCount = 0,
    this.media = const [],
    this.specs = const [],
  });

  factory Listing.fromJson(Map<String, dynamic> j) => Listing(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        slug: j['slug'] ?? '',
        description: j['description'],
        categoryName: j['category']?['name'] ?? '',
        categorySlug: j['category']?['slug'] ?? '',
        makeName: j['make']?['name'] ?? '',
        modelName: j['model_name'],
        year: j['year'],
        price: (j['price'] ?? 0) is int ? j['price'] : (j['price'] as num).toInt(),
        priceType: j['price_type'],
        formattedPrice: j['formatted_price'] ?? '',
        operatingHours: j['operating_hours'],
        mileageKm: j['mileage_km'],
        region: j['region'],
        thumbnailUrl: j['thumbnail_url'] ?? '',
        isVerified: j['is_verified'] ?? false,
        isFeatured: j['is_featured'] ?? false,
        isUrgent: j['is_urgent'] ?? false,
        status: j['status'] ?? 'active',
        viewCount: (j['view_count'] ?? 0) is int ? j['view_count'] : (j['view_count'] as num).toInt(),
        inquiryCount: (j['inquiry_count'] ?? 0) is int ? j['inquiry_count'] : (j['inquiry_count'] as num).toInt(),
        media: ((j['media'] as List?) ?? []).map((m) => ListingMedia.fromJson(m)).toList(),
        specs: ((j['specs'] as List?) ?? []).map((s) => ListingSpec.fromJson(s)).toList(),
      );
}

class ListingMedia {
  final String id;
  final String url;
  final String role;
  final String roleLabel;
  final bool isPrimary;

  ListingMedia({required this.id, required this.url, required this.role, required this.roleLabel, this.isPrimary = false});

  factory ListingMedia.fromJson(Map<String, dynamic> j) => ListingMedia(
        id: j['id'] ?? '',
        url: j['url'] ?? '',
        role: j['role'] ?? 'other',
        roleLabel: j['role_label'] ?? '기타',
        isPrimary: j['is_primary'] ?? false,
      );
}

class ListingSpec {
  final String key;
  final String label;
  final String value;
  final String? unit;

  ListingSpec({required this.key, required this.label, required this.value, this.unit});

  factory ListingSpec.fromJson(Map<String, dynamic> j) => ListingSpec(
        key: j['key'] ?? '',
        label: j['label'] ?? '',
        value: j['value']?.toString() ?? '',
        unit: j['unit'],
      );
}

class CategoryModel {
  final String id;
  final String key;
  final String name;
  final String slug;
  final List<CategoryModel> children;

  CategoryModel({required this.id, required this.key, required this.name, required this.slug, this.children = const []});

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
        id: j['id'] ?? '',
        key: j['key'] ?? '',
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        children: ((j['children'] as List?) ?? []).map((c) => CategoryModel.fromJson(c)).toList(),
      );
}
