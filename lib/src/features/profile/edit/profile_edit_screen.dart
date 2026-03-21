import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Scaffold(body: Center(child: Text('Edit Profile (PR-02)')));
}
