import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../global/global.dart';


///CustomInputFiled
///담당자 : ---

class CustomInputFiled extends StatefulWidget {

  TextEditingController? controller;
  String? label;
  String? labelText;
  Color? textColor;
  Color? fillColor;
  Color? borderLineColor;
  Color? validatorColor;
  bool? counterText;
  FontWeight? fontWeight;
  TextAlign? textAlign;
  String? hintText;
  double? contentsPaddingHorizontal;
  double? contentsPaddingVertical;
  TextInputType? keyboardType;
  bool? obscureText;
  List<TextInputFormatter>? textInputFormatter;
  int? maxLength;
  int? maxLine;
  Widget? button;
  FormFieldValidator? validator;
  Function onChanged;
  VoidCallback? onTap;
  String? initialValue;
  bool? readOnly;
  bool suffix;
  double? borderRadius;
  bool? isDense;
  double? fontSize;
  Widget? suffixIcon;
  int? minLines;
  FocusNode? focusNode;

  CustomInputFiled({
    Key? key,
    this.controller,
    this.label,
    this.labelText,
    this.textColor,
    this.fillColor,
    this.borderLineColor,
    this.validatorColor,
    this.counterText,
    this.fontWeight,
    this.textAlign,
    this.hintText,
    this.contentsPaddingHorizontal,
    this.contentsPaddingVertical,
    this.keyboardType,
    this.obscureText,
    this.textInputFormatter,
    this.maxLength,
    this.maxLine,
    this.button,
    this.validator,
    required this.onChanged,
    this.onTap,
    this.initialValue,
    this.readOnly,
    required this.suffix,
    this.borderRadius,
    this.isDense,
    this.fontSize,
    this.suffixIcon,
    this.minLines,
    this.focusNode,
  }) : super(key: key);

  @override
  State<CustomInputFiled> createState() => _CustomInputFiledState();
}

class _CustomInputFiledState extends State<CustomInputFiled> {

  bool obscureText=false;
  @override
  void initState() {
    super.initState();

    setState(() {
      obscureText = widget.obscureText??false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      controller: widget.controller,
      focusNode: widget.focusNode,
      onTap: widget.onTap,
      maxLines: widget.maxLine??1,
      minLines: widget.minLines,
      initialValue: widget.initialValue,
      readOnly: widget.readOnly??false,
      keyboardType: widget.keyboardType??TextInputType.text,
      inputFormatters: widget.textInputFormatter,
      style: TextStyle(color: widget.textColor ,fontWeight: widget.fontWeight,fontSize:widget.fontSize?? 16 ),
      textAlign: widget.textAlign??TextAlign.start,
      cursorColor: appColorPrimary,
      onChanged: (val){
        widget.onChanged(val);
      },

      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: obscureText,
      maxLength: widget.maxLength??100,
      decoration: InputDecoration(
          labelText: widget.labelText??"",
          suffix: Container(
            child:widget.suffix
                ?GestureDetector(
                onTap: (){
                  setState(() {
                    obscureText =! obscureText;
                  });

                },
                child: Text(obscureText?"보이기":"안보이기"))
                :SizedBox(),
          ),
          errorStyle: TextStyle(
            color: widget.validatorColor??Colors.red,
          ),
          suffixIcon: widget.suffixIcon,
          hintText: widget.hintText,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(fontSize: 14),
          isDense: widget.isDense,
          contentPadding: EdgeInsets.symmetric(horizontal: widget?.contentsPaddingHorizontal??15.0,vertical: widget?.contentsPaddingVertical??0),
          filled: true,
          fillColor: widget?.fillColor??appColorPrimary,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius??20.0),
              borderSide: BorderSide(color: widget?.borderLineColor??Colors.transparent)
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius??20.0),
              borderSide: BorderSide(color: appColorPrimary)
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius??20.0),
              borderSide: BorderSide(color: widget?.borderLineColor??Colors.transparent)
          ),
          counterText: widget.counterText==null?"":widget.counterText==true?null:""

      ),


    );
  }
}
