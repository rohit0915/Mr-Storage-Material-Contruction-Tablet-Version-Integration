import 'package:flutter/material.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Keep curves in the corners only (Figma: card does not touch them)
    final edgeW = size.width * 0.38;
    final edgeH = size.height * 0.42;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppAssets.loginBg,
          fit: BoxFit.cover,
          width: size.width,
          height: size.height,
        ),
        Positioned(
          top: 0,
          left: 0,
          child: _CurvedEdge(
            asset: AppAssets.ellipseTopLeft,
            width: edgeW,
            height: edgeH,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: _CurvedEdge(
            asset: AppAssets.ellipseBottomRight,
            width: edgeW,
            height: edgeH,
          ),
        ),
      ],
    );
  }
}

/// Figma Ellipse assets, recolored to solid brand blue and pinned to screen edges.
class _CurvedEdge extends StatelessWidget {
  const _CurvedEdge({
    required this.asset,
    required this.width,
    required this.height,
  });

  final String asset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    // srcIn keeps curve shape; stack boosts export alpha so blue reads solid.
    Widget layer() => Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.fill,
      color: AppColors.edgeBlue,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
    );

    return SizedBox(
      width: width,
      height: height,
      child: Stack(fit: StackFit.expand, children: [layer(), layer()]),
    );
  }
}
