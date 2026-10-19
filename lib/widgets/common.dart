import 'package:flutter/material.dart';
import '../models.dart';

/// 应用图标：有 icon_url 则加载网络图，否则用首字母占位
class AppIconImage extends StatelessWidget {
  final AppItem? app;
  final String? url;
  final String fallbackName;
  final double size;
  const AppIconImage({
    super.key,
    this.app,
    this.url,
    this.fallbackName = '?',
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final src = url ?? app?.iconUrl ?? '';
    final name = app?.name ?? fallbackName;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.secondary],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: src.isNotEmpty
          ? Image.network(
              src,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(name, scheme),
            )
          : _fallback(name, scheme),
    );
  }

  Widget _fallback(String name, ColorScheme scheme) {
    final ch = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Center(
      child: Text(
        ch,
        style: TextStyle(
          color: scheme.onPrimary,
          fontSize: size * 0.44,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 星级评分展示
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final int? ratingCount;
  const StarRating({super.key, required this.rating, this.size = 16, this.ratingCount});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating && rating - i >= 0.3 && rating - i < 0.7;
        final showHalf = half;
        return Icon(
          filled
              ? Icons.star_rounded
              : (showHalf ? Icons.star_half_rounded : Icons.star_outline_rounded),
          size: size,
          color: color,
        );
      }),
    );
  }
}

/// 金币标签
class CoinChip extends StatelessWidget {
  final int coins;
  const CoinChip({super.key, required this.coins});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.monetization_on_rounded, size: 13, color: scheme.onTertiaryContainer),
        const SizedBox(width: 3),
        Text('$coins',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scheme.onTertiaryContainer)),
      ]),
    );
  }
}

/// 显示提示 SnackBar
void showToast(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.inverseSurface,
    ));
}
