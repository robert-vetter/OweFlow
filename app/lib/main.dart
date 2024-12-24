// main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndoaHVib3ZrYXNxeGhkaG5wc2FkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUwMzg5OTMsImV4cCI6MjA1MDYxNDk5M30.7xv3-ZvXF2uohhCdj_MMGRVOCyTktmQCzbDVUmUWJZo",
    url: "https://whhubovkasqxhdhnpsad.supabase.co",
  );
  runApp(const MyApp());
}
