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
}
