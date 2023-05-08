import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../Components/coustom_bottom_nav_bar.dart';
import '../Components/video_item.dart';
import '../Utils/constants.dart';
import '../Utils/enums.dart';
import '../Utils/keyboard.dart';
import '../Utils/string_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController textSearch = TextEditingController();
  List<Video> ytResult = [];
  dynamic data;
  var yt = YoutubeExplode();
  bool showBanner = true;
  final InAppReview inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    showRequestReview();

  }

  searchSong() async {
    if (textSearch.text.isNotEmpty) {
      try {
        VideoSearchList suggestions = await yt.search.search(textSearch.text);
        setState(() {
          ytResult = suggestions;
        });
        KeyboardUtil.hideKeyboard(context);
      } catch (err) {
        throw Exception(err.toString());
      }
    }
  }

  showRequestReview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool show = (prefs.getBool('show') ?? true);
    int counter = (prefs.getInt('counter') ?? 0) + 1;

    if (show) {
      if (counter >= 6) {
        await prefs.setInt('counter', 0);
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
        } else {
          showAlertDialog(context);
        }
      } else {
        await prefs.setInt('counter', counter);
      }
    }
  }

  showAlertDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Widget remindButton = TextButton(
      child: Text(AppLocalizations.of(context).later),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).cancel),
      onPressed: () async {
        await prefs.setBool('show', false);
        Navigator.of(context).pop();
      },
    );
    Widget launchButton = TextButton(
      child: Text(AppLocalizations.of(context).rate),
      onPressed: () async {
        await prefs.setBool('show', false);
        inAppReview.openStoreListing(
            appStoreId: 'com.xipeapps.musicapp');
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).rateApp),
      content: Text(AppLocalizations.of(context).takeMoment),
      actions: [
        remindButton,
        cancelButton,
        launchButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<Map?> getVideoData({
    required Video video,
    required String quality,
    // bool preferM4a = true,
  }) async {
    if (video.duration?.inSeconds == null) return null;
    print("Asking uri");
    final StreamManifest manifest =
        await yt.videos.streamsClient.getManifest(video.id);
    print("2");
    final List<AudioOnlyStreamInfo> sortedStreamInfo =
        manifest.audioOnly.sortByBitrate();
    final List urls = [
      sortedStreamInfo.first.url.toString(),
      sortedStreamInfo.last.url.toString(),
    ];
    print("finish asking uri");
    return {
      'id': video.id.value,
      'album': video.author,
      'duration': video.duration?.inSeconds.toString(),
      'title': video.title,
      'artist': video.author,
      'image': video.thumbnails.maxResUrl,
      'secondImage': video.thumbnails.highResUrl,
      'language': 'YouTube',
      'genre': 'YouTube',
      'url': quality == 'High' ? urls.last : urls.first,
      'lowUrl': urls.first,
      'highUrl': urls.last,
      'year': video.uploadDate?.year.toString(),
      '320kbps': 'false',
      'has_lyrics': 'false',
      'release_date': video.publishDate.toString(),
      'album_id': video.channelId.value,
      'subtitle': video.author,
      'perma_url': video.url,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar:
          const CustomBottomNavBar(selectedMenu: MenuState.home),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: const BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(13)),
                          ),
                          child: TextField(
                              controller: textSearch,
                              decoration:  InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 16),
                                border: InputBorder.none,
                                hintText: AppLocalizations.of(context).search,
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: SizedBox(
                                    width: 50,
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    )),
                              )),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        child: Container(
                            height: 50,
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(13)),
                            ),
                            child: IconButton(
                                icon: const Icon(
                                  Icons.search,
                                  size: 25,
                                  color: blackColor,
                                ),
                                onPressed: () {
                                  searchSong();
                                })),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  itemCount: ytResult.length,
                  itemBuilder: (_, int index) => VideoItem(
                    image: ytResult[index].thumbnails.mediumResUrl.toString(),
                    title: titleParser(ytResult[index].title),
                    chanel: ytResult[index].author,
                    duration: ytResult[index].duration != null
                        ? durationToString(ytResult[index].duration)
                        : "N/A",
                    video: ytResult[index],
                  ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*


                  GestureDetector(
                    onTap: () async {
                   final result = await  getVideoData(video: ytResult[index], quality: "High");
                   print(result!['url']);
                    },
                    child: Container(
                      child: Text(ytResult[index].title),
                    ),
                  )
*/