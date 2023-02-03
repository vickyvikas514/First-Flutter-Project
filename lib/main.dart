import 'dart:html';
import 'dart:io';
import 'dart:ui';

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
    //this colorSheme we build to use in animation
    var colorScheme = Theme.of(context).colorScheme;
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

 // The container for the current page, with its background color
    // and subtle switching animation.

    //ColoredBox creates widget which paints its area with specified color.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,

      
      //AnimatedSwitcher is a widget that can be used for 
      //creating animation when switching between two widgets. 
      //When a widget is replaced with another,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

//LayoutBuilder. It lets you change your 
//widget tree depending on how much available space you have.
   return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [

                
                //Expanded widget in flutter comes in handy when we want a child widget or children widgets to 
                //take all the available space along the main-axis
                // (for Row the main axis is horizontal & vertical for Column ). 
                //Expanded widget can be taken as the child of Row, Column, and Flex.
                Expanded(child: mainArea),
                //provide area for forming widgets 
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favorites',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    //if width is <600 then names are hide
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      //side waala bar
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
                    //shade ko icon pe rok deta hai.
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                //expanded is child of row
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
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
        //centre main alling karne ke liye
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3
            ,
            child: HistoryListView(),
            ),

          SizedBox(height: 10),
          BigCard(pair: pair),
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
          //Spacer creates an adjustable, empty spacer that can be used to
          // tune the spacing between widgets in a Flex container, like
          // Row or Column. The Spacer widget will take up any available space, so 
          //setting the Flex. mainAxisAlignment on a flex container that contains a Spacer to MainAxisAlignment.
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

//dibba jisme word dikhthe hai.
class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);
// the final keyword will be initialized at runtime and
// can only be assigned for a single time
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
        //dibba apna size change karega through animation
        child: AnimatedSize(duration: Duration(milliseconds: 200),
        //MergeSemantics merge all its desendents to the 
        //main root or itnital components
        child: MergeSemantics(
          child: Wrap(
            children: [
              Text(
                pair.first,
                style: style.copyWith(fontWeight: FontWeight.w200),
              ),
              Text(
                //text ko bold kar raha hai.
                pair.second,
                style:style.copyWith(fontWeight: FontWeight.bold),
              )
            ],
          ) ,
          ),
        ),
      ),
    );
  }
}

//page for favorite words.
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //app ki theme lagai jaa rahi hai
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      //perpendicular axis
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          //saari edges ki padding
          padding: const EdgeInsets.all(30),
          child: Text('You have'
          '${appState.favorites.length} favorites'),
          ),
          Expanded(
            //grid banai hai jisme words store honge.
            child: GridView(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 400/80,
                ) ,
                //grid mai delete ke button banaye hai
                children: [
                  for(var pair in appState.favorites)
                  ListTile(
                    leading: IconButton(icon: Icon(Icons.delete_outline,
                    semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary,
                    onPressed: (){
                      appState.RemoveFavorite(pair);
                    },
                    ),
                    title: Text(
                      pair.asLowerCase,
                      semanticsLabel: pair.asPascalCase,
                    ),
                  )
                ],
              )
            )
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

class HistoryListView extends StatefulWidget{
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();

}
 class _HistoryListViewState extends State<HistoryListView>{
  //  /// Needed so that [MyAppState] can tell [AnimatedList] below to animate
  /// new items.
  final _key = GlobalKey();

  //used to fade out the words
  static const Gradient _maskingGradient = LinearGradient(
    // // This gradient goes from fully transparent to fully opaque black..
    colors: [Colors.transparent,Colors.black],
    // ... from the top (transparent) to half (0.5) of the way to the bottom.
    stops: [0.0,0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    
    );

    @override
    Widget build(BuildContext context){
      final appState = context.watch<MyAppState>();
      appState .historyListKey = _key;
//ShaderMask is a widget that applies a mask generated by a shader to its child
//dont know much
      return ShaderMask(
        
        shaderCallback: ((bounds) => _maskingGradient.createShader(bounds)),
         // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      //animated list mai blend kiya jaa raha hai fading
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top:100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          
          return SizeTransition(
              sizeFactor: animation,
              child: Center(
                child: TextButton.icon(
                  onPressed: (){
                    appState.toggleFavorite(pair);
                  },
                   icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(), 
                   label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
                ),
                   ),
                );
          
        },
        ),
      ); 
      
      
    }
 }



























































