import 'package:flutter/material.dart';

const colorSeed = Color.fromARGB(255, 7, 73, 79);
const scaffoldBackgroundColor = Color.fromARGB(255, 255, 255, 255);

class AppTheme {

  ThemeData getTheme() => ThemeData(

    ///* General
    useMaterial3: true,
    colorSchemeSeed: colorSeed,
    hintColor: colorSeed,

    ///* Texts
    /*textTheme: TextTheme(
      titleLarge: GoogleFonts.montserratAlternates()
        .copyWith( fontSize: 21, fontWeight: FontWeight.bold ),
      titleMedium: GoogleFonts.montserratAlternates()
        .copyWith( fontSize: 17, fontWeight: FontWeight.bold ),
      titleSmall: GoogleFonts.montserratAlternates()
        .copyWith( fontSize: 10 )
    ),*/

    ///* Scaffold Background Color
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    

    ///* AppBar
    appBarTheme: AppBarTheme(
      color: scaffoldBackgroundColor,
      //titleTextStyle: GoogleFonts.montserratAlternates()
      //  .copyWith( fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black ),
    )
  );

}