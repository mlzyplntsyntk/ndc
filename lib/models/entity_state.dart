class EntityState<T> {
  T row;
  bool isRefreshing;
  bool isPendingNext;
  bool hasError;
  String errorMessage;

  EntityState() {
    row = null;
    this.isRefreshing = false;
    this.isPendingNext = false;
    this.hasError = false;
    this.errorMessage = "";
  }
}