import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/notification_service.dart';
import 'core/call_service.dart';
import 'env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A0C),
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  tzdata.initializeTimeZones();
  try {
    final deviceTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTz.identifier));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();
  await CallService.instance.init();

  runApp(const ProviderScope(child: AnnaApp()));
}