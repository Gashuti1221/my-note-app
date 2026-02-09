import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/database_service.dart';
import '../widgets/note_card.dart';
import 'create_note_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/constants.dart';

class NotesListScreen extends StatefulWidget {
  final DatabaseService dbServices;

  const NotesListScreen({
    super.key,
    required this.dbServices,
  });

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> allNotes = [];
  List<Note> filteredNotes = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final fetchedNotes = await widget.dbServices.getNotes();

    fetchedNotes.sort((a, b) {
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;
      return 0; // maintain original order otherwise (creation time usually)
    });

    setState(() {
      allNotes = fetchedNotes;
      filteredNotes = fetchedNotes;
      isLoading = false;
    });
  }

  void showInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(), // Spacer
                    const Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 28),
                        SizedBox(height: 8),
                        Text(
                          "About Teshiet\nNotes",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Teshiet Notes is a simple yet powerful note-taking app designed for productivity.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Features",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildFeatureItem(Icons.edit, "Create & Edit Notes"),
                _buildFeatureItem(Icons.palette, "Color Coding"),
                _buildFeatureItem(Icons.label, "Tags"),
                _buildFeatureItem(Icons.push_pin, "Pin Notes"),
                _buildFeatureItem(Icons.search, "Search"),
                _buildFeatureItem(Icons.brightness_6, "Dark/Light Mode"),
                _buildFeatureItem(Icons.picture_as_pdf, "PDF Export"),
                const SizedBox(height: 20),
                const Text(
                  "How to Use",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildUsageItem("Tap + button to create new note"),
                _buildUsageItem("Tap any note to view/edit"),
                _buildUsageItem("Long-press note for options"),
                _buildUsageItem("Use search bar to find notes"),
                _buildUsageItem("Toggle theme using theme icon"),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.lightBlue.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "PDF Export",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Long-press any note → Share as PDF → Send to Telegram or any app",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Developer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildDeveloperItem(
                    Icons.person, "Developed by Gashu and Haile"),
                _buildDeveloperItem(Icons.email, "haile_gashu@gmail.com"),
                _buildDeveloperItem(Icons.verified, "Version 1.0.0"),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Made with ❤️",
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEE5F4),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildDeveloperItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  void searchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredNotes = allNotes.where((note) {
        return note.title.toLowerCase().contains(lowerQuery) ||
            note.content.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use theme's scaffoldBackgroundColor (defined in ThemeProvider)
      // backgroundColor: const Color(0xFFF8F4F9),
      body: CustomScrollView(
        slivers: [
          buildSliverAppBar(),
          buildSearchBarSliver(),
          buildBodySliver(),
        ],
      ),
      floatingActionButton: buildFABs(),
    );
  }

  // ---------------- APP BAR ----------------
  SliverAppBar buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: showInfoDialog,
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "Teshiet Notes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [Colors.grey[900]!, Colors.grey[850]!]
                  : [const Color(0xFF9D8DF1), const Color(0xFFB39DDB)],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SEARCH BAR ----------------
  Widget buildSearchBarSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: searchController,
          onChanged: searchNotes,
          decoration: InputDecoration(
            hintText: "Search notes...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- BODY SLIVER ----------------
  Widget buildBodySliver() {
    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (filteredNotes.isEmpty) {
      return SliverFillRemaining(
        child: buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = filteredNotes[index];
            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateNoteScreen(
                      dbService: widget.dbServices,
                      note: note,
                    ),
                  ),
                );
                fetchNotes();
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Note Options",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          "Choose an action for this note",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // PIN ACTION
                        ListTile(
                          leading:
                              const Icon(Icons.push_pin, color: Colors.blue),
                          title:
                              Text(note.pinned ? "Unpin Notes" : "Pin Notes"),
                          onTap: () async {
                            Navigator.pop(context);
                            final updatedNote = Note(
                              id: note.id,
                              title: note.title,
                              content: note.content,
                              color: note.color,
                              tags: note.tags,
                              pinned: !note.pinned,
                            );
                            await widget.dbServices.updateNote(updatedNote);
                            fetchNotes();
                          },
                        ),
                        // SHARE LINK
                        ListTile(
                          leading:
                              const Icon(Icons.share, color: Colors.purple),
                          title: const Text("Share Link"),
                          onTap: () async {
                            Navigator.pop(context);

                            // Use constants for backend URL
                            const String backendUrl = AppConstants.backendUrl;
                            final String shareUrl =
                                "$backendUrl/share/${note.id}";

                            // Use ShareParams instead of plain String
                            await SharePlus.instance.share(
                              ShareParams(
                                text: "Check out this note: $shareUrl",
                                subject:
                                    "Shared Note", // optional, can be removed
                              ),
                            );
                          },
                        ),

                        // EXPORT PDF
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf,
                              color: Colors.orange),
                          title: const Text("Export as PDF"),
                          onTap: () async {
                            Navigator.pop(context);
                            await PdfService().exportNoteToPdf(note);
                          },
                        ),
                        // DELETE ACTION
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text("Delete Note"),
                          onTap: () async {
                            Navigator.pop(context);
                            await widget.dbServices.deleteNote(note.id);
                            fetchNotes();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: NoteCard(note: note),
            );
          },
          childCount: filteredNotes.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3 / 4,
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.note_add_outlined, size: 80, color: Colors.grey),
        SizedBox(height: 20),
        Text(
          "Until now there is no notes/documents",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          "To create notes click the + button",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "info",
          onPressed: showInfoDialog,
          child: const Icon(Icons.info_outline),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "add",
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateNoteScreen(dbService: widget.dbServices),
              ),
            );
            fetchNotes();
          },
        ),
      ],
    );
  }
}
