//create menu for TimeFilterType

import 'package:flutter/material.dart';

import '../../product/provider/product_filter_provider.dart';

class TimeFilterMenuWidget extends StatelessWidget {
  const TimeFilterMenuWidget({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<TimeFilterType> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TimeFilterType>(
      icon: const Icon(Icons.filter_list),
      onSelected: onSelected,
      itemBuilder: (context) => TimeFilterType.values
          .where((type) => type != TimeFilterType.none)
          .map(
            (type) => PopupMenuItem<TimeFilterType>(
              value: type,
              child: Text(type.displayName),
            ),
          )
          .toList(),
    );
  }
}

//segment time filter menu widget
class SegmentTimeFilterMenuWidget extends StatelessWidget {
  const SegmentTimeFilterMenuWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TimeFilterType selected;
  final ValueChanged<TimeFilterType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TimeFilterType>(
        segments: [
          ButtonSegment<TimeFilterType>(
            value: TimeFilterType.today,
            label: Text('Day'),
            icon: Icon(Icons.calendar_view_day),
          ),
          ButtonSegment<TimeFilterType>(
            value: TimeFilterType.last7Days,
            label: Text('Week'),
            icon: Icon(Icons.calendar_view_week),
          ),
          ButtonSegment<TimeFilterType>(
            value: TimeFilterType.last1Month,
            label: Text('Month'),
            icon: Icon(Icons.calendar_view_month),
          ),
          ButtonSegment<TimeFilterType>(
            value: TimeFilterType.last3Months,
            label: Text('Year'),
            icon: Icon(Icons.calendar_today),
          ),
        ],
        selected: {
          selected
        },
        onSelectionChanged: (newSelection) {
          onSelected(newSelection.first);
        });
  }
}

//tabs for TimeFilterType
class TabTimeFilterMenuWidget extends StatefulWidget {
  const TabTimeFilterMenuWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TimeFilterType selected;
  final ValueChanged<TimeFilterType> onSelected;

  @override
  State<TabTimeFilterMenuWidget> createState() => _TabTimeFilterMenuWidgetState();
}

class _TabTimeFilterMenuWidgetState extends State<TabTimeFilterMenuWidget> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 5, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16.0, right: 8.0),
          decoration: BoxDecoration(
            color: widget.selected == TimeFilterType.custom ? Theme.of(context).colorScheme.primary : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.date_range_sharp),
            onPressed: () {
              widget.onSelected(TimeFilterType.custom);
            },
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                labelPadding: EdgeInsets.only(right: 8.0),
                dividerHeight: 0,
                indicatorColor: Colors.transparent,
                tabAlignment: TabAlignment.start,
                tabs: TimeFilterTypeExtension.predefinedTypes.map((type) {
                  return ChoiceChip(
                    label: Text(type.displayName),
                    selected: widget.selected == type,
                    onSelected: (isSelected) {
                      if (isSelected) {
                        widget.onSelected(type);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
