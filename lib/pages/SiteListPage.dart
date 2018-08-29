import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:policy_collection/util/NetUtils.dart';

class SiteListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SiteListPageState();
  }
}

class SiteListPageState extends State<SiteListPage> {
  var listData;
  var curPage = 0;
  var isEnd = false;

  ScrollController _controller = new ScrollController();
  TextStyle titleTextStyle = new TextStyle(fontSize: 15.0);
  TextStyle subtitleStyle =
      new TextStyle(color: const Color(0xFFB5BDC0), fontSize: 12.0);
  TextStyle summaryTextStyle =
      new TextStyle(color: const Color(0x88B5BDC0), fontSize: 12.0);

  SiteListPageState() {
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll >= pixels && !isEnd) {
        // scroll to bottom, get next page data
        curPage++;
        print("curPage=$curPage");
        getSiteList(true);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getSiteList(false);
  }

  getSiteList(bool isLoadMore) {
    var url =
        "http://policy.codeessay.com/api/site-configs/query?page=$curPage&size=20&query=&sort=siteGroup,asc&sort=siteName,asc";
    NetUtils.get(url).then((data) {
      List dataList = json.decode(data);
      print(dataList);
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
    var inkWell = new InkWell(
      child: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Container(
                width:20.0,
                height: 20.0,
                child: const Icon(Icons.account_balance, size: 18.0,),
              ),
              new Container(
                height: 20.0,
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: new Text(itemData["siteGroup"], style: subtitleStyle),
                decoration: new BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: new BorderRadius.all(
                    const Radius.circular(6.0),
                  ),
                ),
              )
            ],
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Text(itemData["siteName"], style: titleTextStyle),
              )
            ],
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                  child: new Text(
                itemData["domainUrl"],
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
    getSiteList(false);
    isEnd = false;
    return null;
  }
}
