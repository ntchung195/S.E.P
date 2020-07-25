
import 'package:MusicApp/BloC/musicplayerBloC.dart';
import 'package:MusicApp/BloC/userBloC.dart';

class GlobalBloC {

  UserBloC userBloC;
  MusicPlayerBloC mpBloC;

  GlobalBloC(){
    userBloC = UserBloC();
    mpBloC = MusicPlayerBloC();
  }

  void dispose(){
    mpBloC.dispose();
    userBloC.dispose();
  }

}