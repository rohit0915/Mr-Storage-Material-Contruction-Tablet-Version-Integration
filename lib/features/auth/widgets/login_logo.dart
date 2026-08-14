import 'package:flutter/material.dart';

import '../../../app/constants/app_assets.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoWidth = (size.width * 0.26).clamp(200.0, 300.0);
    final logoHeight = (size.height * 0.08).clamp(48.0, 72.0);

    // Home / warehouse icon + "STEEL BUILDING DEPOT" from Figma logo asset
    return Image.asset(
      AppAssets.logo,
      width: logoWidth,
      height: logoHeight,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
