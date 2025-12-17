import 'package:flutter/material.dart';

class UserApprovalPage extends StatelessWidget {
  const UserApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Approval')),
      body: Center(child: Text('This is the User Approval Page')),
    );
  }
}
