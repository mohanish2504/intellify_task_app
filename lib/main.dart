import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';

void main() {
  runApp(Searchbar());
}

class Searchbar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Searchbarstate();
  }

}

class Searchbarstate extends State<Searchbar> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red
      ),
        home: Body()
    );
  }
}

class Body extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BodyState()  ;
  }
}

class BodyState extends State<Body>{



  Future<List<Item>> search(String query) async {
    final dioLocation = Dio(BaseOptions(
        baseUrl: 'https://developers.zomato.com/api/v2.1/locations',
        headers: {
          'user-key': '1b3c8b37ea96785391fa55c288ac385c'
        }
    ));
    var response = await dioLocation.get(
        '',
        queryParameters: {
          'query':query
        }
    );
    var locations_suggestion = response.data["location_suggestions"];
    final dioRestaurantList = Dio(BaseOptions(
        baseUrl: 'https://developers.zomato.com/api/v2.1/search',
        headers: {
          'user-key': '1b3c8b37ea96785391fa55c288ac385c'
        }
    ));
    response = await dioRestaurantList.get(
        '',
        queryParameters:{
          'entity_id':locations_suggestion[0]["entity_id"],
          'entity_type':locations_suggestion[0]["entity_type"]
        }
    );
    var restaurants = [];
    restaurants = response.data['restaurants'];
    //print(restaurants.length);
    List<Item> restaurantItems = [];
    for(dynamic restaurant in restaurants){
      restaurantItems.add(new Item(restaurant));
    }
    //print(restaurantItems.length);

    return restaurantItems;

  }
  SearchBarController searchBarController = new SearchBarController();
  Widget Thumbnail(String thumbnail){
    String defaultThumb = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTt0TZq80UynlOQTDV-_N1P1X_1cKuHxRBEGw&usqp=CAU";
    Widget image = Image.network(defaultThumb);
    if(thumbnail.isNotEmpty)image = Image.network(thumbnail);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: image,
    );
  }
  Widget makeTile(Item item){
    String title = item.restaurantDetails['restaurant']['name'];
    String thumbnail = item.restaurantDetails['restaurant']['thumb'];
    String location = ' ${item.restaurantDetails['restaurant']['location']['locality']}';
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height*0.085,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Thumbnail(thumbnail),
          Container(
            margin: EdgeInsets.only(top:1,left: 3),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:<Widget>[
                  Text(title,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                  Text(location,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500,color: Colors.grey))
                ]
            ),
          )

        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar<Item>(
            hintText: 'Search restaurants in your locality',
            onSearch: search,
            onItemFound: (Item item, int index) {
              if(item==null)return Center(child: Text('Sorry no restaurants available in this area!'),);
              return makeTile(item);
            },
            loader: Center(child:CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),)),
            listPadding: EdgeInsets.all(2),
            mainAxisSpacing: 7.5,
          ),
        ),
      ),
    );// T
  }

}

class Item {
  dynamic _restaurantDetails;
  Item(this._restaurantDetails);

  dynamic get restaurantDetails => _restaurantDetails;
}