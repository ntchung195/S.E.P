import 'package:flutter/material.dart';

// Widget textLato(String str, Color color , double size, FontWeight fontweight){
//   return Text(
//     str,
//     overflow: TextOverflow.ellipsis,
//     style: TextStyle(
//       color: color,
//       fontSize: size,
//       fontFamily: 'Lato',
//       fontWeight: fontweight,
//     ),
//   );
// }

class TextLato extends StatelessWidget {

  final String str;
  final Color color;
  final double size;
  final FontWeight fontWeight;

  TextLato(this.str, this.color, this.size, this.fontWeight);

  @override
  Widget build(BuildContext context) {
    return Text(
      str,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        wordSpacing: 1.15,
        color: color,
        fontSize: size,
        fontFamily: 'Lato',
        fontWeight: fontWeight,
      ),
    );
  }
  
}