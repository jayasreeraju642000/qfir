import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/utils/log_printer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/main_model.dart';
import '../widgets/widget_common.dart';

final log = getLogger('NewsPage');

class NewsPage extends StatefulWidget {
  
  final MainModel model;

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  NewsPage(this.model, {this.analytics, this.observer});
  
  @override
  State<StatefulWidget> createState() {
    return _NewsPageState();
  }
}

class _NewsPageState extends State<NewsPage> {
	_NewsPageState();

	Widget _progressHUD;

	List<Map<String, dynamic>> newsData = [];

	Future<Null> _currentScreen() async {
		await widget.analytics.setCurrentScreen(
			screenName: 'News Page', screenClassOverride: 'NewsPage');
	}

	Future<Null> _addEvent() async{
		await widget.analytics.logEvent(
			name: "page_change",
			parameters: <String, dynamic>{
				"pageName": "News page",
			}
		);
	}


	void initState() { 
		super.initState();
		_currentScreen();
		_progressHUD = new Center(
			child: new CircularProgressIndicator(),
		);
		log.i('requesting fetch news and tweets');
		
		//widget.model.fetchNews();
		//widget.model.fetchTweets();
		
	}

	Future<Null> loadNews() async{
		//newsData = widget.model.fetchNews();
	}

  	@override
	Widget build(BuildContext context) {
		return ScopedModelDescendant<MainModel>(
			builder: (BuildContext context, Widget child, MainModel model){
				_addEvent();
				return DefaultTabController(
					length: 4,
					child: Scaffold(
						drawer: WidgetDrawer(),
						appBar: newsAppBar(context, model),
						body: _buildBody(),
						bottomNavigationBar: widgetBottomNavBar(context, 4)
					),
				);
				
			}
		);

	}

  Widget _buildBody() {
    if (widget.model.isLoading) {
      return _progressHUD;
    } else {
      return TabBarView(
        children: [
          _buildNews(context),
          _buildTweet(context),
        ],
      );
    }
  }

  Widget _buildNews(BuildContext context){
    List listNews = widget.model.newsData;
    return
      Container(
        child:
          ListView.builder(
              itemCount: listNews.length,
              itemBuilder: (context, index) {
                  News newsData = listNews[index];
                  return
                   GestureDetector(
                    onTap: (){
                      _launchURL(newsData.url);
                      /* Navigator.pushNamed(context, '/basket/' + index.toString()); */
                    },
                    child:
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        child: 
                          _buildNewsItem(context, index, newsData)
                      )
                   ); 
              }
            )
      );
  }

  Widget _buildNewsItem(BuildContext context, int index, News newsData) {
    return Card(
      color: Colors.white,
      child: 
      Container(
        child: 
        Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5.0),
                child:
                  /* widgetCacheImage(context, basketData.image, 60.0) */
                 Image.network(
                  newsData.image,
                  width: 60.0,
                )
              ),
              Expanded(
                child: 
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[    
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          
                          children: <Widget>[
                            Expanded(
                              child:  Container(
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text(
                                newsData.title,
                                softWrap: true,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),),
                            ),
                            
                          ],
                        ),
                        SizedBox(height: 3.0),
                       
                        Container(
                          margin: EdgeInsets.only(left: 10.0),
                          child: 
                            Row(children: <Widget>[
                              Text(
                                newsData.source,
                                overflow: TextOverflow.clip,
                                softWrap: true, 
                                textAlign: TextAlign.left,

                                style: TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.grey,
                                  height: 1.1
                                
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20.0),
                                child:Text(
                                      newsData.date_published,
                                      overflow: TextOverflow.clip,
                                      softWrap: true, 
                                      textAlign: TextAlign.left,

                                      style: TextStyle(
                                        fontSize: 11.0,
                                        color: Colors.grey,
                                        height: 1.1
                                      
                                      ),
                                    ),
                              ),
                            ],),
                          
                        ),
                       
                        Container(
                          margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                          child: Container()
                          
                        ),
                      ],
                    ),
              ),
            ],
          ) ,
        ],
      ),
         
      )
      
    );
  }


  Widget _buildTweet(BuildContext context){
    List listTweets = widget.model.tweetData;
    return
      Container(
        child:
          ListView.builder(
              itemCount: listTweets.length,
              itemBuilder: (context, index) {
                  Tweet tweetData = listTweets[index];
                  return
                   GestureDetector(
                    onTap: (){
                      _launchURL(tweetData.url);
                    },
                    child:
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        child: 
                          _buildTweetItem(context, index, tweetData)
                      )
                   ); 
              }
            )
      );
  }

  Widget _buildTweetItem(BuildContext context, int index, Tweet tweetData) {
    return Card(
      color: Colors.white,
      child: 
      Container(
        child: 
        Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5.0),
                child:
                  /* widgetCacheImage(context, basketData.image, 60.0) */
                  
                 Image.asset(
                  'assets/images/icon_twitter.png',
                  width: 30.0,
                )
              ),
              Expanded(
                child: 
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[    
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          
                          children: <Widget>[
                            Expanded(
								child:  Container(
									margin: EdgeInsets.only(left: 10.0),
									padding: EdgeInsets.only(top: 5.0),
									child: Text(
										tweetData.tweet,
										softWrap: true,
										textAlign: TextAlign.left,
										style: TextStyle(
										fontSize: 12.0,
										fontWeight: FontWeight.normal,
										color: Theme.of(context).primaryColor,
										),
									),
								),
                            ),
                            
                          ],
                        ),
                        SizedBox(height: 3.0),
						Container(
							margin: EdgeInsets.only(left: 10.0),
							child:Text(
								tweetData.date_published,
								overflow: TextOverflow.clip,
								softWrap: true, 
								textAlign: TextAlign.left,

								style: TextStyle(
								fontSize: 11.0,
								color: Colors.grey,
								height: 1.1
								
								),
							),
						),
                        SizedBox(height: 5.0),
                       
                      ],
                    ),
              ),
            ],
          ) ,
        ],
      ),
         
      )
      
    );
  }


  
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  

}