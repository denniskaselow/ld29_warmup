import 'package:ld29_warmup/client.dart';

@MirrorsUsed(targets: const [LightRenderingSystem, BodyRenderer, RaycastingSystem
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {

  Game() : super.noAssets('ld29_warmup', 'canvas', 600, 600);

  void createEntities() {
    addEntity([new Transform(0, 0), new Body([0, 0, 600, 0, 600, 600, 0, 600])]);
    addEntity([new Transform(150, 150), new Body([-51, -51, 49, -49, 51, 51, -49, 49])]);
    addEntity([new Transform(450, 450), new Body([-60, -40, 30, 50, -50, 60])]);
    addEntity([new Transform(150, 450), new Body([-60, -40, 30, -20, 80, -60, 90, 20, 50, 50, 20, 40, -50, 60])]);
    addEntity([new Transform(450, 150), new Body([-60, -40, -20, -20, 30, -50, 50, 50, -50, 60])]);
  }

  List<EntitySystem> getSystems() {
    return [
            new CanvasCleaningSystem(canvas),
            new LightRenderingSystem(canvas),
//            new BodyRenderer(ctx),
            new RaycastingSystem(canvas, ctx),
            new FpsRenderingSystem(ctx),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld29_warmup')
    ];
  }
}
