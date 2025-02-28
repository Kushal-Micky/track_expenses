import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:minor_project/bargraph/individual_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // this list will hold the data for the bar graph
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();

    // we need to scroll to the latest month automatically
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
  }

  // initialize the bar data
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(x: index, y: widget.monthlySummary[index]),
    );
  }

  //calculate max for upper limit of graph
  double calculateMax() {
    double max = 500;
    widget.monthlySummary.sort();
    max = widget.monthlySummary.last * 1.05;

    if (max < 500) {
      return 500;
    }
    return max;
  }

  //scroll controller to make sure it scroll to the end / last month
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();

    double barWidth = 20;
    double spaceBetweenBars = 10;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          height: 250,
          width:
              barWidth * barData.length +
              spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                show: true,
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles,
                    reservedSize: 42,
                  ),
                ),
              ),
              barGroups:
                  barData
                      .map(
                        (data) => BarChartGroupData(
                          x: data.x,
                          barRods: [
                            BarChartRodData(
                              toY: data.y,
                              width: barWidth,
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade800,
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: calculateMax(),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta) {
  const textStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  String text;
  switch (value.toInt() % 12) {
    case 0:
      text = 'Jan';
      break;
    case 1:
      text = 'Feb';
      break;
    case 2:
      text = 'Mar';
      break;
    case 3:
      text = 'Apr';
      break;
    case 4:
      text = 'May';
      break;
    case 5:
      text = 'Jun';
      break;
    case 6:
      text = 'Jul';
      break;
    case 7:
      text = 'Aug';
      break;
    case 8:
      text = 'Sep';
      break;
    case 9:
      text = 'Oct';
      break;
    case 10:
      text = 'Nov';
      break;
    case 11:
      text = 'Dec';
      break;
    default:
      text = '';
      break;
  }
  return SideTitleWidget(
    space: 16,
    meta: meta,
    child: Text(text, style: textStyle),
  );
}
