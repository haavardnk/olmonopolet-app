import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';

class RangeFilter extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String unit;
  final RangeValues values;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<RangeValues> onChanged;

  const RangeFilter({
    super.key,
    required this.title,
    this.icon,
    required this.unit,
    required this.values,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDefault = values.start == min && values.end == max;
    final startValue = values.start.round().toString();
    final endValue = values.end == max
        ? '${values.end.round()}+'
        : values.end.round().toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16.r, color: colors.primary),
                    SizedBox(width: 6.w),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('$startValue - $endValue $unit',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.primary)),
                  if (!isDefault) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onChanged(RangeValues(min, max)),
                      child:
                          Icon(Icons.refresh, size: 16, color: colors.primary),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              rangeThumbShape:
                  const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 3,
            ),
            child: RangeSlider(
                values: values,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class PriceRangeFilter extends StatefulWidget {
  final StateSetter parentSetState;

  const PriceRangeFilter({super.key, required this.parentSetState});

  @override
  State<PriceRangeFilter> createState() => _PriceRangeFilterState();
}

class _PriceRangeFilterState extends State<PriceRangeFilter> {
  late RangeValues _priceRange;
  late RangeValues _pricePerVolumeRange;

  @override
  void initState() {
    super.initState();
    final filters = Provider.of<Filter>(context, listen: false);
    _priceRange = filters.priceRange;
    _pricePerVolumeRange = filters.pricePerVolumeRange;
  }

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return Column(
      children: [
        RangeFilter(
          title: 'Pris',
          icon: Icons.payments_outlined,
          unit: 'kr',
          values: _priceRange,
          min: 0,
          max: 500,
          divisions: 20,
          onChanged: (v) {
            setState(() => _priceRange = v);
            widget.parentSetState(() {});
            filters.setPriceRange(_priceRange);
          },
        ),
        RangeFilter(
          title: 'Pris per liter',
          icon: Icons.water_drop_outlined,
          unit: 'kr',
          values: _pricePerVolumeRange,
          min: 0,
          max: 1000,
          divisions: 20,
          onChanged: (v) {
            setState(() => _pricePerVolumeRange = v);
            widget.parentSetState(() {});
            filters.setPricePerVolumeRange(_pricePerVolumeRange);
          },
        ),
      ],
    );
  }
}

class AlcoholRangeFilter extends StatefulWidget {
  final StateSetter parentSetState;

  const AlcoholRangeFilter({super.key, required this.parentSetState});

  @override
  State<AlcoholRangeFilter> createState() => _AlcoholRangeFilterState();
}

class _AlcoholRangeFilterState extends State<AlcoholRangeFilter> {
  late RangeValues _alcoholRange;

  @override
  void initState() {
    super.initState();
    _alcoholRange = Provider.of<Filter>(context, listen: false).alcoholRange;
  }

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return RangeFilter(
      title: 'Alkohol',
      icon: Icons.percent,
      unit: '%',
      values: _alcoholRange,
      min: 0,
      max: 15,
      divisions: 15,
      onChanged: (v) {
        setState(() => _alcoholRange = v);
        widget.parentSetState(() {});
        filters.setAlcoholRange(_alcoholRange);
      },
    );
  }
}
