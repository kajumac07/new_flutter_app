import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle appStyle(double size, Color color, FontWeight fw) {
  return GoogleFonts.aBeeZee(fontSize: size.sp, color: color, fontWeight: fw);
}

TextStyle appStylePoppins(double size, Color color, FontWeight fw) {
  return GoogleFonts.poppins(fontSize: size.sp, color: color, fontWeight: fw);
}

TextStyle appStyleRoboto(double size, Color color, FontWeight fw) {
  return GoogleFonts.roboto(fontSize: size.sp, color: color, fontWeight: fw);
}

TextStyle appStyleLato(double size, Color color, FontWeight fw) {
  return GoogleFonts.lato(fontSize: size.sp, color: color, fontWeight: fw);
}

TextStyle appStyleMontserrat(double size, Color color, FontWeight fw) {
  return GoogleFonts.montserrat(
    fontSize: size.sp,
    color: color,
    fontWeight: fw,
  );
}

TextStyle appStyleRaleway(double size, Color color, FontWeight fw) {
  return GoogleFonts.raleway(fontSize: size.sp, color: color, fontWeight: fw);
}

TextStyle appStyleOswald(double size, Color color, FontWeight fw) {
  return GoogleFonts.oswald(fontSize: size.sp, color: color, fontWeight: fw);
}
