import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customText.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';


class CustomMarquee extends StatelessWidget {
  final String str;
  final double size;
  final FontWeight fontWeight;
  final Color color;
  CustomMarquee(this.str, this.color, this.size, this.fontWeight);

  @override
  Widget build(BuildContext context) {
    return str.length > 5 ?
      Marquee(
        text: str,
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 30.0,
        // velocity: 100.0,
        pauseAfterRound: Duration(seconds: 2),
        showFadingOnlyWhenScrolling: true,
        fadingEdgeStartFraction: 0.1,
        fadingEdgeEndFraction: 0.1,
        //startPadding: 10.0,
        accelerationDuration: Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        // decelerationDuration: Duration(milliseconds: 500),
        // decelerationCurve: Curves.easeOut,
        style: TextStyle(
          wordSpacing: 1.15,
          color: ColorCustom.orange,
          fontSize: size,
          fontFamily: 'Lato',
          fontWeight: fontWeight,
        ),
      ) :
      TextLato(str, color, size, fontWeight);
  }
}