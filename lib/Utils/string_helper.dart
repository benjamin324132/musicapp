String durationToString(Duration? duration) {
  String hour = twoDigits(duration?.inHours);
  String minute = twoDigits(duration?.inMinutes.remainder(60));
  String second = twoDigits(duration?.inSeconds.remainder(60));

  if (hour == "00") {
    return minute + ':' + second;
  } else {
    return hour + ':' + minute + ':' + second;
  }
}

String twoDigits(int? n) => n.toString().padLeft(2, '0');

String titleParser(String title) {
  return title
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll('[', '')
      .replaceAll(']', '')
      .replaceAll('video', '')
      .replaceAll('Video', '')
      .replaceAll('Official', '')
      .replaceAll('official', '')
      .replaceAll('Audio', '')
      .replaceAll('audio', '')
      .replaceAll('Playlist', '')
      .replaceAll('playlist', '')
      .replaceAll('Lyrics', '')
      .replaceAll('lyrics', '')
      .replaceAll('Lyric', '')
      .replaceAll('lyric', '')
      .replaceAll('Music', '')
      .replaceAll('music', '');
}
