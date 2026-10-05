import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/agent_workflow.dart';
import '../../services/agent_service.dart';

class AiBuildPage extends StatefulWidget {
  const AiBuildPage({super.key});

  @override
  State<AiBuildPage> createState() => _AiBuildPageState();
}

class _AiBuildPageState extends State<AiBuildPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _agentService = AgentService();

  final List<_ChatMessage> _messages = [];

  AgentWorkflow? _workflow;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _messages.add(
      const _ChatMessage(
        text:
            "Hi! I'm your TechNest AI PC Builder.\n\n"
            "Tell me what kind of PC you need, what you'll use it for, "
            "and your approximate budget. I'll help you choose a suitable build.",
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_loading) return;

    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    _messageController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));

      _loading = true;
      _workflow = null;
    });

    _scrollToBottom();

    try {
      final conversation = _buildConversation();

      final workflow = await _agentService.startWorkflow(
        objective: text,
        conversation: conversation,
      );

      if (!mounted) return;

      setState(() {
        _workflow = workflow;
        _loading = false;
      });

      _addAssistantResponse(workflow);

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;

        _messages.add(
          _ChatMessage(
            text: e.toString().replaceFirst('Exception: ', ''),
            isUser: false,
            isError: true,
          ),
        );
      });

      _scrollToBottom();
    }
  }

  List<Map<String, String>> _buildConversation() {
    return _messages.map((message) {
      return {
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.text,
      };
    }).toList();
  }

  void _addAssistantResponse(AgentWorkflow workflow) {
    final response = workflow.chatResponse.trim();

    if (response.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: response, isUser: false));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _workflow = null;
      _loading = false;

      _messages.add(
        const _ChatMessage(
          text:
              "Hi! I'm your TechNest AI PC Builder.\n\n"
              "Tell me what kind of PC you need, what you'll use it for, "
              "and your approximate budget.",
          isUser: false,
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F4),
        elevation: 0,
        foregroundColor: Colors.black87,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI PC Builder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 2),
            Text(
              'TechNest AI',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New chat',
            onPressed: _loading ? null : _startNewChat,
            icon: const Icon(Icons.add_comment_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_loading && index == _messages.length) {
                  return _buildTypingIndicator();
                }

                return _buildMessage(_messages[index]);
              },
            ),
          ),

          if (_workflow != null &&
              (_workflow!.build != null || _workflow!.validation != null))
            _buildWorkflowResult(_workflow!),

          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: message.isError
              ? Colors.red.shade50
              : message.isUser
              ? AppColors.primary
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.isUser ? 18 : 5),
            bottomRight: Radius.circular(message.isUser ? 5 : 18),
          ),
          border: message.isUser || message.isError
              ? null
              : Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: message.isError
                ? Colors.red.shade800
                : message.isUser
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(5),
          ),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AI is thinking...',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_loading,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Tell me about the PC you need...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F7F4),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) {
                  if (!_loading) {
                    _sendMessage();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _loading ? Colors.grey.shade400 : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _loading ? null : _sendMessage,
                icon: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowResult(AgentWorkflow workflow) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F4),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(workflow),

            if (workflow.build != null) ...[
              const SizedBox(height: 12),
              _buildBuildCard(workflow.build!),
            ],

            if (workflow.validation != null) ...[
              const SizedBox(height: 12),
              _buildValidationCard(workflow.validation!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AgentWorkflow workflow) {
    final isValid = workflow.status == 'WAITING_FOR_APPROVAL';

    final isFailed = workflow.status == 'FAILED_SAFE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isValid
            ? Colors.green.shade50
            : isFailed
            ? Colors.red.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isValid
              ? Colors.green.shade100
              : isFailed
              ? Colors.red.shade100
              : Colors.orange.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid
                ? Icons.check_circle_outline
                : isFailed
                ? Icons.error_outline
                : Icons.warning_amber_rounded,
            color: isValid
                ? Colors.green.shade700
                : isFailed
                ? Colors.red.shade700
                : Colors.orange.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isValid
                  ? 'Build passed validation'
                  : isFailed
                  ? 'Build could not be safely completed'
                  : 'Build requires attention',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildCard(AgentBuild build) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Build',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          ...build.products.map((product) => _buildProductRow(product)),

          const SizedBox(height: 10),

          Divider(color: Colors.grey.shade200, height: 1),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                _formatPrice(build.totalAmount),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          if (build.explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              build.explanation,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductRow(AgentProduct product) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1E8),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              _categoryIcon(product.category),
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatPrice(product.unitPrice),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationCard(AgentValidation validation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Validation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          if (validation.budget != null)
            _buildBudgetRow(validation.totalAmount, validation.budget!),

          if (validation.errors.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Issues',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 7),
            ...validation.errors.map(_buildIssue),
          ],

          if (validation.warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Warnings',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 7),
            ...validation.warnings.map(_buildIssue),
          ],

          if (validation.errors.isEmpty && validation.warnings.isEmpty)
            Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade600),
                const SizedBox(width: 7),
                Text(
                  'All validation checks passed.',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 13),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(double total, double budget) {
    final withinBudget = total <= budget;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: withinBudget ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(
            withinBudget
                ? Icons.check_circle_outline
                : Icons.warning_amber_rounded,
            color: withinBudget ? Colors.green.shade700 : Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budget',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  'Budget: ${_formatPrice(budget)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
                Text(
                  'Build: ${_formatPrice(total)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Text(
            withinBudget ? 'OK' : 'Over',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: withinBudget ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssue(AgentValidationIssue issue) {
    final isWarning = issue.severity == 'WARNING';

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isWarning ? Colors.orange.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.error_outline,
            size: 17,
            color: isWarning ? Colors.orange.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              issue.message,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: isWarning ? Colors.orange.shade900 : Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'processor':
        return Icons.memory;
      case 'motherboard':
        return Icons.developer_board;
      case 'ram':
        return Icons.memory_outlined;
      case 'gpu':
        return Icons.graphic_eq;
      case 'storage':
        return Icons.storage;
      case 'psu':
        return Icons.power;
      case 'case':
        return Icons.desktop_windows;
      case 'cpu cooler':
        return Icons.ac_unit;
      default:
        return Icons.computer;
    }
  }

  String _formatPrice(double value) {
    final rounded = value.round();
    final text = rounded.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(text[i]);
    }

    return 'Rs. ${buffer.toString()}';
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}
