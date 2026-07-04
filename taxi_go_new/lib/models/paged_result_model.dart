/// Generic wrapper matching the backend's `PagedResult<T>` DTO
/// (`TotalCount`, `Page`, `PageSize`, `Data`).
class PagedResultModel<T> {
  final int totalCount;
  final int page;
  final int pageSize;
  final List<T> data;

  const PagedResultModel({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.data,
  });

  factory PagedResultModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final rawData = json['data'];

    return PagedResultModel<T>(
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 0,
      data: rawData is List
          ? rawData.map((e) => itemParser(e as Map<String, dynamic>)).toList()
          : <T>[],
    );
  }
}
