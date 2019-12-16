import 'package:http/http.dart' as http;

class HtmlApi {
  final String url;

  String responseBody;

  bool _fetched = false;

  HtmlApi(this.url);

  bool hasErrors = false;

  String errorMessage;

  Future<List<Map<String, dynamic>>> parse(SearchPattern container) async {

    hasErrors = false;

    List<Map<String, dynamic>> result = List<Map<String, dynamic>>();

    if (!_fetched) {
      var response = await http.get(this.url);

      this.responseBody = response.body;

      _fetched = true;
    }

    int startIndex = 0;
    int endIndex = 0;

    for (String search in container.containerStartEnd.searchStart) {
      startIndex = this.responseBody.indexOf(search, startIndex);
      if (startIndex == -1) {
        hasErrors = true;
        errorMessage = "pattern not found";
        return null;
      }
      startIndex = startIndex + search.length;
    }


    endIndex = this.responseBody.indexOf(container.containerStartEnd.searchEnd, startIndex);
    if (endIndex == -1) {
      hasErrors = true;
      errorMessage = "pattern not found";
      return null;
    }

    String containerToSearch = this.responseBody.substring(startIndex, endIndex);

    startIndex = 0;
    endIndex = 0;

    while (startIndex > -1) {
      Map<String, dynamic> rowResult = Map<String, dynamic>();
      bool rowResultInitiated = false;
      for (StartEndPair searchRow in container.dataSet) {
        for (String search in searchRow.searchStart) {
          startIndex = containerToSearch.indexOf(search, startIndex);
          if (startIndex == -1) {
            break;
          }
          //startIndex = startIndex + search.length;
        }
        if (startIndex == -1) {
          break;
        }
        endIndex = containerToSearch.indexOf(searchRow.searchEnd, startIndex);
        if (endIndex == -1) {
          break;
        }
        rowResult[searchRow.name] = containerToSearch.substring(startIndex, endIndex);
        //startIndex = endIndex;
        rowResultInitiated = true;
      }
      if (rowResultInitiated) {
        result.add(rowResult);
      }
    }

    return result;
  }
}

class SearchPattern {
  StartEndPair containerStartEnd;
  List<StartEndPair> dataSet;

  SearchPattern({
    this.containerStartEnd,
    this.dataSet
  });
}

class StartEndPair {
  String name;
  List<String> searchStart;
  String searchEnd;

  StartEndPair({
    this.name,
    this.searchStart,
    this.searchEnd
  });
}