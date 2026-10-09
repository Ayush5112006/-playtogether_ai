import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/player.dart';
import 'models/question.dart';
import 'widgets/top_bar.dart';
import 'widgets/bottom_hud.dart';
import 'widgets/dpad_remote_overlay.dart';
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
        scaffoldBackgroundColor: AppColors.background,
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
  bool isRemoteOverlayVisible = false;
  final FocusNode _focusNode = FocusNode();

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
      if (cmd == 'OK') {
        if (currentScreenIndex < 4) {
          currentScreenIndex++;
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
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Ambient Volumetric TV Shaders
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

            // Main 16:9 Viewport Shell
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

            // D-Pad TV Controller / Phone Buzzer Simulation Overlay
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
        );
      case 2:
        return GameSelectScreen(
          onCreateGame: () => setState(() => currentScreenIndex = 3),
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
