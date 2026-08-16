import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';
import '../models/entry.dart';
import '../utils/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    _messages.add(ChatMessage(
      text: "Merhaba! Ben senin 'Günce'n. Tüm anılarını burada saklıyorum. Geçmişinle ilgili bir şey sormak ister misin?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    final entries = Hive.box<Entry>('entries').values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final response = await GeminiService.getChatResponse(text, entries);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: response ?? "Bağlantıda bir kopukluk oldu, ama anıların güvende.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hafıza Sohbeti',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              )),
            Text('AI ile konuş',
              style: GoogleFonts.outfit(
                fontSize: 11, color: sub)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, size: 18, color: sub),
            onPressed: () => setState(() {
              _messages.clear();
              _addInitialMessage();
            }),
            tooltip: 'Sohbeti Temizle',
          )
        ],
      ),
      body: Column(
        children: [
          Divider(color: theme.dividerColor, height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 12, height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: theme.colorScheme.primary)),
                  const SizedBox(width: 10),
                  Text('Günce düşünüyor...',
                    style: GoogleFonts.outfit(fontSize: 12, color: sub)),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final theme = Theme.of(context);
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 2, right: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text('G',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimary,
                  )),
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: isUser
                    ? null
                    : Border.all(color: theme.dividerColor, width: 1),
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    final sub = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.outfit(
                    color: theme.colorScheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Güncene bir şey sor...',
                  hintStyle: GoogleFonts.outfit(color: sub, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.arrow_upward_rounded,
                  color: theme.colorScheme.onPrimary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
