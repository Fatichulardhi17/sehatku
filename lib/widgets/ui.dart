import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'screen_frame.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.radius = 22,
    this.padding = const EdgeInsets.all(20),
    this.height,
    this.width,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsets padding;
  final double? height;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width ?? double.infinity,
      height: height,
      padding: padding,
      child: child,
    );

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 52,
    this.width,
    this.loading = false,
    this.showSpinner = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double? width;
  final bool loading;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppText.button15,
        ),
        child: loading && showSpinner
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.foreground = AppColors.brown,
    this.background = AppColors.surface,
    this.height = 44,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color foreground;
  final Color background;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: AppText.button12.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.background = AppColors.mint,
    this.foreground = AppColors.primary,
    this.width = 70,
    this.height = 24,
    this.fontSize = 11,
  });

  final String label;
  final Color background;
  final Color foreground;
  final double width;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.body11.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.height = 60,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: height,
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.body14.copyWith(color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppText.body13,
            ),
          ),
        ],
      ),
    );
  }
}

class PlanTile extends StatelessWidget {
  const PlanTile({
    super.key,
    required this.title,
    required this.detail,
    this.isDone = false,
    this.onTap,
  });

  final String title;
  final String detail;
  final bool isDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: 72,
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isDone ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone ? AppColors.primary : AppColors.muted,
                width: 1.5,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body15.copyWith(
                    color: isDone ? AppColors.muted : AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body13,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    super.key,
    required this.item,
    this.highlighted = false,
    this.onToggleStatus,
  });

  final WorkoutItem item;
  final bool highlighted;
  final VoidCallback? onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final pillColor = highlighted ? AppColors.surface : AppColors.mint;
    final isDone = item.isDone;

    return AppCard(
      radius: 22,
      color: isDone
          ? AppColors.lineSoft
          : (highlighted ? AppColors.mint : AppColors.surface),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.time,
                  style: AppText.body13.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: AppText.title18.copyWith(
                    color: isDone ? AppColors.muted : AppColors.primaryDark,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.type, style: AppText.body13),
                const SizedBox(height: 10),
                Container(
                  width: 92,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    '${item.durationMinutes} menit',
                    style: AppText.button12.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          if (onToggleStatus != null)
            IconButton(
              icon: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? AppColors.primary : AppColors.muted,
                size: 24,
              ),
              onPressed: onToggleStatus,
              tooltip: isDone ? 'Tandai belum selesai' : 'Tandai selesai',
            ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (user.status) {
      'Baru' => (AppColors.primary, Colors.white),
      'Tidak aktif' => (AppColors.line, AppColors.muted),
      'Admin' => (AppColors.primaryDark, Colors.white),
      _ => (AppColors.mint, AppColors.primary),
    };

    return AppCard(
      height: 76,
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          AvatarBadge(initial: user.initial, size: 40, fontSize: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body15.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body12,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(
            label: user.status,
            background: background,
            foreground: foreground,
          ),
        ],
      ),
    );
  }
}

class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.errorText,
    this.enabled = true,
    this.filledColor,
    this.hintColor,
    this.onChanged,
  });

  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? errorText;
  final bool enabled;
  final Color? filledColor;
  final Color? hintColor;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppText.body13.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            enabled: enabled,
            onChanged: onChanged,
            cursorColor: AppColors.primary,
            style: AppText.body14.copyWith(color: AppColors.primaryDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.body14.copyWith(color: hintColor),
              fillColor: filledColor ??
                  (enabled ? AppColors.surface : AppColors.skeleton),
              errorText: errorText,
              errorStyle: AppText.body12.copyWith(color: AppColors.danger),
              errorMaxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}

class LinkRow extends StatelessWidget {
  const LinkRow({
    super.key,
    required this.leading,
    required this.action,
    required this.onTap,
    this.height = 44,
  });

  final String leading;
  final String action;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text.rich(
              TextSpan(
                style: AppText.body13,
                children: [
                  TextSpan(text: leading),
                  TextSpan(
                    text: action,
                    style: AppText.body13.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, this.height = 8});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1).toDouble(),
        minHeight: height,
        backgroundColor: AppColors.line,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.color = AppColors.skeleton,
    this.radius,
  });

  final double width;
  final double height;
  final Color color;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? height / 2),
      ),
    );
  }
}

class LoadingRegion extends StatelessWidget {
  const LoadingRegion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat data',
      container: true,
      child: ExcludeSemantics(child: child),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.body,
    this.buttonLabel,
    this.onPressed,
    this.height = 150,
    this.radius = 20,
    this.label,
    this.labelColor = AppColors.primary,
  });

  final String title;
  final String body;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final double height;
  final double radius;
  final String? label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: height,
      radius: radius,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: AppText.label11.copyWith(color: labelColor),
            ),
            const SizedBox(height: 8),
          ],
          Text(title, style: AppText.title16),
          const SizedBox(height: 6),
          Text(body, style: AppText.body13),
          const Spacer(),
          if (buttonLabel != null)
            GhostButton(
              label: buttonLabel!,
              onPressed: onPressed,
              foreground: Colors.white,
              background: AppColors.primary,
              width: 130,
              height: 44,
            ),
        ],
      ),
    );
  }
}

class LoadingStateCard extends StatelessWidget {
  const LoadingStateCard({
    super.key,
    this.height = 150,
    this.radius = 20,
    this.label,
    this.message = 'Memuat rencana',
    this.labelColor = AppColors.muted,
  });

  final double height;
  final double radius;
  final String? label;
  final String message;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: height,
      radius: radius,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!, style: AppText.label11.copyWith(color: labelColor)),
            const SizedBox(height: 8),
          ],
          const SkeletonBox(
            width: 160,
            height: 14,
            color: AppColors.skeletonStrong,
            radius: 7,
          ),
          const SizedBox(height: 12),
          const SkeletonBox(width: 240, height: 10, radius: 5),
          const SizedBox(height: 8),
          const SkeletonBox(width: 200, height: 10, radius: 5),
          const Spacer(),
          Text(message, style: AppText.body12),
        ],
      ),
    );
  }
}

class ErrorStateCard extends StatelessWidget {
  const ErrorStateCard({
    super.key,
    required this.title,
    required this.body,
    this.buttonLabel = 'Coba lagi',
    this.onPressed,
    this.height = 150,
    this.radius = 20,
    this.label,
  });

  final String title;
  final String body;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final double? height;
  final double radius;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: height,
      radius: radius,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: height == null ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: AppText.label11.copyWith(
                color: AppColors.danger,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(title, style: AppText.title16),
          const SizedBox(height: 6),
          Text(body, style: AppText.body13),
          if (buttonLabel != null) ...[
            if (height == null) const SizedBox(height: 16) else const Spacer(),
            GhostButton(
              label: buttonLabel!,
              onPressed: onPressed,
              foreground: AppColors.brown,
              background: AppColors.surface,
              width: 110,
              height: 44,
            ),
          ],
        ],
      ),
    );
  }
}
