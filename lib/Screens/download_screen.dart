import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Utils/constants.dart';
import '../Utils/string_helper.dart';

enum TrackStatus { downloading, idle, done }

class DownladScreen extends StatefulWidget {
  const DownladScreen({Key? key, required this.video}) : super(key: key);
  final Video video;
  @override
  _DownladScreenState createState() => _DownladScreenState(this.video);
}

class _DownladScreenState extends State<DownladScreen> {
  final Video video;
  var yt = YoutubeExplode();
  OnAudioQuery _audioQuery = OnAudioQuery();
  bool isLoading = false;
  bool succes = false;
  bool error = false;
  bool isFirst = false;
  bool completed = true;
  String songPath = "";
  double downProgress = 0.0;
  var len = 0;
  var durationFF = 250;
  double downloadProggress = 0.0;

  _DownladScreenState(this.video);

  download2(String id, String title) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).permissionDenied),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
      error = false;
      succes = false;
      completed = false;
    });
    try {
      StreamManifest manifest = await yt.videos.streamsClient.getManifest(id);
      title = titleParser(title);
      var fileName = '$title'
          .replaceAll(r'\', '')
          .replaceAll('/', '')
          .replaceAll('*', '')
          .replaceAll('?', '')
          .replaceAll('"', '')
          .replaceAll('<', '')
          .replaceAll('>', '')
          .replaceAll('&', '')
          .replaceAll('ñ', 'n')
          .replaceAll('+', '')
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll(':', '');

      var downloadsDirectory = await getDownloadPath();
      var filePath = path.join(downloadsDirectory!, "$fileName.mp3");
      File outputFile = File(filePath);
      final audio = manifest.audioOnly
          .where((audio) => audio.codec.mimeType == "audio/mp4")
          .withHighestBitrate();
      final audioStream = yt.videos.streamsClient.get(audio).asBroadcastStream();  

      final len = audio.size.totalBytes;
      var count = 0;
      var prevProgress = 0;  

      final statusCb = audioStream.listen(
        (event) {
          //print(event.length);
          /*if (TrackStatus.done != TrackStatus.downloading) {
          status.value = TrackStatus.downloading;
        }*/
        count += event.length;

        final progress = ((count / len) * 100).ceil();
        if (progress - prevProgress >= 1) {
          prevProgress = progress;
          setState(() {
            downProgress = progress.toDouble();
          });
        }
        },
        onDone: () async {
          setState(() {
            isLoading = false;
            succes = true;
            songPath = filePath;
            completed = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).succes),
            ),
          );
          try {
            _audioQuery.scanMedia(filePath);
          } catch (err) {}
        },
      );

      IOSink outputFileStream = outputFile.openWrite();
      await audioStream.pipe(outputFileStream);
      await outputFileStream.flush();
      await outputFileStream.close().then((value) async {
        return statusCb.cancel();
      });
    } catch (err) {
      setState(() {
        isLoading = false;
        error = true;
        succes = false;
        completed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failed),
        ),
      );
    }
  }

  Future<void> downloadFileFromYT(String id, String title) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).permissionDenied),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
      error = false;
      succes = false;
      completed = false;
    });
    try {
      final manifest = await yt.videos.streamsClient.getManifest(id);
      final audio = manifest.audioOnly
          .where((audio) => audio.codec.mimeType == "audio/mp4")
          .withHighestBitrate();
      final audioStream = yt.videos.streamsClient.get(audio).asBroadcastStream();

      title = titleParser(title);
      var fileName = '$title'
          .replaceAll(r'\', '')
          .replaceAll('/', '')
          .replaceAll('*', '')
          .replaceAll('?', '')
          .replaceAll('"', '')
          .replaceAll('<', '')
          .replaceAll('>', '')
          .replaceAll('&', '')
          .replaceAll('ñ', 'n')
          .replaceAll('+', '')
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll(':', '')
          .replaceAll('|', '');

      var downloadsDirectory = await getDownloadPath();
      var filePath = path.join(downloadsDirectory!, "$fileName.mp3");
      File file = File(filePath);

      if (file.existsSync()) {
        await file.delete();
      }

      final output = file.openWrite(mode: FileMode.writeOnlyAppend);

      final len = audio.size.totalBytes;
      var count = 0;
      var prevProgress = 0;

      await for (final data in audioStream) {
        count += data.length;

        final progress = ((count / len) * 100).ceil();
        if (progress - prevProgress >= 1) {
          prevProgress = progress;
          setState(() {
            downProgress = progress.toDouble();
          });
        }

        output.add(data);
      }

      await output.close();

      setState(() {
        isLoading = false;
        succes = true;
        songPath = filePath;
        completed = true;
      });
      _audioQuery.scanMedia(filePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).succes),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        error = true;
        succes = false;
        completed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failed),
        ),
      );
    }
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      Exception(err);
    }
    return directory?.path;
  }

  Future<void> requestPermission() async {
    await Permission.storage.request();
  }

  Future<bool> _onWillPop() async {
    if (completed)
      return true;
    else
      return (await showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text(AppLocalizations.of(context).youSure),
              content: new Text(AppLocalizations.of(context).stopDownload),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text(AppLocalizations.of(context).no),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: new Text(AppLocalizations.of(context).yes),
                ),
              ],
            ),
          )) ??
          false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (completed)
                    Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.close))),
                  const Spacer(),
                  Text(
                    "${titleParser(video.title)}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  if (succes)
                    ClipOval(
                      child: Material(
                        color:
                            Colors.greenAccent.withOpacity(0.2), // button color
                        child: InkWell(
                          splashColor: Colors.greenAccent
                              .withOpacity(0.6), // inkwell color
                          child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.greenAccent,
                              )),
                          onTap: () async {
                            if (songPath.isNotEmpty) {
                              await OpenFile.open(songPath);
                            }
                          },
                        ),
                      ),
                    ),
                  if (error)
                    ClipOval(
                      child: Material(
                        color:
                            Colors.redAccent.withOpacity(0.2), // button color
                        child: InkWell(
                          splashColor: Colors.redAccent
                              .withOpacity(0.6), // inkwell color
                          child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(
                                Icons.close,
                                color: Colors.redAccent,
                              )),
                          onTap: () {},
                        ),
                      ),
                    ),
                  if (!succes)
                    if (!isLoading)
                      ClipOval(
                        child: Material(
                          color: primaryColor.withOpacity(0.2), // button color
                          child: InkWell(
                            splashColor:
                                primaryColor.withOpacity(0.6), // inkwell color
                            child: const SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.download,
                                  color: primaryColor,
                                )),
                            onTap: () {
                              download2(video.id.toString(), video.title);
                            },
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CircularProgressIndicator(
                          value: downProgress * 0.01,
                          //color: primaryColor,
                          backgroundColor: primaryColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: _onWillPop,
    );
  }
}
