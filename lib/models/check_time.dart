import 'package:intl/intl.dart';
class Check{

  String checkDate(DateTime created,DateTime now){
    var minute=now.difference(created).inMinutes;
    String date="";
    if(minute<60){
      //date=minute.toString()+ " min ago";
      date=minute.toString()+" min ago";
    }else{
      if((minute/60)<72){
        if((minute/60)<24){
          date=(minute/60).toStringAsFixed(0).toString()+" hours ago";
        }else{
          date=((minute/60)/24).toStringAsFixed(0).toString()+" days ago";
        }
      }else{
        var df = new DateFormat('dd-MM-yyyy | hh:mm a');
        //date=created.day.toString()+"-"+created.month.toString()+"-"+created.year.toString()+" at "+created.hour.toString()+":"+created.minute.toString();
        date=df.format(created);
      }
    }
    return date;
  }

  int checkImage(List<String> imgList){
    var height=0;
//    if(imageList.length==1){
//      height=200;
//    }else if(imageList.length==2 || imageList.length==3){
//      height=130;
//    }else if(imageList.length>3 && imageList.length<=6){
//      height=240;
//    }else if(imageList.length>6 && imageList.length<=9){
//      height=380;
//    }
    if(imgList.length==1){
      height=200;
    }else if(imgList.length==3){
      height=100;
    }else if(imgList.length==2){
      height=150;
    } else if(imgList.length>3 && imgList.length<=6){
      height=200;
      print(imgList.length);
    }else if(imgList.length>6 && imgList.length<=9){
      height=300;
    }
    return height;
  }

}