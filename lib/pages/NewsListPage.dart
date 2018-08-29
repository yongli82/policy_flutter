import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:policy_collection/Api.dart';
import 'package:policy_collection/util/NetUtils.dart';

class NewsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new NewsListPageState();
  }
}

class NewsListPageState extends State<NewsListPage> {
  var listData;
  var curPage = 0;
  var isEnd = false;

  TextStyle titleTextStyle = new TextStyle(fontSize: 15.0);
  TextStyle subtitleStyle =
      new TextStyle(color: Colors.black45, fontSize: 12.0);
  TextStyle summaryTextStyle =
      new TextStyle(color: Colors.black12, fontSize: 12.0);
  ScrollController _controller = new ScrollController();

  NewsListPageState() {
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll >= pixels && !isEnd) {
        // scroll to bottom, get next page data
        curPage++;
        getNewsList(true);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getNewsList(false);
  }

  getNewsList(bool isLoadMore) {
    String url = Api.BASE_URL +
        "/api/policy-articles/search?page=$curPage&size=10&query=&sort=publishTime,desc&sort=id,desc";
    NetUtils.get(url).then((data) {
      List dataList = json.decode(data);
      if (dataList != null && dataList.length > 0) {
        setState(() {
          if (isLoadMore) {
            List totalList = new List();
            totalList.addAll(listData);
            totalList.addAll(dataList);
            listData = totalList;
          } else {
            listData = dataList;
          }
        });
      } else {
        isEnd = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (listData == null) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      Widget listView = new ListView.builder(
        itemCount: listData.length,
        itemBuilder: (context, i) => renderRow(i),
        controller: _controller,
      );
      return new RefreshIndicator(child: listView, onRefresh: _pullToRefresh);
    }
  }

  Widget renderRow(int i) {
    if (i > listData.length) {
      return new Divider();
    }
    var itemData = listData[i];
    print(itemData);

    var summary = "";
    var textContent = itemData["textContent"];
    if (null != textContent) {
      if (textContent.length > 100) {
        summary = textContent.substring(0, 100);
      } else {
        summary = textContent;
      }
    }

    var publishDay = "";
    var publishTime = itemData["publishTime"];
    if (null != publishTime && publishTime.length >= 10) {
      publishDay = publishTime.substring(0, 10);
    }

    var inkWell = new InkWell(
      child: new Column(
        children: <Widget>[
          new Row(children: <Widget>[
            new Container(
              width: 20.0,
              height: 20.0,
              child: const Icon(
                Icons.account_balance,
                size: 18.0,
              ),
            ),
            new Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
              child:
                  new Text(itemData["site"]["siteName"], style: subtitleStyle),
            )
          ]),
          new Row(
            children: <Widget>[
              new Container(
                width: 20.0,
                height: 20.0,
                child: const Icon(
                  Icons.access_time,
                  size: 18.0,
                ),
              ),
              new Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                child: new Text(publishDay, style: subtitleStyle),
              ),
            ],
          ),
          new Divider(
            height: 1.0,
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                  child: new Text(itemData["title"], style: titleTextStyle)),
            ],
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                  child: new Text(
                summary,
                style: titleTextStyle,
                softWrap: true,
              )),
            ],
          ),
        ],
      ),
    );

    var card = new Card(
      child: inkWell,
      margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
    );
    return card;
  }

  Future<Null> _pullToRefresh() async {
    curPage = 0;
    getNewsList(false);
    isEnd = false;
    return null;
  }
}
