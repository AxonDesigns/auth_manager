import 'package:auth_manager/components/fractional_clip_r_rect.dart';
import 'package:flutter/material.dart';

class ProgressWithCode extends StatefulWidget {
  const ProgressWithCode({
    super.key,
    required this.code,
    required this.value,
    required this.minValue,
    required this.maxValue,
  });

  final String code;
  final double value;
  final double minValue;
  final double maxValue;

  @override
  State<ProgressWithCode> createState() => _ProgressWithCodeState();
}

class _ProgressWithCodeState extends State<ProgressWithCode> {
  String _lastCode = "000000";

  @override
  void initState() {
    super.initState();
    _lastCode = widget.code;
  }

  @override
  void didUpdateWidget(covariant ProgressWithCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.code != oldWidget.code) return;
    if (widget.code != _lastCode) {
      setState(() {
        _lastCode = widget.code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        _buildText(context, _lastCode, inverted: true),
        AnimatedFractionalClipRRect(
          duration: const Duration(milliseconds: 800),
          curve: widget.value >= widget.maxValue
              ? Curves.fastEaseInToSlowEaseOut
              : Curves.elasticOut,
          widthFactor: (widget.value - widget.minValue) /
              (widget.maxValue - widget.minValue),
          alignment: Alignment.centerLeft,
          borderRadius: const Radius.circular(4),
          child: _buildText(context, widget.code, inverted: false),
        ),
      ],
    );
  }

  Widget _buildText(BuildContext context, String code,
      {bool inverted = false}) {
    final lightColor = Theme.of(context).colorScheme.onSurface;
    final darkColor = Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: inverted ? darkColor : lightColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: lightColor,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.value.toStringAsFixed(0).padLeft(2, "0"),
            style: TextStyle(
              fontFamily: "JetbrainsMono",
              fontVariations: [
                FontVariation.weight(inverted ? 200 : 600),
              ],
              fontSize: 18,
              color: inverted ? lightColor : darkColor,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            color: inverted ? lightColor : darkColor,
            width: 1,
            height: 18,
          ),
          const SizedBox(width: 16),
          Text(
            "${code.substring(0, 3)} ${code.substring(3, 6)}",
            style: TextStyle(
              fontFamily: "JetbrainsMono",
              fontVariations: [
                FontVariation.weight(inverted ? 700 : 800),
              ],
              fontSize: 30,
              color: inverted ? lightColor : darkColor,
            ),
          ),
        ],
      ),
    );
  }
}
