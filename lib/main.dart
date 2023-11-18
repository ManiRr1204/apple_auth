// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_apple_signin/providers/authentication_provider.dart';
// import 'package:flutter_apple_signin/screens/login_screen.dart';
// import 'package:flutter_apple_signin/screens/logout_screen.dart';
// import 'package:provider/provider.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (ctx) => AuthenticationProvider(FirebaseAuth.instance),
//         ),
//         StreamProvider(
//           create: (BuildContext context) {
//             return context.read<AuthenticationProvider>().authStateChanges;
//           },
//          initialData: null,
//         )
//       ],
//       child: MaterialApp(
//         title: 'Flutter Demo',
//         theme: ThemeData(
//           primarySwatch: Colors.purple,
//           hintColor: Colors.deepOrange,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         home: MyHomePage(),
//         routes: {},
//       ),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final firebaseUser = context.watch<User>();
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Apple Sign In'),
//         ),
//         // ignore: unnecessary_null_comparison
//         body: firebaseUser != null ? LogoutPage() : LoginPage());
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_apple_signin/loginCredentials.dart';
import 'package:flutter_apple_signin/providers/authentication_provider.dart';
import 'package:flutter_apple_signin/screens/login_screen.dart';
import 'package:flutter_apple_signin/screens/logout_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyA85U-XbHimUx_K1O2LRVvCZc51DWGtBh8",
            authDomain: "bright-brains-app.firebaseapp.com",
            projectId: "bright-brains-app",
            storageBucket: "bright-brains-app.appspot.com",
            messagingSenderId: "823648655832",
            appId: "1:823648655832:web:f0f01b2618ec2d51d4faad",
            measurementId: "G-W0SZ8HXBSM"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthenticationProvider(FirebaseAuth.instance),
        ),
        StreamProvider<User?>(
          create: (BuildContext context) {
            return context.read<AuthenticationProvider>().authStateChanges;
          },
          initialData: null,
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          hintColor: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
        routes: {},
      ),
    );
  }
}

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final firebaseUser = context.watch<User?>();
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Apple Sign In'),
//       ),
//       body: firebaseUser != null ? LogoutPage() : LoginPage(),
//     );
//   }
// }

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apple Sign In'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            User? user = snapshot.data;
            return UserDetailsWidget(user: user!);
          } else {
            return LoginPage(); // Or any other login handling widget
          }
        },
      ),
    );
  }
}

class UserDetailsWidget extends StatelessWidget {
  final User user;

  const UserDetailsWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Name : ${user.displayName ?? "N/A"}"),
          Text('Photo URL: ${user.photoURL ?? "N/A"}'),
          Text('Email: ${user.email ?? "N/A"}'),
          ElevatedButton(
            onPressed: () {
              // Handle sign out here using context
              context.read<AuthenticationProvider>().signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
