extension Initials on String {
  String computeInitials() {
    if (length == 0) {
      return this;
    }
    final tokens = split(" ").take(2).map((t) => t[0].toUpperCase());
    return tokens.join();
  }
}
