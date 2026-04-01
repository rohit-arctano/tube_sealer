import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/services/responsive_service.dart';

/// Header bar with timestamp, title, and username styled like the references.
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                timestamp,
                style: TextStyle(
                  color: r.textLight(),
                  fontSize: r.scaled(11),
                  fontFamily: 'monospace',
                ),
              ),
            ),
            Text(
              username,
              style: TextStyle(
                color: r.textLight(),
                fontSize: r.scaled(11),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        if (title.isNotEmpty) ...[
          SizedBox(height: r.scaled(6)),
          Text(
            title,
            style: TextStyle(
              color: r.textLight(),
              fontSize: r.scaled(26),
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: r.scaled(14)),
        ] else
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
      padding: EdgeInsets.symmetric(vertical: r.scaled(8)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: r.textLight(),
            fontSize: r.scaled(26),
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

/// Progress bar with label and optional time.
class ProgressPhase extends StatelessWidget {
  final String label;
  final double progress;
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
            fontSize: r.scaled(18),
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: r.scaled(8)),
        Container(
          width: double.infinity,
          height: r.scaled(34),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            border: Border.all(color: r.borderDark(), width: 2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(color: r.accentColor()),
            ),
          ),
        ),
        if (timeRemaining != null) ...[
          SizedBox(height: r.scaled(6)),
          Text(
            timeRemaining!,
            style: TextStyle(
              color: r.textLight(),
              fontSize: r.scaled(12),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ],
    );
  }
}

/// Bottom-right OK/Cancel icon buttons.
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
        if (onOk != null) _ActionIconButton(icon: Icons.check, onTap: onOk!, r: r),
        if (onOk != null && onCancel != null) SizedBox(width: r.scaled(8)),
        if (onCancel != null) _ActionIconButton(icon: Icons.close, onTap: onCancel!, r: r),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Responsive r;

  const _ActionIconButton({
    required this.icon,
    required this.onTap,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: r.touchTargetDp(),
      height: r.touchTargetDp(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: r.accentColor(),
              border: Border.all(color: r.textLight(), width: 2),
            ),
            child: Center(
              child: Icon(
                icon,
                size: r.scaled(28),
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon grid for menu-like screens.
class IconGrid extends StatelessWidget {
  final List<IconGridItem> items;
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
        mainAxisSpacing: r.scaled(10),
        crossAxisSpacing: r.scaled(10),
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        return GestureDetector(
          onTap: () => onItemTap?.call(i),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: r.borderDark(), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: r.scaled(44),
                  height: r.scaled(44),
                  color: r.accentColor(),
                  child: Icon(
                    item.icon,
                    size: r.scaled(26),
                    color: AppColors.textOnPrimary,
                  ),
                ),
                SizedBox(height: r.scaled(8)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.scaled(4)),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: r.textLight(),
                      fontSize: r.scaled(11),
                      fontFamily: 'monospace',
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

/// Reference-style selector with a white arrow box on the right.
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
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant SpinBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final maxIndex = widget.options.isEmpty ? 0 : widget.options.length - 1;
    final nextIndex = widget.initialIndex.clamp(0, maxIndex);
    if (oldWidget.initialIndex != widget.initialIndex && nextIndex != _selectedIndex) {
      _selectedIndex = nextIndex;
      _expanded = false;
    }
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
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: widget.r.scaled(8)),
        Container(
          height: widget.r.scaled(48),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: widget.r.borderDark(), width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: widget.r.scaled(12)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.options[_selectedIndex],
                        style: TextStyle(
                          color: widget.r.textLight(),
                          fontSize: widget.r.scaled(16),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: widget.r.touchTargetDp(),
                height: widget.r.scaled(48),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _selectedIndex = (_selectedIndex + 1) % widget.options.length;
                    });
                    widget.onChanged?.call(_selectedIndex);
                  },
                  child: Container(
                    color: widget.r.accentColor(),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textOnPrimary,
                      size: widget.r.scaled(28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: _expanded ? widget.r.scaled(240) : 0),
            child: _expanded
                ? Container(
                    margin: EdgeInsets.only(top: widget.r.scaled(6)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: widget.r.borderDark(), width: 2),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: widget.options.length,
                      itemBuilder: (ctx, i) {
                        final selected = i == _selectedIndex;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = i;
                              _expanded = false;
                            });
                            widget.onChanged?.call(i);
                          },
                          child: Container(
                            height: widget.r.scaled(48),
                            padding: EdgeInsets.symmetric(horizontal: widget.r.scaled(12)),
                            decoration: BoxDecoration(
                              color: selected ? widget.r.accentColor() : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(color: widget.r.borderDark(), width: 1),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.options[i],
                              style: TextStyle(
                                color: selected
                                    ? AppColors.textOnPrimary
                                    : widget.r.textLight(),
                                fontSize: widget.r.scaled(16),
                                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
