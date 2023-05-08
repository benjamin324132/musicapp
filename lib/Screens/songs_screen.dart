import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Components/coustom_bottom_nav_bar.dart';
import '../Utils/constants.dart';
import '../Utils/enums.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({Key? key}) : super(key: key);

  @override
  _SongsScreenState createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  TextEditingController textSearch = TextEditingController();
  List<SongModel> songs = [];
  List<SongModel> filteredSongs = [];
  bool isLoading = true;

  @override
  void initState() {
    getSongs();
    super.initState();
  }

  getSongs() async {
    // DEFAULT:
    // SongSortType.TITLE,
    // OrderType.ASC_OR_SMALLER,
    // UriType.EXTERNAL,
    while (!await _audioQuery.permissionsStatus()) {
      await _audioQuery.permissionsRequest();
    }
    List<SongModel> something =
        await _audioQuery.querySongs(sortType: SongSortType.DATE_ADDED);
    setState(() {
      songs = something;
      filteredSongs = something;
      isLoading = false;
    });
  }

  searchSong() async {
    if (textSearch.text.isNotEmpty) {
      filteredSongs = [];

      setState(() {
        filteredSongs = List.from(songs.where((song) =>
            song.title.toLowerCase().contains(textSearch.text.toLowerCase())));
      });
    } else {
      setState(() {
        filteredSongs = songs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar:
          const CustomBottomNavBar(selectedMenu: MenuState.search),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : songs.isNotEmpty
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(13)),
                                ),
                                child: TextField(
                                    controller: textSearch,
                                    decoration:  InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 16),
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
                      ),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 10),
                          shrinkWrap: true,
                          itemExtent: 70.0,
                          itemCount: filteredSongs.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                filteredSongs[index].title.trim() != ''
                                    ? filteredSongs[index].title
                                    : filteredSongs[index].displayNameWOExt,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${filteredSongs[index].artist?.replaceAll('<unknown>', 'Unknown') ?? "unknown"} - ${filteredSongs[index].album?.replaceAll('<unknown>', 'Unknown') ?? "unknown"}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () async {
                                await OpenFile.open(filteredSongs[index].data);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  )
                :  Center(child: Text(AppLocalizations.of(context).noMusic)),
      ),
    );
  }
}
