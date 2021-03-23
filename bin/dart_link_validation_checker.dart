#! /usr/bin/env dcli.bat

import 'package:dcli/dcli.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

void main() async {
  print('\n\n**Welcome!!**\n\n');

  var username = ask('Enter username', defaultValue: 'utkarshshendge');
  var projName = ask(
    'Please Enter name of project',
  );
  var fileName = ask(
    'Please enter markdown file name',
  );
  var branchName = ask('Please enter branch Name', defaultValue: 'master');
  var rawLink = 'https://raw.githubusercontent.com/' +
      username +
      '/' +
      projName +
      '/' +
      branchName +
      '/' +
      fileName;
  print('Getting links from ' + rawLink + '...');
  var markDownText = await _getDataFromWeb(rawLink);
  if (markDownText != null) {
    var links = getLinks(markDownText);
    links.isNotEmpty
        ? checkLinkValidity(links)
        : print('Thanks for trying out!!');
  }
}

Future<String> _getDataFromWeb(String linkString) async {
  final response = await http.get(linkString);
  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    var linkElem = document.documentElement.innerHtml;

    return linkElem;
  } else {
    print('Cannot load data from   ' + linkString);
    return null;
  }
}

Iterable<String> getLinks(String text) {
  var re = RegExp(
      r'(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?');
  var match = re.allMatches(text).map((m) => m[0]);
  print('\nFound ${match.length} Links\n');
  return match;
}

void checkLinkValidity(Iterable<String> links) {
  links.forEach((element) async {
    final response = await http.head(element);
    if (response.statusCode != 200) {
      print(element + ' Link is Broken');
    } else {
      print(element + ' Link is Fine');
    }
  });
}
