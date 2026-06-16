import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/core/utils/animations.dart';
import 'package:grip_strength_monitor/services/statistics_provider.dart';
import 'package:grip_strength_monitor/shared/models/grip_data.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: Consumer<StatisticsProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAnimations.fadeSlideUp(controller: _animController, delay: 0.0, child: _buildPeriodSelector(context, provider)),
                SizedBox(height: 24),
                AppAnimations.fadeSlideUp(controller: _animController, delay: 0.1, child: _buildSummaryCards(context, provider)),
                SizedBox(height: 24),
                AppAnimations.fadeSlideUp(controller: _animController, delay: 0.2, child: _buildTrendChart(context, provider)),
                SizedBox(height: 24),
                AppAnimations.fadeSlideUp(controller: _animController, delay: 0.3, child: _buildInsightsCard(context, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, StatisticsProvider provider) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: TimePeriod.values.map((period) {
          final isSelected = provider.selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.updatePeriod(period),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    _getPeriodLabel(period),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.days7:
        return AppLocalizations.get('days7');
      case TimePeriod.days30:
        return AppLocalizations.get('days30');
      case TimePeriod.days90:
        return AppLocalizations.get('days90');
    }
  }

  Widget _buildSummaryCards(BuildContext context, StatisticsProvider provider) {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard(context, AppLocalizations.get('average'), '${provider.averageGrip.toStringAsFixed(1)}', 'kg', AppTheme.primaryBlue)),
        SizedBox(width: 12),
        Expanded(child: _buildSummaryCard(context, AppLocalizations.get('maximum'), '${provider.maxGrip.toStringAsFixed(1)}', 'kg', AppTheme.accentGreen)),
        SizedBox(width: 12),
        Expanded(child: _buildSummaryCard(
          context,
          AppLocalizations.get('trend'),
          '${provider.trend >= 0 ? '+' : ''}${provider.trend.toStringAsFixed(1)}',
          '%',
          provider.trend >= 0 ? AppTheme.accentGreen : AppTheme.riskRed,
        )),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, String unit, Color color) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color, letterSpacing: -0.5)),
              SizedBox(width: 2),
              Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(unit, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context, StatisticsProvider provider) {
    final data = provider.data;
    if (data.isEmpty) return SizedBox();

    final maxValue = data.map((e) => e.gripStrength).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e.gripStrength).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.get('gripTrend'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, letterSpacing: -0.2),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size(double.infinity, 180),
              painter: _LineChartPainter(data, maxValue, minValue, range),
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDate(data.first.date), style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              Text(_formatDate(data.last.date), style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(BuildContext context, StatisticsProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.accentGreen.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.get('insights'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, letterSpacing: -0.2),
          ),
          SizedBox(height: 16),
          _buildInsightItem(
            Icons.trending_up_rounded,
            AppLocalizations.get('consistency'),
            AppLocalizations.getWithParams('trainedDays', {'count': '${provider.data.length}'}),
            AppTheme.primaryBlue,
          ),
          SizedBox(height: 12),
          _buildInsightItem(
            Icons.star_rounded,
            AppLocalizations.get('peakStrength').split(' ').first,
            AppLocalizations.getWithParams('peakStrength', {'value': provider.maxGrip.toStringAsFixed(1)}),
            AppTheme.accentGreen,
          ),
          SizedBox(height: 12),
          _buildInsightItem(
            Icons.insights_rounded,
            AppLocalizations.get('trend'),
            provider.trend >= 0
                ? AppLocalizations.getWithParams('improved', {'value': provider.trend.toStringAsFixed(1)})
                : AppLocalizations.get('keepWorking'),
            provider.trend >= 0 ? AppTheme.accentGreen : AppTheme.warningOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class _LineChartPainter extends CustomPainter {
  final List<GripData> data;
  final double maxValue;
  final double minValue;
  final double range;

  _LineChartPainter(this.data, this.maxValue, this.minValue, this.range);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.primaryBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = AppTheme.primaryBlue
      ..style = PaintingStyle.fill;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppTheme.primaryBlue.withValues(alpha: 0.2), AppTheme.primaryBlue.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i].gripStrength - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height * 0.7 + size.height * 0.15);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.data != data;
}
