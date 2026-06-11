import 'package:flutter/material.dart';
import 'package:motion/models.dart';
import 'package:motion/router.dart';
import 'package:motion/style.dart';
import 'package:provider/provider.dart';

void main() => runApp(const ReplyApp());

class ReplyApp extends StatefulWidget {
  const ReplyApp({Key? key}) : super(key: key);

  @override
  ReplyAppState createState() => ReplyAppState();
}

class ReplyAppState extends State<ReplyApp> {
  final RouterProvider _replyState = RouterProvider(const ReplyHomePath());
  final ReplyRouteInformationParser _routeInformationParser =
      ReplyRouteInformationParser();
  late final ReplyRouterDelegate _routerDelegate;

  @override
  void initState() {
    super.initState();
    _routerDelegate = ReplyRouterDelegate(replyState: _replyState);
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EmailStore>.value(value: EmailStore()),
      ],
      child: Selector<EmailStore, ThemeMode>(
          selector: (context, emailStore) => emailStore.themeMode,
          builder: (context, themeMode, child) {
            return MaterialApp.router(
              routeInformationParser: _routeInformationParser,
              routerDelegate: _routerDelegate,
              themeMode: themeMode,
              title: 'Motion Mail',
              darkTheme: _buildReplyDarkTheme(context),
              theme: _buildReplyLightTheme(context),
            );
          }),
    );
  }
}

ThemeData _buildReplyLightTheme(BuildContext context) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1976D2),
    brightness: Brightness.light,
  );
  return ThemeData.from(
    colorScheme: colorScheme,
    useMaterial3: true,
  ).copyWith(
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.primary,
      modalBackgroundColor: Colors.white.withValues(alpha: 0.7),
    ),
    cardColor: ReplyColors.white50,
    chipTheme: _buildChipTheme(
      colorScheme.primary,
      ReplyColors.lightChipBackground,
      Brightness.light,
    ),
    textTheme: _buildReplyLightTextTheme(ThemeData.light().textTheme),
    scaffoldBackgroundColor: ReplyColors.blue50,
    bottomAppBarTheme: BottomAppBarThemeData(
      color: colorScheme.primary,
    ),
  );
}

ThemeData _buildReplyDarkTheme(BuildContext context) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1976D2),
    brightness: Brightness.dark,
  );
  return ThemeData.from(
    colorScheme: colorScheme,
    useMaterial3: true,
  ).copyWith(
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ReplyColors.darkDrawerBackground,
      modalBackgroundColor: Colors.black.withValues(alpha: 0.7),
    ),
    cardColor: ReplyColors.darkCardBackground,
    chipTheme: _buildChipTheme(
      colorScheme.primary,
      ReplyColors.darkChipBackground,
      Brightness.dark,
    ),
    textTheme: _buildReplyDarkTextTheme(ThemeData.dark().textTheme),
    scaffoldBackgroundColor: ReplyColors.black900,
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: ReplyColors.darkBottomAppBarBackground,
    ),
  );
}

ChipThemeData _buildChipTheme(
  Color primaryColor,
  Color chipBackground,
  Brightness brightness,
) {
  return ChipThemeData(
    backgroundColor: primaryColor.withValues(alpha: 0.12),
    disabledColor: primaryColor.withValues(alpha: 0.87),
    selectedColor: primaryColor.withValues(alpha: 0.05),
    secondarySelectedColor: chipBackground,
    padding: const EdgeInsets.all(4),
    shape: const StadiumBorder(),
    labelStyle: TextStyle(
      fontFamily: 'WorkSans',
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: brightness == Brightness.dark
          ? ReplyColors.white50
          : ReplyColors.black900,
    ),
    secondaryLabelStyle: const TextStyle(
      fontFamily: 'WorkSans',
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    brightness: brightness,
  );
}

TextTheme _buildReplyLightTextTheme(TextTheme base) {
  return base.copyWith(
    headlineMedium: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.w600,
      fontSize: 34,
      letterSpacing: 0.4,
      height: 0.9,
      color: ReplyColors.black900,
    ),
    headlineSmall: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.bold,
      fontSize: 24,
      letterSpacing: 0.27,
      color: ReplyColors.black900,
    ),
    titleLarge: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: 0.18,
      color: ReplyColors.black900,
    ),
    titleSmall: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: -0.04,
      color: ReplyColors.black900,
    ),
    bodyLarge: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.normal,
      fontSize: 18,
      letterSpacing: 0.2,
      color: ReplyColors.black900,
    ),
    bodyMedium: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      letterSpacing: -0.05,
      color: ReplyColors.black900,
    ),
    bodySmall: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.normal,
      fontSize: 12,
      letterSpacing: 0.2,
      color: ReplyColors.black900,
    ),
  );
}

TextTheme _buildReplyDarkTextTheme(TextTheme base) {
  return base.copyWith(
    headlineMedium: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.w600,
      fontSize: 34,
      letterSpacing: 0.4,
      height: 0.9,
      color: ReplyColors.white50,
    ),
    headlineSmall: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.bold,
      fontSize: 24,
      letterSpacing: 0.27,
      color: ReplyColors.white50,
    ),
    titleLarge: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: 0.18,
      color: ReplyColors.white50,
    ),
    titleSmall: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: -0.04,
      color: ReplyColors.white50,
    ),
    bodyLarge: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.normal,
      fontSize: 18,
      letterSpacing: 0.2,
      color: ReplyColors.white50,
    ),
    bodyMedium: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      letterSpacing: -0.05,
      color: ReplyColors.white50,
    ),
    bodySmall: const TextStyle(
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.normal,
      fontSize: 12,
      letterSpacing: 0.2,
      color: ReplyColors.white50,
    ),
  );
}
