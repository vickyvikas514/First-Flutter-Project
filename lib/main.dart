import 'dart:html';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Your App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 185, 34, 255)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  //to remembering last elements
  var history = <WordPair>[];


//Normally, flutter will not use Global Keys.
// When you create a stateful widget, two object get created: 
//a widget, and it's state. The idea is that
// the widget itself will be destroyed at the end of the build 
//(or after it is painted on the screen).
  GlobalKey?historyListKey;



  void getNext() {
    //filling the history element
    history.insert(0,current);


    //more or less introducing animation
    //AnimatedListState Widget is the state for a scrolling container that animates items 
    //when they are inserted or removed.
    // When an item is inserted with insertItem an animation begins running.
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);

    current = WordPair.random();
    //notify listner, tell all other objects about the change happening in this context
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair?pair]) {
    pair = pair??current;

    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  void RemoveFavorite(WordPair Element){
    favorites.remove(Element);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  //myhome page se _MyHomePage (nicche hai)waali widget pe jaayega.\
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
   @override
   //dusre page pe phochatha hai\\
  Widget build(BuildContext context) {
Widget page;
switch (selectedIndex) {
  case 0:
    page = GeneratorPage();
    break;
  case 1:
    page = FavoritesPage();
    break;
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}
//LayoutBuilder. It lets you change your 
//widget tree depending on how much available space you have.
    return LayoutBuilder(
      builder: (context,Constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: Constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  //shade ko icon pe rok dea hai
                  onDestinationSelected: (value) {

                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  //new page added
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    //contain Icon's Data whether heart is filled or not
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    //adding text styling
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      //color same as app's schema.
      color: theme.colorScheme.primary,

      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(pair.asLowerCase
        ,style: style
        ,semanticsLabel: pair.asPascalCase),
      ),
    );
  }
}

//page for favorite words.
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),


        for (var pair in appState.favorites)
        //this for loop create each line
        //List Title provide structure for each line.

        //if we want to add anything to favorites word line
        // we have to done here under ListTitle like Remove button
          ListTile(
            leading: IconButton(icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
            onPressed: (){
              appState.RemoveFavorite(pair);
            },),

            title: Text(
              pair.asPascalCase,
              
            ),
          ),
      ],
    );
  }
}


/*practice page 
class PracticePage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();
    if(appState.favorites.isEmpty){
      return Center(
        child: Text('No favorites yet'),
      );
    } return ListView(
      children: [
        Padding(padding: const EdgeInsets.all(20),
        child: Text('You got'
        '${appState.favorites.length} favorites:'),
        ),
        for(var pair in appState.favorites)
        //this for loop create each line
        //List Title provide structure for each line.
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text(pair.asPascalCase),
        )
      ],
    )

  }

}*/





























































