class ListState<T> {
  List<T> rows;
  bool isRefreshing;
  bool isPendingNext;
  bool hasError;
  String errorMessage;

  ListState() {
    rows = new List<T>();
    this.isRefreshing = false;
    this.isPendingNext = false;
    this.hasError = false;
    this.errorMessage = "";
  }
}