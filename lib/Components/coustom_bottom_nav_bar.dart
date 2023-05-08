import 'package:flutter/material.dart';


import '../Screens/home_screen.dart';
import '../Screens/songs_screen.dart';
import '../Utils/constants.dart';
import '../Utils/enums.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    Key? key,
    required this.selectedMenu,
  }) : super(key: key);

  final MenuState selectedMenu;

  @override
  Widget build(BuildContext context) {
    const Color inActiveIconColor = Color(0xFFB6B6B6);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding / 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -15),
            blurRadius: 20,
            color: const Color(0xFFDADADA).withOpacity(0.15),
          ),
        ],
      ),
      child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: MenuState.home == selectedMenu
                      ? primaryColor
                      : inActiveIconColor,
                ),
                onPressed: () {
                  if (MenuState.home != selectedMenu)
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                        (Route<dynamic> route) => false);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.music_note,
                  color: MenuState.search == selectedMenu
                      ? primaryColor
                      : inActiveIconColor,
                ),
                onPressed: () {
                  if (MenuState.search != selectedMenu)
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SongsScreen()));
                },
              ),
            ],
          )),
    );
  }
}
