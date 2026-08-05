import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paywall_demo/src/core/bloc/bloc.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';

class AppPaginatedCustomScrollView<T, P> extends StatefulWidget {
  const AppPaginatedCustomScrollView({
    required this.bloc,
    required this.itemBuilder,
    super.key,
    this.headerWidgets = const [],
    this.footerWidgets = const [],
    this.injectedWidgets = const {},
    this.globalLoadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.scrollThreshold = 200.0,
    this.padding = const EdgeInsets.all(8),
  });
  final PaginatedDataBloc<T, P> bloc;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final List<Widget> headerWidgets;
  final List<Widget> footerWidgets;
  final Map<int, Widget> injectedWidgets;
  final Widget? globalLoadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final double scrollThreshold;
  final EdgeInsets padding;

  @override
  State<AppPaginatedCustomScrollView<T, P>> createState() =>
      _AppPaginatedCustomScrollViewState<T, P>();
}

class _AppPaginatedCustomScrollViewState<T, P>
    extends State<AppPaginatedCustomScrollView<T, P>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Авто-загрузка, если список пуст и не было ошибки
    if (widget.bloc.state.data.isEmpty &&
        widget.bloc.state is! ErrorPaginatedState) {
      widget.bloc.add(const PaginatedDataEvent.loadFirstPage());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      widget.bloc.add(const PaginatedDataEvent.loadNextPage());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll - widget.scrollThreshold);
  }

  Future<void> _onRefresh() async {
    // При рефреше передаем param: null,
    // чтобы Блок использовал прошлый (state.param)
    // или передаем текущий, если логика требует сброса.
    // В данном случае используем параметры из стейта блока внутри самого блока.
    widget.bloc.add(
      PaginatedDataEvent.loadFirstPage(
        param: widget.bloc.state.param,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaginatedDataBloc<T, P>, PaginatedDataState<T, P>>(
      bloc: widget.bloc,
      listener: (context, state) {},
      builder: (context, state) {
        // Глобальная загрузка (первый запуск)
        if (state.isProcessing && state.data.isEmpty) {
          return widget.globalLoadingWidget ?? const AppLoader();
        }

        // Ошибка (пустой экран)
        if (state is ErrorPaginatedState && state.data.isEmpty) {
          final message = (state as ErrorPaginatedState).message;
          return Center(
            child: widget.errorWidget ?? Text(message ?? context.l10n.error),
          );
        }

        // Пустой список
        if (state.data.isEmpty && !state.isProcessing) {
          return widget.emptyWidget ??
              Center(child: Text(context.l10n.emptyText));
        }

        final data = state.data;
        final showBottomLoader = !state.hasReachedMax;

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            clipBehavior: Clip.none,
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              ...widget.headerWidgets.map((w) => SliverToBoxAdapter(child: w)),
              SliverPadding(
                padding: widget.padding.copyWith(
                  bottom: context.mediaQuery.viewInsets.bottom + 120,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = data[index];
                      final itemWidget = widget.itemBuilder(
                        context,
                        item,
                        index,
                      );

                      if (widget.injectedWidgets.containsKey(index)) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            itemWidget,
                            widget.injectedWidgets[index]!,
                          ],
                        );
                      }
                      return itemWidget;
                    },
                    childCount: data.length,
                  ),
                ),
              ),
              if (showBottomLoader)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16).copyWith(
                      bottom: context.mediaQuery.viewInsets.bottom + 120,
                    ),
                    child: const AppLoader(),
                  ),
                ),
              ...widget.footerWidgets.map((w) => SliverToBoxAdapter(child: w)),
            ],
          ),
        );
      },
    );
  }
}
