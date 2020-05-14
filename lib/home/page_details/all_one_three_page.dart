import 'package:flutter/material.dart';
import 'package:news/home/page_details/moment_page_details.dart';
import 'package:news/home/page_details/one_three_page_details.dart';

class AllPageDetails extends StatefulWidget {
  final String option;
  final List image;
  final bool follow;
  AllPageDetails({Key key,this.option,this.image,this.follow}):super(key: key);

  @override
  _AllPageDetailsState createState() => _AllPageDetailsState();
}

class _AllPageDetailsState extends State<AllPageDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.option=='moment'? MomentPageDetails(image: widget.image,follow: widget.follow,) : OneThreePageDetails(image: widget.image,),
    );
  }
}