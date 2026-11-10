import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

const mainNavItems = ['Beranda', 'Aktivitas', 'Jadwal', 'Profil'];
const adminNavItems = ['Ringkasan', 'Pengguna', 'Keluar'];

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.child,
    this.bottomNav,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 16, 24, 24),
    this.scrollable = true,
  });

  final Widget child;
  final Widget? bottomNav;
  final EdgeInsets contentPadding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final body = scrollable
        ? SingleChildScrollView(padding: contentPadding, child: child)
        : Padding(padding: contentPadding, child: child);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: bottomNav == null,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: body),
                if (bottomNav != null) bottomNav!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SehatkuBottomNav extends StatelessWidget {
  const SehatkuBottomNav({
    super.key,
    required this.activeIndex,
    required this.items,
    required this.onTap,
  });

  final int activeIndex;
  final List<String> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.lineSoft)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 80,
            child: Row(
              children: [
                for (var index = 0; index < items.length; index++)
                  Expanded(
                    child: InkWell(
                      onTap: () => onTap(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          Container(
                            width: 20,
                            height: 3,
                            decoration: BoxDecoration(
                              color: index == activeIndex
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            items[index],
                            textAlign: TextAlign.center,
                            style: index == activeIndex
                                ? AppText.nav11.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  )
                                : AppText.nav11,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PageHeading extends StatelessWidget {
  const PageHeading({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.title26),
        const SizedBox(height: 5),
        Text(subtitle, style: AppText.body14),
      ],
    );
  }
}

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({
    super.key,
    required this.initial,
    this.size = 34,
    this.fontSize = 15,
    this.background = AppColors.mint,
    this.foreground = AppColors.primary,
  });

  final String initial;
  final double size;
  final double fontSize;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Text(
          initial.toUpperCase(),
          style: AppText.value20.copyWith(
            fontSize: fontSize,
            color: foreground,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(title, style: AppText.title18)),
        if (actionLabel != null && onAction != null)
          Material(
            type: MaterialType.transparency,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      actionLabel!,
                      style: AppText.body12.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
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
