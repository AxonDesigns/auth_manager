import 'package:flutter/material.dart';

class RefreshPhysics extends StatefulWidget {
  const RefreshPhysics({
    super.key,
    required this.builder,
  });

  final Widget Function(
    ScrollController controller,
    ScrollPhysics physics,
  ) builder;

  @override
  State<RefreshPhysics> createState() => _RefreshPhysicsState();
}

class _RefreshPhysicsState extends State<RefreshPhysics> {
  bool _atTop = true;
  late ScrollController scrollController;

  ScrollPhysics get _inheritedPhysics =>
      ScrollConfiguration.of(context).getScrollPhysics(context);

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldUpdate = scrollController.hasClients &&
        (_atTop && scrollController.offset > 0 ||
            !_atTop && scrollController.offset <= 0);

    if (shouldUpdate) {
      setState(() {
        _atTop = scrollController.offset <= 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      scrollController,
      _atTop
          ? const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            )
          : _inheritedPhysics,
    );
  }
}
