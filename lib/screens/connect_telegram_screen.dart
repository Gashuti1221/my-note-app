import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/telegram_provider.dart';

class ConnectTelegramScreen extends StatefulWidget {
  const ConnectTelegramScreen({super.key});

  @override
  State<ConnectTelegramScreen> createState() => _ConnectTelegramScreenState();
}

class _ConnectTelegramScreenState extends State<ConnectTelegramScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isSuccess = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _verifyConnection() async {
    final provider = context.read<TelegramProvider>();
    final username = _usernameController.text.trim();

    final success = await provider.connectChannel(username);

    if (success) {
      setState(() {
        _isSuccess = true;
      });
      // Show success message and wait briefly
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Telegram channel connected successfully."),
          backgroundColor: Colors.green,
        ),
      );

      // Close screen after short delay
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If successfully connected, we might want to just show success state or nothing if leaving
    if (_isSuccess) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 16),
              Text(
                "Connected!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect Telegram Channel"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        titleTextStyle: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      body: Consumer<TelegramProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Connect your Telegram channel to automatically receive notes from this app.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                if (provider.isConnected) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          "Connected to ${provider.connectedChannelName}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final shouldDisconnect = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Disconnect Telegram"),
                                  content: const Text(
                                    "Are you sure you want to disconnect your Telegram channel?\nNotes will no longer be sent to Telegram.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red),
                                      child: const Text("Disconnect"),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldDisconnect == true) {
                                await provider.disconnect();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Telegram disconnected successfully")),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.link_off, color: Colors.red),
                            label: const Text("Disconnect",
                                style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Text(
                    "Instructions:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep("1. Create a Telegram channel"),
                  _buildInstructionStep(
                      "2. Add @halaz21bot as an administrator"),
                  _buildInstructionStep(
                      "3. Allow the “Post Messages” permission"),
                  _buildInstructionStep("4. Enter your channel username below"),
                  _buildInstructionStep("5. Click Verify Connection"),
                  const SizedBox(height: 32),
                  const Text(
                    "Telegram Channel Username",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: "@your_channel_username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.alternate_email),
                    ),
                  ),
                  if (provider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _verifyConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF2196F3), // Telegram Blue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Verify Connection",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
