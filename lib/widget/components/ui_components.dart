// lib/widget/components/ui_components.dart
import 'package:flutter/material.dart';
import '../../core/services/responsive_service.dart';

/// Header bar with timestamp, title, and username.
class HeaderBar extends StatelessWidget {
  final String timestamp;
  final String title;
  final String username;
  final Responsive r;

  const HeaderBar({
    required this.timestamp,
    required this.title,
    required this.username,
    required this.r,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timestamp,
              style: TextStyle(
                color: r.textLight(),
                fontSize: r.scaled(12),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: r.textLight(),
                    fontSize: r.scaled(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Text(
              username,
              style: TextStyle(
                color: r.textLight(),
                fontSize: r.scaled(12),
              ),
            ),
          ],
        ),
        SizedBox(height: r.scaled(8)),
      ],
    );
  }
}

/// Large screen title.
class ScreenTitle extends StatelessWidget {
  final String text;
  final Responsive r;

  const ScreenTitle({required this.text, required this.r, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.scaled(12)),
      child: Text(
        text,
        style: TextStyle(
          color: r.textLight(),
          fontSize: r.scaled(24),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Progress bar with label and percentage.
class ProgressPhase extends StatelessWidget {
  final String label;
  final double progress; // 0.0 to 1.0
  final String? timeRemaining;
  final Responsive r;

  const ProgressPhase({
    required this.label,
    required this.progress,
    this.timeRemaining,
    required this.r,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: r.textLight(),
            fontSize: r.scaled(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: r.scaled(8)),
        Container(
          width: double.infinity,
          height: r.scaled(24),
          decoration: BoxDecoration(
            border: Border.all(color: r.borderDark(), width: 2),
            borderRadius: BorderRadius.circular(r.scaled(6)),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
                  color: r.accentColor(),
              child: Center(
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: r.bgDark(),
                    fontSize: r.scaled(10),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (timeRemaining != null) ...[
          SizedBox(height: r.scaled(6)),
          Text(
            'Time: $timeRemaining',
            style: TextStyle(
              color: r.textLight(),
              fontSize: r.scaled(12),
            ),
          ),
        ],
      ],
    );
  }
}

/// Action buttons (OK and Cancel) at the bottom-right.
class ActionBar extends StatelessWidget {
  final VoidCallback? onOk;
  final VoidCallback? onCancel;
  final Responsive r;

  const ActionBar({
    this.onOk,
    this.onCancel,
    required this.r,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // OK button — filled accent for emphasis
        SizedBox(
          width: r.touchTargetDp(),
          height: r.touchTargetDp(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOk,
              borderRadius: BorderRadius.circular(r.scaled(6)),
              child: Container(
                decoration: BoxDecoration(
                  color: r.accentColor(),
                  borderRadius: BorderRadius.circular(r.scaled(6)),
                  border: Border.all(color: r.textLight(), width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: r.scaled(28),
                    // color: r.bgLight(),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: r.scaled(12)),
        // Cancel button — outline
        SizedBox(
          width: r.touchTargetDp(),
          height: r.touchTargetDp(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCancel,
              borderRadius: BorderRadius.circular(r.scaled(6)),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: r.textLight(), width: 2),
                  borderRadius: BorderRadius.circular(r.scaled(6)),
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    size: r.scaled(28),
                    color: r.textLight(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Icon grid (for menu).
class IconGrid extends StatelessWidget {
  final List<IconGridItem> items; // up to 12 items (3x4)
  final ValueChanged<int>? onItemTap;
  final Responsive r;

  const IconGrid({
    required this.items,
    this.onItemTap,
    required this.r,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: r.scaled(8),
        crossAxisSpacing: r.scaled(8),
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        return GestureDetector(
          onTap: () => onItemTap?.call(i),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: r.borderDark(), width: 2),
              borderRadius: BorderRadius.circular(r.scaled(4)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  item.icon,
                  size: r.scaled(44),
                  color: r.textLight(),
                ),
                Positioned(
                  bottom: r.scaled(4),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: r.accentColor(),
                      fontSize: r.scaled(11),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class IconGridItem {
  final IconData icon;
  final String label;

  IconGridItem({required this.icon, required this.label});
}

/// Simple spin box (dropdown-like selector).
class SpinBox extends StatefulWidget {
  final List<String> options;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final String label;
  final Responsive r;

  const SpinBox({
    required this.options,
    this.initialIndex = 0,
    this.onChanged,
    required this.label,
    required this.r,
    Key? key,
  }) : super(key: key);

  @override
  State<SpinBox> createState() => _SpinBoxState();
}

class _SpinBoxState extends State<SpinBox> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: widget.r.textLight(),
            fontSize: widget.r.scaled(14),
          ),
        ),
        SizedBox(height: widget.r.scaled(8)),
        GestureDetector(
          onTap: () => _showSelectionDialog(),
          child: Container(
            height: widget.r.scaled(48),
            decoration: BoxDecoration(
              border: Border.all(color: widget.r.borderDark(), width: 2),
              borderRadius: BorderRadius.circular(widget.r.scaled(4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.r.scaled(12)),
                  child: Text(
                    widget.options[_selectedIndex],
                    style: TextStyle(
                      color: widget.r.textLight(),
                      fontSize: widget.r.scaled(16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: widget.r.scaled(12)),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: widget.r.textLight(),
                    size: widget.r.scaled(24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: widget.r.bgDark(),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: widget.options.length,
              itemBuilder: (ctx, i) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = i);
                    widget.onChanged?.call(i);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    height: widget.r.scaled(56),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: widget.r.borderDark(), width: 1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.options[i],
                        style: TextStyle(
                          color: _selectedIndex == i
                              ? widget.r.accentColor()
                              : widget.r.textLight(),
                          fontSize: widget.r.scaled(18),
                          fontWeight: _selectedIndex == i
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
