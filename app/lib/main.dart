// main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpiZmVodWJwY2NsdWhuc3Ryd2RqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5ODk5NzUsImV4cCI6MjA1MDU2NTk3NX0.NEyCAGirr4J4iHBxud50uyvpGtaHgqSvVy5RQ8H4Q2I",
    url: "https://jbfehubpccluhnstrwdj.supabase.co",
  );
  runApp(const MyApp());
}
