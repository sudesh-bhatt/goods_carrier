class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total = 0,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasMorePages => currentPage < lastPage;
}
