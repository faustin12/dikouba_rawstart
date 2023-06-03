import 'package:flutter/material.dart';
//import 'package:google_map_location_picker/generated/l10n.dart' as location_picker;
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/AppThemeNotifier.dart';
import 'package:dikouba_rawstart/activity/splashscreen_activity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:firebase_performance/firebase_performance.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() {
  //runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    await Firebase.initializeApp();

    //await NotificationService().init(); //
    //await NotificationService().requestIOSPermissions(); //

    runApp(ChangeNotifierProvider<AppThemeNotifier>(
      create: (context) => AppThemeNotifier(),
      child: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {
  //Navigator Key for onWillPop on Home Activity
  static GlobalKey<NavigatorState> HomeNavigatorKey = new GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> AgendaNavigatorKey = new GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> MapNavigatorKey = new GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> LiveNavigatorKey = new GlobalKey<NavigatorState>();

  //Trace for firebase Performance
  static Trace getAllEventServer = FirebasePerformance.instance.newTrace("GetAllEventServerTime");
  static Trace likeEvent = FirebasePerformance.instance.newTrace("GetAllEventServerTime");
  static Trace unLikeEvent = FirebasePerformance.instance.newTrace("GetAllEventServerTime");
  static Trace favorisEvent = FirebasePerformance.instance.newTrace("GetAllEventServerTime");
  static Trace unFavorisEvent = FirebasePerformance.instance.newTrace("GetAllEventServerTime");
  static Trace findUserEventLikes = FirebasePerformance.instance.newTrace("GetAllEventServerTime");
  static Trace findUserEventFavoris = FirebasePerformance.instance.newTrace("GetAllEventServerTime");
  /*static Trace getAllEventServer = FirebasePerformance.instance.newTrace("GetAllEventServerTime");
  static Trace getAllEventServer = FirebasePerformance.instance.newTrace("GetAllEventServerTime");
  static Trace getAllEventServer = FirebasePerformance.instance.newTrace("GetAllEventServerTime");
  */
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);


  @override
  Widget build(BuildContext context) {

    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        /*UserModel userModel = new UserModel(
        nbre_followers: '0',
            id_users: 'NekuDL6WO6eiX08LY8jmiUCkIot2',
            email: 'youmsijunior@gmail.com',
            nbre_following: '0',
            name: 'ROMUALD JUNIOR YOUMSI MOUMBE',
            password: 'NekuDL6WO6eiX08LY8jmiUCkIot2',
            photo_url: 'https://lh3.googleusercontent.com/a-/AOh14GghjI3-geYdM4kHUOllmG39EUQBabouB9mjnUMQFw=s96-c',
            email_verified: 'true',
            phone: '',
            password_hash: 'TmVrdURMNldPNmVpWDA4TFk4am1pVUNrSW90Mg==',
            uid: 'NekuDL6WO6eiX08LY8jmiUCkIot2'

        );*/
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            /*localizationsDelegates: const [
              location_picker.S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],*/
            supportedLocales: const <Locale>[
              Locale('en', ''),
              Locale('fr', ''),
            ],
            // home: RegisterActivity(userModel: userModel),);
            navigatorObservers: <NavigatorObserver>[observer],
            home: SplashScreen(
              analytics: analytics,
              observer: observer,
            ));
      },
    );
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  /*const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }*/
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
