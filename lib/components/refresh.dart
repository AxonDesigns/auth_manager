import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The current state of the refresh control.
///
/// Passed into the [RefreshControlIndicatorBuilder] builder function so
/// users can show different UI in different modes.
enum RefreshIndicatorMode {
  /// Initial state, when not being overscrolled into, or after the overscroll
  /// is canceled or after done and the sliver retracted away.
  inactive,

  /// While being overscrolled but not far enough yet to trigger the refresh.
  drag,

  /// Dragged far enough that the onRefresh callback will run and the dragged
  /// displacement is not yet at the final refresh resting state.
  armed,

  /// While the onRefresh task is running.
  refresh,

  /// While the indicator is animating away after refreshing.
  done,
}

const double _kActivityIndicatorRadius = 14.0;
const double _kActivityIndicatorMargin = 16.0;

class _OverscrollSliver extends SingleChildRenderObjectWidget {
  const _OverscrollSliver({
    this.refreshIndicatorLayoutExtent = 0.0,
    this.hasLayoutExtent = false,
    super.child,
  }) : assert(refreshIndicatorLayoutExtent >= 0.0);

  // The amount of space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  final double refreshIndicatorLayoutExtent;

  // _RenderCupertinoSliverRefresh will paint the child in the available
  // space either way but this instructs the _RenderCupertinoSliverRefresh
  // on whether to also occupy any layoutExtent space or not.
  final bool hasLayoutExtent;

  @override
  _RenderOverscrollSliver createRenderObject(BuildContext context) {
    return _RenderOverscrollSliver(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
      hasLayoutExtent: hasLayoutExtent,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderOverscrollSliver renderObject) {
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..hasLayoutExtent = hasLayoutExtent;
  }
}

class _RenderOverscrollSliver extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderOverscrollSliver({
    required double refreshIndicatorExtent,
    required bool hasLayoutExtent,
    RenderBox? child,
  })  : assert(refreshIndicatorExtent >= 0.0),
        _refreshIndicatorExtent = refreshIndicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  // The amount of layout space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  double get refreshIndicatorLayoutExtent => _refreshIndicatorExtent;
  double _refreshIndicatorExtent;
  set refreshIndicatorLayoutExtent(double value) {
    assert(value >= 0.0);
    if (value == _refreshIndicatorExtent) {
      return;
    }
    _refreshIndicatorExtent = value;
    markNeedsLayout();
  }

  // The child box will be laid out and painted in the available space either
  // way but this determines whether to also occupy any
  // [SliverGeometry.layoutExtent] space or not.
  bool get hasLayoutExtent => _hasLayoutExtent;
  bool _hasLayoutExtent;
  set hasLayoutExtent(bool value) {
    if (value == _hasLayoutExtent) {
      return;
    }
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  // This keeps track of the previously applied scroll offsets to the scrollable
  // so that when [refreshIndicatorLayoutExtent] or [hasLayoutExtent] changes,
  // the appropriate delta can be applied to keep everything in the same place
  // visually.
  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    // Only pulling to refresh from the top is currently supported.
    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);

    // The new layout extent this sliver should now have.
    final double layoutExtent =
        (_hasLayoutExtent ? 1.0 : 0.0) * _refreshIndicatorExtent;
    // If the new layoutExtent instructive changed, the SliverGeometry's
    // layoutExtent will take that value (on the next performLayout run). Shift
    // the scroll offset first so it doesn't make the scroll position suddenly jump.
    if (layoutExtent != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = layoutExtent;
      // Return so we don't have to do temporary accounting and adjusting the
      // child's constraints accounting for this one transient frame using a
      // combination of existing layout extent, new layout extent change and
      // the overlap.
      return;
    }

    final bool active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    final double overscrolledExtent =
        constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;
    // Layout the child giving it the space of the currently dragged overscroll
    // which may or may not include a sliver layout extent space that it will
    // keep after the user lets go during the refresh process.
    child!.layout(
      constraints.asBoxConstraints(
        maxExtent: layoutExtent
            // Plus only the overscrolled portion immediately preceding this
            // sliver.
            +
            overscrolledExtent,
      ),
      parentUsesSize: true,
    );
    if (active) {
      geometry = SliverGeometry(
        scrollExtent: layoutExtent,
        paintOrigin: -overscrolledExtent - constraints.scrollOffset,
        paintExtent: max(
          // Check child size (which can come from overscroll) because
          // layoutExtent may be zero. Check layoutExtent also since even
          // with a layoutExtent, the indicator builder may decide to not
          // build anything.
          max(child!.size.height, layoutExtent) - constraints.scrollOffset,
          0.0,
        ),
        maxPaintExtent: max(
          max(child!.size.height, layoutExtent) - constraints.scrollOffset,
          0.0,
        ),
        layoutExtent: max(layoutExtent - constraints.scrollOffset, 0.0),
      );
    } else {
      // If we never started overscrolling, return no geometry.
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    if (constraints.overlap < 0.0 ||
        constraints.scrollOffset + child!.size.height > 0) {
      paintContext.paintChild(child!, offset);
    }
  }

  // Nothing special done here because this sliver always paints its child
  // exactly between paintOrigin and paintExtent.
  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}

class PullToRefreshSliver extends StatefulWidget {
  const PullToRefreshSliver({
    super.key,
    this.refreshTriggerPullDistance = _defaultRefreshTriggerPullDistance,
    this.refreshIndicatorExtent = _defaultRefreshIndicatorExtent,
    required this.builder,
    this.onRefresh,
  })  : assert(refreshTriggerPullDistance > 0.0),
        assert(refreshIndicatorExtent >= 0.0),
        assert(
          refreshTriggerPullDistance >= refreshIndicatorExtent,
          'The refresh indicator cannot take more space in its final state '
          'than the amount initially created by overscrolling.',
        );

  /// The amount of overscroll the scrollable must be dragged to trigger a reload.
  ///
  /// Must be larger than zero and larger than [refreshIndicatorExtent].
  /// Defaults to 100 pixels when not specified.
  ///
  /// When overscrolled past this distance, [onRefresh] will be called if not
  /// null and the [builder] will build in the [RefreshIndicatorMode.armed] state.
  final double refreshTriggerPullDistance;

  /// The amount of space the refresh indicator sliver will keep holding while
  /// [onRefresh]'s [Future] is still running.
  ///
  /// Must be a positive number, but can be zero, in which case the sliver will
  /// start retracting back to zero as soon as the refresh is started. Defaults
  /// to 60 pixels when not specified.
  ///
  /// Must be smaller than [refreshTriggerPullDistance], since the sliver
  /// shouldn't grow further after triggering the refresh.
  final double refreshIndicatorExtent;

  /// A builder that's called as this sliver's size changes, and as the state
  /// changes.
  ///
  /// Can be set to null, in which case nothing will be drawn in the overscrolled
  /// space.
  ///
  /// Will not be called when the available space is zero such as before any
  /// overscroll.
  final Widget Function(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) builder;

  /// Callback invoked when pulled by [refreshTriggerPullDistance].
  ///
  /// If provided, must return a [Future] which will keep the indicator in the
  /// [RefreshIndicatorMode.refresh] state until the [Future] completes.
  ///
  /// Can be null, in which case a single frame of [RefreshIndicatorMode.armed]
  /// state will be drawn before going immediately to the [RefreshIndicatorMode.done]
  /// where the sliver will start retracting.
  final Future<void> Function()? onRefresh;

  static const double _defaultRefreshTriggerPullDistance = 100.0;
  static const double _defaultRefreshIndicatorExtent = 60.0;

  @override
  State<PullToRefreshSliver> createState() => _PullToRefreshStateSliver();
}

class _PullToRefreshStateSliver extends State<PullToRefreshSliver> {
  // Reset the state from done to inactive when only this fraction of the
  // original `refreshTriggerPullDistance` is left.
  static const double _inactiveResetOverscrollFraction = 0.1;

  late RefreshIndicatorMode refreshState;
  // [Future] returned by the widget's `onRefresh`.
  Future<void>? refreshTask;
  // The amount of space available from the inner indicator box's perspective.
  //
  // The value is the sum of the sliver's layout extent and the overscroll
  // (which partially gets transferred into the layout extent when the refresh
  // triggers).
  //
  // The value of latestIndicatorBoxExtent doesn't change when the sliver scrolls
  // away without retracting; it is independent from the sliver's scrollOffset.
  double latestIndicatorBoxExtent = 0.0;
  bool hasSliverLayoutExtent = false;

  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    refreshState = RefreshIndicatorMode.inactive;
  }

  // A state machine transition calculator. Multiple states can be transitioned
  // through per single call.
  RefreshIndicatorMode transitionNextState() {
    RefreshIndicatorMode nextState;

    void goToDone() {
      nextState = RefreshIndicatorMode.done;
      // Either schedule the RenderSliver to re-layout on the next frame
      // when not currently in a frame or schedule it on the next frame.
      if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        setState(() => hasSliverLayoutExtent = false);
      } else {
        SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
          setState(() => hasSliverLayoutExtent = false);
        }, debugLabel: 'Refresh.goToDone');
      }
    }

    switch (refreshState) {
      case RefreshIndicatorMode.inactive:
        if (latestIndicatorBoxExtent <= 0) {
          return RefreshIndicatorMode.inactive;
        } else {
          nextState = RefreshIndicatorMode.drag;
        }
        continue drag;
      drag:
      case RefreshIndicatorMode.drag:
        if (latestIndicatorBoxExtent == 0) {
          return RefreshIndicatorMode.inactive;
        } else if (latestIndicatorBoxExtent <
            widget.refreshTriggerPullDistance) {
          return RefreshIndicatorMode.drag;
        } else {
          if (widget.onRefresh != null) {
            HapticFeedback.mediumImpact();
            // Call onRefresh after this frame finished since the function is
            // user supplied and we're always here in the middle of the sliver's
            // performLayout.
            SchedulerBinding.instance.addPostFrameCallback(
                (Duration timestamp) {
              refreshTask = widget.onRefresh!()
                ..whenComplete(() {
                  if (mounted) {
                    setState(() => refreshTask = null);
                    // Trigger one more transition because by this time, BoxConstraint's
                    // maxHeight might already be resting at 0 in which case no
                    // calls to [transitionNextState] will occur anymore and the
                    // state may be stuck in a non-inactive state.
                    refreshState = transitionNextState();
                  }
                });
              setState(() => hasSliverLayoutExtent = true);
            }, debugLabel: 'Refresh.transition');
          }
          return RefreshIndicatorMode.armed;
        }
      case RefreshIndicatorMode.armed:
        if (refreshState == RefreshIndicatorMode.armed &&
            refreshTask == null &&
            !_isDragging) {
          goToDone();
          continue done;
        }

        if (latestIndicatorBoxExtent > widget.refreshIndicatorExtent) {
          return RefreshIndicatorMode.armed;
        } else {
          nextState = RefreshIndicatorMode.refresh;
        }
        continue refresh;
      refresh:
      case RefreshIndicatorMode.refresh:
        if (refreshTask != null) {
          return RefreshIndicatorMode.refresh;
        } else {
          goToDone();
        }
        continue done;
      done:
      case RefreshIndicatorMode.done:
        // Let the transition back to inactive trigger before strictly going
        // to 0.0 since the last bit of the animation can take some time and
        // can feel sluggish if not going all the way back to 0.0 prevented
        // a subsequent pull-to-refresh from starting.
        if (latestIndicatorBoxExtent >
            widget.refreshTriggerPullDistance *
                _inactiveResetOverscrollFraction) {
          return RefreshIndicatorMode.done;
        } else {
          nextState = RefreshIndicatorMode.inactive;
        }
    }

    return nextState;
  }

  @override
  Widget build(BuildContext context) {
    return _OverscrollSliver(
      refreshIndicatorLayoutExtent: widget.refreshIndicatorExtent,
      hasLayoutExtent: hasSliverLayoutExtent,
      // A LayoutBuilder lets the sliver's layout changes be fed back out to
      // its owner to trigger state changes.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          latestIndicatorBoxExtent = constraints.maxHeight;
          refreshState = transitionNextState();
          _isDragging = Scrollable.of(context)
              .position
              .toString()
              .contains("DragScrollActivity");
          if (latestIndicatorBoxExtent > 0) {
            return widget.builder(
              context,
              refreshState,
              latestIndicatorBoxExtent,
              widget.refreshTriggerPullDistance,
              widget.refreshIndicatorExtent,
            );
          }
          return const LimitedBox(
              maxWidth: 0.0, maxHeight: 0.0, child: SizedBox.expand());
        },
      ),
    );
  }
}
