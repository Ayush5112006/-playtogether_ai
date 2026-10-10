import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/player.dart';
import 'models/question.dart';
import 'services/api_service.dart';
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
  int gameplayQuestionIndex = 0;
  late List<Player> players;
  late List<Question> questions;
  List<Map<String, dynamic>> categories = [];
  String activeSessionId = 'session_live_4892';
  String selectedCategory = 'Cinema Clues';
  String selectedDifficulty = 'ADAPTIVE';

  bool isRemoteOverlayVisible = true;
  final FocusNode _focusNode = FocusNode();
  String? lastRemoteCommand;
  int remoteCommandCounter = 0;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    players = Player.getDefaultPlayers();
    questions = Question.getSampleQuestions();
    _loadDynamicDatabaseContent();
  }

  Future<void> _loadDynamicDatabaseContent() async {
    try {
      final fetchedCategories = await _apiService.fetchCategories();
      final fetchedQuestions = await _apiService.fetchAllQuestions();
      final newSessionId = await _apiService.createSession(
        players: players.map((p) => p.toSessionMap()).toList(),
        difficulty: selectedDifficulty,
      );

      if (mounted) {
        setState(() {
          if (fetchedCategories.isNotEmpty) categories = fetchedCategories;
          if (fetchedQuestions.isNotEmpty) questions = fetchedQuestions;
          if (newSessionId.isNotEmpty) activeSessionId = newSessionId;
        });
      }
    } catch (_) {}
  }

  Future<void> _onCategoryChanged(String categoryName) async {
    setState(() => selectedCategory = categoryName);
    try {
      final catQuestions = await _apiService.fetchAllQuestions(category: categoryName);
      if (mounted && catQuestions.isNotEmpty) {
        setState(() => questions = catQuestions);
      }
    } catch (_) {}
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
      } else if (event.logicalKey == LogicalKeyboardKey.keyB) {
        _handleRemoteCommand('BUZZ');
      } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
        _handleRemoteCommand('MIC');
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
          gameplayQuestionIndex = 0;
          currentScreenIndex = 4;
        } else if (currentScreenIndex == 5) { // Adaptation -> Gameplay next q
          gameplayQuestionIndex = 1;
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
    // Dynamic background energy & opacity per screen (optimized for performance)
    double bgOpacity;
    double bgSpeed;
    double bgGlow;
    const int pCount = 30; // Lightweight 30 particles for instant load time and 60fps

    switch (currentScreenIndex) {
      case 0: // Home Screen Hub
        bgOpacity = 0.90;
        bgSpeed = 1.0;
        bgGlow = 1.1;
        break;
      case 1: // Player Setup
        bgOpacity = 0.45;
        bgSpeed = 0.7;
        bgGlow = 0.7;
        break;
      case 2: // Game Select
        bgOpacity = 0.55;
        bgSpeed = 0.85;
        bgGlow = 0.85;
        break;
      case 3: // AI Synthesis Screen
        bgOpacity = 0.95;
        bgSpeed = 1.2;
        bgGlow = 1.3;
        break;
      case 4: // Gameplay Screen
        bgOpacity = 0.28;
        bgSpeed = 0.65;
        bgGlow = 0.55;
        break;
      case 5: // AI Adaptation Screen
        bgOpacity = 0.85;
        bgSpeed = 1.2;
        bgGlow = 1.2;
        break;
      case 6: // Winner Recap
        bgOpacity = 0.90;
        bgSpeed = 1.0;
        bgGlow = 1.3;
        break;
      default:
        bgOpacity = 0.85;
        bgSpeed = 1.0;
        bgGlow = 1.0;
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
                  onStepTap: (step) {
                    setState(() {
                      if (step == 1) currentScreenIndex = 1;
                      if (step == 2) currentScreenIndex = 2;
                      if (step == 3) currentScreenIndex = 3;
                      if (step == 4) currentScreenIndex = 4;
                    });
                  },
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
              activeCommand: lastRemoteCommand != null ? '$lastRemoteCommand-$remoteCommandCounter' : null,
              onToggle: () => setState(() => isRemoteOverlayVisible = !isRemoteOverlayVisible),
              onCommand: _handleRemoteCommand,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    final remoteTag = lastRemoteCommand != null ? '$lastRemoteCommand-$remoteCommandCounter' : null;

    switch (currentScreenIndex) {
      case 0:
        return HomeScreen(
          players: players,
          sessionId: activeSessionId,
          totalQuestionsCount: questions.length,
          categories: categories,
          lastRemoteCommand: remoteTag,
          onStartGame: () => setState(() => currentScreenIndex = 1),
          onContinueSession: () => setState(() => currentScreenIndex = 4),
          onSelectCategory: (cat) {
            _onCategoryChanged(cat);
            setState(() => currentScreenIndex = 3);
          },
        );
      case 1:
        return PlayerSetupScreen(
          players: players,
          onContinue: () => setState(() => currentScreenIndex = 2),
          onFocusPlayerChanged: (idx) {},
          lastRemoteCommand: remoteTag,
        );
      case 2:
        return GameSelectScreen(
          players: players,
          categories: categories,
          selectedCategory: selectedCategory,
          selectedDifficulty: selectedDifficulty,
          onCategoryChanged: _onCategoryChanged,
          onDifficultyChanged: (diff) => setState(() => selectedDifficulty = diff),
          onCreateGame: () => setState(() => currentScreenIndex = 3),
          lastRemoteCommand: remoteTag,
        );
      case 3:
        return AiSynthesisScreen(
          onStartGame: () => setState(() => currentScreenIndex = 4),
          lastRemoteCommand: remoteTag,
        );
      case 4:
        return GameplayScreen(
          questions: questions,
          players: players,
          sessionId: activeSessionId,
          initialQuestionIndex: gameplayQuestionIndex,
          onTriggerAdaptation: () => setState(() => currentScreenIndex = 5),
          onGameFinished: () => setState(() => currentScreenIndex = 6),
          lastRemoteCommand: remoteTag,
          onScoreUpdate: (pts) {
            setState(() {
              if (players.isNotEmpty) {
                players[0].score += pts;
              }
            });
          },
        );
      case 5:
        return AiAdaptationScreen(
          onContinue: () => setState(() {
            gameplayQuestionIndex = 1;
            currentScreenIndex = 4;
          }),
          lastRemoteCommand: remoteTag,
        );
      case 6:
        return WinnerRecapScreen(
          players: players,
          sessionId: activeSessionId,
          onPlayAgain: () => setState(() => currentScreenIndex = 3),
          onReturnHub: () => setState(() => currentScreenIndex = 0),
          lastRemoteCommand: remoteTag,
        );
      default:
        return HomeScreen(
          players: players,
          sessionId: activeSessionId,
          totalQuestionsCount: questions.length,
          categories: categories,
          lastRemoteCommand: remoteTag,
          onStartGame: () => setState(() => currentScreenIndex = 1),
          onContinueSession: () => setState(() => currentScreenIndex = 4),
        );
    }
  }
}
