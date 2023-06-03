import 'package:dikouba_rawstart/widget/UI/Constants/constants.dart';
import 'package:dikouba_rawstart/widget/UI/Models/page_bubble_view_model.dart';
import 'package:dikouba_rawstart/widget/UI/Models/pager_indicator_view_model.dart';
import 'package:dikouba_rawstart/widget/UI/page_bubble.dart';
import 'package:flutter/material.dart';

/// This class contains the UI elements associated with bottom page indicator.

class PagerIndicator extends StatelessWidget {
  //view model
  final PagerIndicatorViewModel viewModel;

  //Constructor
  PagerIndicator({
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    //Extracting page bubble information from page view model
    List<PageBubble> bubbles = [];

    for (var i = 0; i < viewModel.pages.length; i++) {
      final page = viewModel.pages[i];

      //calculating percent active
      var percentActive;
      if (i == viewModel.activeIndex) {
        percentActive = 1.0 - viewModel.slidePercent;
      } else if (i == viewModel.activeIndex - 1 &&
          viewModel.slideDirection == SlideDirection.leftToRight) {
        percentActive = viewModel.slidePercent;
      } else if (i == viewModel.activeIndex + 1 &&
          viewModel.slideDirection == SlideDirection.rightToLeft) {
        percentActive = viewModel.slidePercent;
      } else {
        percentActive = 0.0;
      }

      //Checking is that bubble hollow
      bool isHollow = i > viewModel.activeIndex ||
          (i == viewModel.activeIndex &&
              viewModel.slideDirection == SlideDirection.leftToRight);

      //Adding to the list
      bubbles.add(PageBubble(
        viewModel: PageBubbleViewModel(
          iconAssetPath: page.iconImageAssetPath!,
          iconColor: page.iconColor,
          isHollow: isHollow,
          activePercent: percentActive,
          bubbleBackgroundColor: page.bubbleBackgroundColor,
          bubbleInner: page.bubble!,
        ),
      ));
    }

    //Calculating the translation value of pager indicator while sliding.
    final baseTranslation =
        ((viewModel.pages.length * BUBBLE_WIDTH) / 2 / 10) - (BUBBLE_WIDTH / 2 /10 ); //Added /10 to avoid overlap on skip button
    var translation = baseTranslation - (viewModel.activeIndex * BUBBLE_WIDTH / 10); //Added /10 to avoid overlap on skip button

    if (viewModel.slideDirection == SlideDirection.leftToRight) {
      translation += BUBBLE_WIDTH * viewModel.slidePercent /10; //Added /10 to avoid overlap on skip button
    } else if (viewModel.slideDirection == SlideDirection.rightToLeft) {
      translation -= BUBBLE_WIDTH * viewModel.slidePercent /10; //Added /10 to avoid overlap on skip button
    }
    //UI
    return Column(
      children: <Widget>[
        Expanded(child: Container()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform(
              // used for horizontal transformation
              transform: Matrix4.translationValues(translation, 0.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: bubbles,
              ), //Row
            ),
          ],
        ), //Transform
      ], //Children
    ); //Column
  }
}
