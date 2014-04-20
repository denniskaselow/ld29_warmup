import 'package:ld29_warmup/client.dart';

@MirrorsUsed(targets: const [LightRenderingSystem, BodyRenderer
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {

  Game() : super.noAssets('ld29_warmup', 'canvas', 600, 600);

  void createEntities() {
    addEntity([new Transform(100, 100), new Body([-60, -40, 30, -50, 50, 50, -50, 60])]);
  }

  List<EntitySystem> getSystems() {
    return [
            new CanvasCleaningSystem(canvas),
            new LightRenderingSystem(canvas),
            new BodyRenderer(ctx),
            new FpsRenderingSystem(ctx),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld29_warmup')
    ];
  }
}
