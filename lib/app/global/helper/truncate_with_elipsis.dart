String truncateWithEllipsis(int cutoff, String text) {
  return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
}
