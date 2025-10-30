class PaginatedList<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  final bool isLoading;
  
  const PaginatedList({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
    this.isLoading = false,
  });
  
  factory PaginatedList.empty() {
    return const PaginatedList(
      items: [],
      currentPage: 0,
      totalPages: 0,
      totalItems: 0,
      hasMore: false,
    );
  }
  
  factory PaginatedList.fromList(
    List<T> allItems, {
    required int page,
    required int pageSize,
  }) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, allItems.length);
    
    final items = startIndex < allItems.length 
        ? allItems.sublist(startIndex, endIndex)
        : <T>[];
    
    final totalPages = (allItems.length / pageSize).ceil();
    final hasMore = page < totalPages - 1;
    
    return PaginatedList(
      items: items,
      currentPage: page,
      totalPages: totalPages,
      totalItems: allItems.length,
      hasMore: hasMore,
    );
  }
  
  PaginatedList<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    bool? isLoading,
  }) {
    return PaginatedList(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  PaginatedList<T> appendPage(List<T> newItems) {
    return copyWith(
      items: [...items, ...newItems],
      currentPage: currentPage + 1,
      hasMore: newItems.isNotEmpty,
      isLoading: false,
    );
  }
  
  PaginatedList<T> setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }
}