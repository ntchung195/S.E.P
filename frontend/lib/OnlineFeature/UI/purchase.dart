
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';

class Purchase extends StatelessWidget {

  // @override
  // Widget build(BuildContext context) {
  //   SizeConfig().init(context);
  //   return Scaffold(
  //       appBar: appBar(context),
  //       backgroundColor: Colors.black,
  //       body: Column(
  //         children: <Widget>[
  //           SizedBox(height: 50/640*SizeConfig.screenHeight,),
  //         Expanded(
  //           child: Container(
  //             padding: EdgeInsets.only(left: 38, right: 38),
  //             child: paymentMethod(context),
  //         ),
  //         )],
  //       )
  //   );
  // }

  // Widget appBar(BuildContext context) {
  //   return AppBar(
  //     backgroundColor: Colors.black,
  //     centerTitle: true,
  //     leading: BackButton(
  //         onPressed: () {
  //           Navigator.pop(context);
  //         }
  //     ),
  //     title: text("PAYMENT METHOD"),
  //     actions: <Widget>[
  //       IconButton(
  //         onPressed: () {},
  //         icon: Icon(
  //             IconCustom.settings_1
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: ColorCustom.grey,
      height: 500,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: text("Payment Method", size: 21, color: Colors.white, font: FontWeight.w700),
            )
          ),
          SizedBox(height: 20/640*SizeConfig.screenHeight,),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 38, right: 38),
              child: paymentMethod(context),
            ),
          )
        ],
      )
    );
  }


  Widget text(String str, {Color color = Colors.white, double size = 20.0, FontWeight font = FontWeight.w700}) {
    return Text(
      str,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: 'Lato',
        fontWeight: font,
      ),
    );
  }

  Widget paymentMethod(BuildContext context) {
    return ListView(
      children: <Widget>[
        bankInfo(Image.asset('images/momo.png', fit: BoxFit.cover, width: 50.0,
          height: 50.0,), 'MoMo E-Wallet', context),
        bankInfo(Image.asset('images/visa.png', fit: BoxFit.cover, width: 50.0,
          height: 50.0,), 'Visa', context),
        bankInfo(Image.asset('images/ocb.png', fit: BoxFit.cover, width: 50.0,
          height: 50.0,), 'OCB Banking', context)
      ],
    );
  }

  Widget bankInfo(Image image, String bankName, BuildContext context) {
    return Container(
      height: 75,
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.white),
      // ),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 0,),
        leading: image,
        title: text(bankName, color: Colors.amber),
        onTap: (){
          createAlert(context, bankName).then((onValue) => print(onValue));// send to database
        },
      ),
    );
  }

  final TextEditingController customController = TextEditingController();

  Future<String> createAlert(BuildContext context, String bankName){
    return showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          backgroundColor: ColorCustom.grey,
          title: text("You are purchase using $bankName. \nEnter your password:", color: Colors.amber),
          content: TextField(
            obscureText: true,
            controller: customController,
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              color: Colors.amber,
            ),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)
              )
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 5.0,
              child: text('Cancel',size: 20, color: Colors.amber),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              elevation: 5.0,
                child: text('Confirm buy',size: 20 ,color: Colors.amber),
              onPressed: (){
                Navigator.of(context).pop(customController.text.toString());
              },
            )
          ],
        );
      }
    );
  }

}
