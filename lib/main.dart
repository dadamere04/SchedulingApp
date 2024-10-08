// main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase Initialized Successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'Scheduling App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'https://www.googleapis.com/auth/calendar',
  ],
);

class _MyHomePageState extends State<MyHomePage> {
  late calendar.CalendarApi _calendarApi;
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Sign-in aborted by user');
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final authenticatedClient = GoogleHttpClient({'Authorization': 'Bearer ${googleAuth.accessToken}'});
      _calendarApi = calendar.CalendarApi(authenticatedClient);
      print('Google Sign-In successful');
    } catch (error) {
      print('Error during Google Sign-In: $error');
    }
  }

  Future<void> _getEvents() async {
    try {
      var events = await _calendarApi.events.list('primary');
      print('Events: ${events.items}');
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> _createEvent() async {
    var event = calendar.Event()
      ..summary = 'New Task'
      ..description = 'A new task added to the schedule'
      ..start = calendar.EventDateTime(
          dateTime: DateTime.now().add(Duration(hours: 1)),
          timeZone: 'America/New_York')
      ..end = calendar.EventDateTime(
          dateTime: DateTime.now().add(Duration(hours: 2)),
          timeZone: 'America/New_York');

    try {
      var calendarId = 'primary';
      await _calendarApi.events.insert(event, calendarId);
      print('Event added successfully');
    } catch (e) {
      print('Error creating event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _handleGoogleSignIn,
              child: Text('Sign in with Google'),
            ),
            ElevatedButton(
              onPressed: _getEvents,
              child: Text('Get Events'),
            ),
            ElevatedButton(
              onPressed: _createEvent,
              child: Text('Create Event'),
            ),
            Text('$_counter'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  Future<http.Response> head(Object url, {Map<String, String>? headers}) {
    return _client.head(url as Uri, headers: _headers);
  }
}
