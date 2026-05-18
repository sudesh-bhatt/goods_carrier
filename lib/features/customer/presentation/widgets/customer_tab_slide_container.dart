import 'package:flutter/material.dart';

/// Horizontal slide transition between customer bottom-nav tabs.
///
/// Used as [StatefulShellRoute.navigatorContainerBuilder] so branch state is
/// preserved while switching tabs with a left/right page shift.
class CustomerTabSlideContainer extends StatefulWidget {
  const CustomerTabSlideContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<CustomerTabSlideContainer> createState() =>
      _CustomerTabSlideContainerState();
}

class _CustomerTabSlideContainerState extends State<CustomerTabSlideContainer>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 300);

  late final AnimationController _controller;
  late int _fromIndex;
  late int _toIndex;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex;
    _toIndex = widget.currentIndex;
    _controller = AnimationController(vsync: this, duration: _duration, value: 1);
    _controller.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _fromIndex = _toIndex);
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomerTabSlideContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _fromIndex = oldWidget.currentIndex;
      _toIndex = widget.currentIndex;
      _controller.forward(from: 0);
    }
  }

  bool get _isAnimating =>
      _fromIndex != _toIndex && _controller.status != AnimationStatus.completed;

  Widget _wrapBranch(int index, Widget child) {
    return IgnorePointer(
      ignoring: index != _toIndex,
      child: TickerMode(
        enabled: index == _toIndex,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimating) {
      return ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < widget.children.length; i++)
              if (i != _toIndex)
                Offstage(
                  child: _wrapBranch(i, widget.children[i]),
                ),
            _wrapBranch(_toIndex, widget.children[_toIndex]),
          ],
        ),
      );
    }

    final forward = _toIndex > _fromIndex;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < widget.children.length; i++)
            if (i != _fromIndex && i != _toIndex)
              Offstage(
                child: _wrapBranch(i, widget.children[i]),
              ),
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(forward ? -1 : 1, 0),
            ).animate(animation),
            child: _wrapBranch(_fromIndex, widget.children[_fromIndex]),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset(forward ? 1 : -1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: _wrapBranch(_toIndex, widget.children[_toIndex]),
          ),
        ],
      ),
    );
  }
}
