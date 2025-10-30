import 'package:flutter/material.dart';

/// High-performance ListView with built-in optimizations
class OptimizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final VoidCallback? onRefresh;
  final bool enablePullToRefresh;
  
  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.onRefresh,
    this.enablePullToRefresh = false,
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  Widget _buildListView() {
    if (widget.separatorBuilder != null) {
      return ListView.separated(
        itemCount: widget.items.length,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        padding: widget.padding,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        itemBuilder: (context, index) => widget.itemBuilder(
          context,
          widget.items[index],
          index,
        ),
        separatorBuilder: widget.separatorBuilder!,
      );
    }
    
    return ListView.builder(
      itemCount: widget.items.length,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      itemBuilder: (context, index) => widget.itemBuilder(
        context,
        widget.items[index],
        index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    Widget listView = _buildListView();
    
    if (widget.enablePullToRefresh && widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: () async {
          widget.onRefresh?.call();
        },
        child: listView,
      );
    }
    
    return listView;
  }
}

/// Optimized grid view for better performance
class OptimizedGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final Widget? emptyWidget;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  
  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.gridDelegate,
    this.emptyWidget,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  State<OptimizedGridView<T>> createState() => _OptimizedGridViewState<T>();
}

class _OptimizedGridViewState<T> extends State<OptimizedGridView<T>>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    return GridView.builder(
      itemCount: widget.items.length,
      gridDelegate: widget.gridDelegate,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      addSemanticIndexes: true,
      itemBuilder: (context, index) => widget.itemBuilder(
        context,
        widget.items[index],
        index,
      ),
    );
  }
}