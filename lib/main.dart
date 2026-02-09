
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/telegram_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/database_service.dart';
import 'screens/notes_list_screen.dart';
import 'package:app_links/app_links.dart';
import 'models/note.dart';
import 'screens/create_note_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const firebaseDatabaseUrl =
      "https://prime-art-eab7d-default-rtdb.firebaseio.com"; // Replace with DB URL
  final dbService = DatabaseService(baseUrl: firebaseDatabaseUrl);

  runApp(MyApp(dbService: dbService));
}

class MyApp extends StatefulWidget {
  final DatabaseService dbService;
  const MyApp({required this.dbService, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (err) {
      debugPrint('Failed to get initial link: $err');
    }

    // Listen for new links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'flutter-note-app') {
      // Case 1: flutter-note-app://note/<id> (host is 'note')
      if (uri.host == 'note' && uri.pathSegments.isNotEmpty) {
        final noteId = uri.pathSegments[0];
        _navigateToNote(noteId);
      }
      // Case 2: flutter-note-app://<host>/note/<id> (path starts with 'note')
      else if (uri.pathSegments.isNotEmpty) {
        if (uri.pathSegments[0] == 'note' && uri.pathSegments.length > 1) {
          final noteId = uri.pathSegments[1];
          _navigateToNote(noteId);
        }
      }
    }
  }

  Future<void> _navigateToNote(String noteId) async {
    // Fetch all notes to find the specific one
    try {
      final notes = await widget.dbService.getNotes();
      final note = notes.firstWhere(
        (n) => n.id == noteId,
        orElse: () => Note(
            id: '',
            title: 'Note not found',
            content: 'This note may have been deleted.',
            createdDate: DateTime.now(), 
            color: 0xFFFFFFFF,
            tags: [],
            pinned: false),
      );

      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => CreateNoteScreen(
            dbService: widget.dbService,
            note: note.id.isNotEmpty ? note : null, // Pass null if note not found to create new or show error? 
            // Actually CreateNoteScreen handles editing if note is passed. 
            // If not found, maybe show a snackbar or alert? 
            // For now let's open it. If ID is empty it acts as new note or we can handle "Note not found" as a read-only note.
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TelegramProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'GH-Note App',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: NotesListScreen(dbServices: widget.dbService),
          );
        },
      ),
    );
  }
}

