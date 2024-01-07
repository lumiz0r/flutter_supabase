import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_supabase/main.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  var _loading = true;
  var _userExists = false; // Add this variable

  Future<void> _getProfile() async {
  setState(() {
    _loading = true;
  });

  try {
    final userId = supabase.auth.currentSession!.user.id;
    final data = await supabase.from('users').select().eq('id', userId).single();

    _usernameController.text = (data  ['username'] ?? '') as String;
    _emailController.text = (data['email'] ?? '') as String;
    setState(() {
      _userExists = true;
    });
  } on PostgrestException catch (error) {
    // Handle exceptions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}



  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
  setState(() {
    _loading = true;
  });
  final userName = _usernameController.text.trim();
  final user = supabase.auth.currentUser;
  final email = _emailController.text.trim();

  final updates = {
    'id': user!.id,
    'username': userName,
    'email': email,
    'updated_at': DateTime.now().toIso8601String(),
  };

  try {
      await supabase.from('users').upsert(updates);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully updated profile!'),
      ),
    );
  } on PostgrestException catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  } finally {
    setState(() {
      _loading = false;
    });
  }
}

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unexpected error occurred'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'User Name'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _loading ? null : _updateProfile,
                  child: Text(_loading ? 'Saving...' : 'Update'),
                ),
                if (_userExists) // Add this condition
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _loading ? null : () => Navigator.pushReplacementNamed(context, '/tasks'),
                    child: const Text('Go to Tasks'),
                  ),
                const SizedBox(height: 18),
                TextButton(onPressed: _signOut, child: const Text('Sign Out')),
              ],
            ),
    );
  }
}