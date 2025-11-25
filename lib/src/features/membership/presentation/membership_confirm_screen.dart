import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/membership_service.dart';

class MembershipConfirmScreen extends StatefulWidget {
  final Map<String, dynamic> plan;

  const MembershipConfirmScreen({super.key, required this.plan});

  @override
  State<MembershipConfirmScreen> createState() =>
      _MembershipConfirmScreenState();
}

class _MembershipConfirmScreenState extends State<MembershipConfirmScreen> {
  bool loading = false;

  Future<void> _complete() async {
    setState(() => loading = true);

    final tier = widget.plan['tier'];
    await MembershipService().enroll(tier);

    if (!mounted) return;
    context.go('/membership/card');
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plan;

    return Scaffold(
      appBar: AppBar(title: Text("Join ${p['tier']}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "You're about to join the ${p['tier']} plan.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text("Price: ${p['price']}"),
            const Spacer(),
            ElevatedButton(
              onPressed: loading ? null : _complete,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Complete Enrollment"),
            ),
          ],
        ),
      ),
    );
  }
}
