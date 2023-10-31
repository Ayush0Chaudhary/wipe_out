import 'package:flutter/material.dart';
import 'package:game_template/src/style/responsive_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../settings/custom_name_dialog.dart';
import '../settings/settings.dart';

class ChangeNameScreen extends StatelessWidget {
  const ChangeNameScreen({super.key});

  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
                child: Column(
                  children: const [
                    _NameChangeLine('P1 :', Player.player1),
                    _gap,
                    _NameChangeLine('P2 :', Player.player2),
                  ],
                ),
              ),
          Column(
            children: [
              _gap,
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: FilledButton(
                    
                    onPressed: () {
                      GoRouter.of(context).go('/play/session');
                    },
                    child: Text('Start')),
              ),
            
            ],
          ),
          ],
        ),
      ),
      
    );
  }
}

class _NameChangeLine extends StatelessWidget {
  final String title;
  final Player player;

  const _NameChangeLine(this.title, this.player);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: () => showCustomNameDialog(context, player),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 30,
                )),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: player == Player.player1
                  ? settings.player1Name
                  : settings.player2Name,
              builder: (context, name, child) => Text(
                '‘$name’',
                style: const TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
