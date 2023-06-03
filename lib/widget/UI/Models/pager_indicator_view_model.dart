import 'package:dikouba_rawstart/widget/UI/Constants/constants.dart';
import 'package:dikouba_rawstart/widget/UI/Models/page_view_model.dart';

class PagerIndicatorViewModel {
  final List<PageViewModel> pages;
  final int activeIndex;
  final SlideDirection slideDirection;
  final double slidePercent;

  PagerIndicatorViewModel(
    this.pages,
    this.activeIndex,
    this.slideDirection,
    this.slidePercent,
  );
}
