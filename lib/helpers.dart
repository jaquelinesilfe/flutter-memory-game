String timeFormat(int second) {
  final dur = Duration(seconds: second);

  return dur.inMinutes.remainder(60).toString().padLeft(2, '0') +
      ':' +
      dur.inSeconds.remainder(60).toString().padLeft(2, '0');
}
