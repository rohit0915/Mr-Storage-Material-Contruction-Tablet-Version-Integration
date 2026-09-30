import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Modern, smooth, high-performance shimmer loading effect used throughout the application.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.shape = BoxShape.rectangle,
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? const Color(0xFFE2E8F0);
    final highlight = widget.highlightColor ?? const Color(0xFFF8FAFC);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(widget.borderRadius)
                : null,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_controller.value * 3.0), -0.3),
              end: Alignment(0.0 + (_controller.value * 3.0), 0.3),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer placeholder for Dashboard 6 metric cards row.
class AppShimmerMetricsRow extends StatelessWidget {
  const AppShimmerMetricsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = size.width * 0.012;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 850;
        final count = 6;

        if (isNarrow) {
          final colWidth = (constraints.maxWidth - gap * 2) / 3;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: List.generate(
              count,
              (_) => SizedBox(
                width: colWidth,
                child: const _SingleMetricShimmerCard(),
              ),
            ),
          );
        }

        return Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) SizedBox(width: gap),
              const Expanded(child: _SingleMetricShimmerCard()),
            ],
          ],
        );
      },
    );
  }
}

class _SingleMetricShimmerCard extends StatelessWidget {
  const _SingleMetricShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer(width: 36, height: 36, borderRadius: 8),
          SizedBox(height: 12),
          AppShimmer(width: 60, height: 20, borderRadius: 4),
          SizedBox(height: 6),
          AppShimmer(width: 90, height: 12, borderRadius: 4),
          SizedBox(height: 10),
          AppShimmer(width: 70, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for summary top cards (4 cards row).
class AppShimmerSummaryRow extends StatelessWidget {
  const AppShimmerSummaryRow({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);

    return Row(
      children: List.generate(
        count,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == count - 1 ? 0 : gap),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmer(width: 80, height: 12),
                        SizedBox(height: 8),
                        AppShimmer(width: 50, height: 22),
                        SizedBox(height: 6),
                        AppShimmer(width: 70, height: 10),
                      ],
                    ),
                  ),
                  AppShimmer(width: 38, height: 38, borderRadius: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for full-width table views (e.g., Material Requests, Deliveries, Tasks, Active Sites).
class AppShimmerTable extends StatelessWidget {
  const AppShimmerTable({
    super.key,
    this.rowCount = 6,
    this.rowHeight = 44.0,
  });

  final int rowCount;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minWidth = constraints.maxWidth.clamp(1000.0, 2400.0);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: minWidth,
              child: Column(
                children: [
                  // Table Header Shimmer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.tableHeader,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: AppShimmer(height: 14)),
                        SizedBox(width: 12),
                        Expanded(flex: 2, child: AppShimmer(height: 14)),
                        SizedBox(width: 12),
                        Expanded(flex: 2, child: AppShimmer(height: 14)),
                        SizedBox(width: 12),
                        Expanded(flex: 2, child: AppShimmer(height: 14)),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  // Rows Shimmer
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rowCount,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppColors.cardBorder),
                    itemBuilder: (_, index) => Container(
                      height: rowHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Row(
                        children: [
                          Expanded(flex: 3, child: AppShimmer(height: 14)),
                          SizedBox(width: 12),
                          Expanded(flex: 2, child: AppShimmer(height: 14)),
                          SizedBox(width: 12),
                          Expanded(flex: 2, child: AppShimmer(height: 14)),
                          SizedBox(width: 12),
                          Expanded(flex: 2, child: AppShimmer(height: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shimmer placeholder for Grid items (e.g. Project Cards, Drawing Cards).
class AppShimmerGrid extends StatelessWidget {
  const AppShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1.3,
  });

  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = size.width * 0.012;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer(height: 120, borderRadius: 10),
              SizedBox(height: 12),
              AppShimmer(width: 140, height: 16),
              SizedBox(height: 8),
              AppShimmer(width: 100, height: 12),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppShimmer(width: 60, height: 20, borderRadius: 10),
                  AppShimmer(width: 60, height: 20, borderRadius: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shimmer card placeholder for single cards (e.g., Donut Overview Card, Timeline Card).
class AppShimmerCard extends StatelessWidget {
  const AppShimmerCard({
    super.key,
    this.height = 240,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmer(width: 140, height: 16),
              AppShimmer(width: 50, height: 14),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: AppShimmer(width: 110, height: 110, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
