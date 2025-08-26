class Page<T> {
  final List<T> data;
  final int page;
  final int size;
  final int total;
  final bool hasNext;
  final bool hasPrevious;

  const Page({
    required this.data,
    required this.page,
    required this.size,
    required this.total,
    required this.hasNext,
    required this.hasPrevious,
  });

  Page<T> copyWith({
    List<T>? data,
    int? page,
    int? size,
    int? total,
    bool? hasNext,
    bool? hasPrevious,
  }) {
    return Page<T>(
      data: data ?? this.data,
      page: page ?? this.page,
      size: size ?? this.size,
      total: total ?? this.total,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
    );
  }

  @override
  String toString() {
    return 'Page(data: $data, page: $page, size: $size, total: $total, hasNext: $hasNext, hasPrevious: $hasPrevious)';
  }

  @override
  bool operator ==(covariant Page<T> other) {
    if (identical(this, other)) return true;

    bool listEquals(List a, List b) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    return listEquals(other.data, data) &&
        other.page == page &&
        other.size == size &&
        other.total == total &&
        other.hasNext == hasNext &&
        other.hasPrevious == hasPrevious;
  }

  @override
  int get hashCode {
    return data.hashCode ^ page.hashCode ^ size.hashCode ^ total.hashCode ^ hasNext.hashCode ^ hasPrevious.hashCode;
  }
}
