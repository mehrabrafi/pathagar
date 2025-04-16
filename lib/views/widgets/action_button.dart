import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool isDisabled;
  final String? tooltip;  // Add this line

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
    this.isDisabled = false,
    this.tooltip,  // Add this line
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final buttonColor = isDisabled
        ? colorScheme.onSurface.withOpacity(0.2)
        : isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withOpacity(0.8);

    final backgroundColor = isDisabled
        ? colorScheme.surface.withOpacity(0.3)
        : isActive
        ? colorScheme.primary.withOpacity(0.2)
        : colorScheme.surface.withOpacity(0.5);

    // Wrap the Column with Tooltip if tooltip is provided
    Widget buttonContent = Column(
      children: [
        IconButton(
          icon: CircleAvatar(
            backgroundColor: backgroundColor,
            child: Icon(
              icon,
              color: buttonColor,
            ),
          ),
          onPressed: isDisabled ? null : onPressed,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: buttonColor,
          ),
        ),
      ],
    );

    return tooltip != null
        ? Tooltip(
      message: tooltip!,
      child: buttonContent,
    )
        : buttonContent;
  }
}