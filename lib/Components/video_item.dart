
import 'package:flutter/material.dart';

import '../Screens/download_screen.dart';
import '../Utils/constants.dart';
import '../Utils/string_helper.dart';

class VideoItem extends StatefulWidget {
  const VideoItem(
      {Key? key,
      this.video,
      required this.chanel,
      required this.image,
      required this.title,
      required this.duration})
      : super(key: key);

  final String image, title, chanel, duration;
  final dynamic video;

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DownladScreen(video: widget.video),
            ))
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Text(
                          widget.title,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Text("Creative Commons"),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          widget.duration,
                          style: const TextStyle(color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
