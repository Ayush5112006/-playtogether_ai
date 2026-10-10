import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/player.dart';
import 'models/question.dart';
import 'widgets/top_bar.dart';
import 'widgets/bottom_hud.dart';
import 'widgets/dpad_remote_overlay.dart';
import 'widgets/animated_ai_network_background.dart';
import 'screens/home_screen.dart';
import 'screens/player_setup_screen.dart';
import 'screens/game_select_screen.dart';
import 'screens/ai_synthesis_screen.dart';
import 'screens/gameplay_screen.dart';
import 'screens/ai_adaptation_screen.dart';
import 'screens/winner_recap_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlayTogetherApp());
}

class PlayTogetherApp extends StatelessWidget {
  const PlayTogetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayTogether AI - Living Room Experience',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070812),
        useMaterial3: true,
      ),
      home: const MainTVViewport(),
    );
  }
}

class MainTVViewport extends StatefulWidget {
  const MainTVViewport({super.key});

  @override
  State<MainTVViewport> createState() => _MainTVViewportState();
}

class _MainTVViewportState extends State<MainTVViewport> {
  int currentScreenIndex = 0; // 0: Hub, 1: Setup, 2: Select, 3: Synthesis, 4: Gameplay, 5: Adaptation, 6: Winner
  late List<Player> players;
  late List<Question> questions;
  bool isRemoteOverlayVisible = true;
  final FocusNode _focusNode = FocusNode();
  String? lastRemoteCommand;
  int remoteCommandCounter = 0;

  @override
  void initState() {
    super.initState();
    players = Player.getDefaultPlayers();
    questions = Question.getSampleQuestions();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
        _handleRemoteCommand('RIGHT');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
        _handleRemoteCommand('LEFT');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyW) {
        _handleRemoteCommand('UP');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyS) {
        _handleRemoteCommand('DOWN');
      } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space) {
        _handleRemoteCommand('OK');
      } else if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.backspace) {
        _handleRemoteCommand('BACK');
      }
    }
  }

  void _handleRemoteCommand(String cmd) {
    setState(() {
      remoteCommandCounter++;
      lastRemoteCommand = cmd;

      if (cmd == 'OK') {
        if (currentScreenIndex == 0) {
          currentScreenIndex = 1;
        } else if (currentScreenIndex == 3) {
          currentScreenIndex = 4;
        } else if (currentScreenIndex == 5) { // Adaptation -> Gameplay next q
          currentScreenIndex = 4;
        } else if (currentScreenIndex == 6) { // Winner -> Hub
          currentScreenIndex = 0;
        }
      } else if (cmd == 'BACK') {
        if (currentScreenIndex > 0) {
          currentScreenIndex--;
        }
      } else if (cmd == 'BUZZ') {
        if (currentScreenIndex == 4) {
          currentScreenIndex = 5; // Trigger AI Intervention overlay
        }
      }
    });

    // Provide visual toast feedback for remote controller action
    if (mounted) {
      String msg = '';
      switch (cmd) {
        case 'LEFT':
          msg = '⬅️ D-Pad Left Pressed';
          break;
        case 'RIGHT':
          msg = '➡️ D-Pad Right Pressed';
          break;
        case 'UP':
          msg = '⬆️ D-Pad Up Pressed';
          break;
        case 'DOWN':
          msg = '⬇️ D-Pad Down Pressed';
          break;
        case 'OK':
          msg = '🎯 OK Action Executed';
          break;
        case 'BACK':
          msg = '↩️ Back Navigation';
          break;
        case 'MIC':
          msg = '🎤 Voice Listening: Room Audio Active';
          break;
        case 'BUZZ':
          msg = '🔔 Phone Buzzer Triggered by Maya!';
          break;
        default:
          msg = '⚡ Command: $cmd';
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          duration: const Duration(milliseconds: 1200),
          backgroundColor: AppColors.surfaceHigh,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 30, right: 300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.secondary, width: 1.5),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic background energy & opacity per screen
    double bgOpacity;
    double bgSpeed;
    double bgGlow;
    int pCount;

    switch (currentScreenIndex) {
      case 0: // Home Screen Hub
        bgOpacity = 0.90;
        bgSpeed = 1.0;
        bgGlow = 1.1;
        pCount = 75;
        break;
      case 1: // Player Setup
        bgOpacity = 0.45;
        bgSpeed = 0.7;
        bgGlow = 0.7;
        pCount = 60;
        break;
      case 2: // Game Select
        bgOpacity = 0.55;
        bgSpeed = 0.85;
        bgGlow = 0.85;
        pCount = 65;
        break;
      case 3: // AI Synthesis Screen (Question Generation)
        bgOpacity = 0.95;
        bgSpeed = 1.4;
        bgGlow = 1.4;
        pCount = 85;
        break;
      case 4: // Gameplay Screen (Keep low opacity so text & choices remain crystal clear)
        bgOpacity = 0.28;
        bgSpeed = 0.65;
        bgGlow = 0.55;
        pCount = 55;
        break;
      case 5: // AI Adaptation Screen
        bgOpacity = 0.85;
        bgSpeed = 1.3;
        bgGlow = 1.25;
        pCount = 80;
        break;
      case 6: // Winner Recap
        bgOpacity = 0.90;
        bgSpeed = 1.0;
        bgGlow = 1.3;
        pCount = 75;
        break;
      default:
        bgOpacity = 0.85;
        bgSpeed = 1.0;
        bgGlow = 1.0;
        pCount = 70;
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFF070812),
        body: Stack(
          children: [
            // 1. Continuous Animated Gold AI Network Background
            Positioned.fill(
              child: AnimatedAINetworkBackground(
                opacity: bgOpacity,
                animationSpeed: bgSpeed,
                glowIntensity: bgGlow,
                particleCount: pCount,
                backgroundColor: const Color(0xFF070812),
              ),
            ),

            // 2. Ambient Volumetric TV Shaders
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.ambientBloom1,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.ambientBloom2,
                ),
              ),
            ),

            // 3. Main 16:9 Viewport Shell
            Column(
              children: [
                // Top App Bar
                SharedTopBar(
                  currentStep: currentScreenIndex == 0 ? 0 : (currentScreenIndex > 4 ? 4 : currentScreenIndex),
                  onMicTap: () => _handleRemoteCommand('MIC'),
                ),

                // Screen Viewport Canvas
                Expanded(
                  child: _buildCurrentScreen(),
                ),

                // Sofa-Friendly Bottom HUD Bar
                SharedBottomHud(
                  onOkPress: () => _handleRemoteCommand('OK'),
                  onBackPress: () => _handleRemoteCommand('BACK'),
                  onMicPress: () => _handleRemoteCommand('MIC'),
                ),
              ],
            ),

            // 4. D-Pad TV Controller / Phone Buzzer Simulation Overlay
            DpadRemoteOverlay(
              isVisible: isRemoteOverlayVisible,
              onToggle: () => setState(() => isRemoteOverlayVisible = !isRemoteOverlayVisible),
              onCommand: _handleRemoteCommand,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (currentScreenIndex) {
      case 0:
        return HomeScreen(
          players: players,
          onStartGame: () => setState(() => currentScreenIndex = 1),
          onContinueSession: () => setState(() => currentScreenIndex = 4),
        );
      case 1:
        return PlayerSetupScreen(
          players: players,
          onContinue: () => setState(() => currentScreenIndex = 2),
          onFocusPlayerChanged: (idx) {},
          lastRemoteCommand: lastRemoteCommand != null ? '$lastRemoteCommand-$remoteCommandCounter' : null,
        );
      case 2:
        return GameSelectScreen(
          onCreateGame: () => setState(() => currentScreenIndex = 3),
          lastRemoteCommand: lastRemoteCommand != null ? '$lastRemoteCommand-$remoteCommandCounter' : null,
        );
      case 3:
        return AiSynthesisScreen(
          onStartGame: () => setState(() => currentScreenIndex = 4),
        );
      case 4:
        return GameplayScreen(
          questions: questions,
          players: players,
          onTriggerAdaptation: () => setState(() => currentScreenIndex = 5),
          onGameFinished: () => setState(() => currentScreenIndex = 6),
          lastRemoteCommand: lastRemoteCommand != null ? '$lastRemoteCommand-$remoteCommandCounter' : null,
          onScoreUpdate: (pts) {
            setState(() {
              players[2].score += pts; // Add points to Maya
            });
          },
        );
      case 5:
        return AiAdaptationScreen(
          onContinue: () => setState(() => currentScreenIndex = 4),
        );
      case 6:
        return WinnerRecapScreen(
          players: players,
          onPlayAgain: () => setState(() => currentScreenIndex = 3),
          onReturnHub: () => setState(() => currentScreenIndex = 0),
        );
      default:
        return HomeScreen(
          players: players,
          onStartGame: () => setState(() => currentScreenIndex = 1),
          onContinueSession: () => setState(() => currentScreenIndex = 4),
        );
    }
  }
}
