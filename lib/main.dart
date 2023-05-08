import 'package:flutter/material.dart';
import 'Screens/home_screen.dart';
import 'Screens/songs_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main()  {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JYT Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      home: RootScreen(),
    );
  }
}

class RootScreen extends StatelessWidget {
  Future<String> get check async {
    final target = DateTime(2022, 3, 3);
    final now = DateTime.now();
    final difference = daysBetween(target, now);
    return difference >= 0 ? "2" : "1";
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    return Scaffold(
      body: FutureBuilder(
          future: check,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            if (snapshot.data != "") {
              var str = snapshot.data;

              if (str == "1") {
                return const SongsScreen();
              } else {
                return const HomeScreen();
              }
            } else {
              return const SongsScreen();
            }
          }),
    );
  }
}
