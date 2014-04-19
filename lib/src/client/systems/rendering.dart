part of client;


class LightRenderingSystem extends VoidEntitySystem {
  CanvasElement canvas;
  CanvasQuery light;
  int index = 0;
  int fireHue = 0;
  int fireLightness = 50;
  int x = 300, y = 300;
  List<String> modes = ['normal', 'multiply', 'screen', 'overlay', 'darken', 'lighten', 'color-dodge', 'color-burn', 'hard-light', 'soft-light', 'difference', 'exclusion', 'hue', 'saturation', 'color', 'luminosity'];

  LightRenderingSystem(this.canvas);

  @override
  void initialize() {
    light = cq(canvas.width, canvas.height);
    var grd = light.createRadialGradient(canvas.width ~/ 2, canvas.height ~/ 2, 0, canvas.width ~/ 2, canvas.height ~/ 2, 300);
    grd.addColorStop(0, 'rgba(200,200,200,0.8)');
    grd.addColorStop(0.4, 'rgba(150,150,150,0.4)');
    grd.addColorStop(0.8, 'rgba(100,100,100,0.2)');
    grd.addColorStop(1, 'rgba(50,50,50,0.1)');
    light..fillStyle = 'black'
         ..fillRect(0, 0, 600, 600)
         ..fillStyle = grd
         ..fillRect(0, 0, 600, 600);
    canvas.onMouseMove.listen((event) {
      x = event.offset.x;
      y = event.offset.y;
    });
  }

  @override
  void processSystem() {
    if (world.frame % 240 == 0) {
      index++;
    }
    if (world.frame % 6 == 0) {
      fireHue += (1 - fireHue/60) > random.nextDouble() ? 1 : -1;
      fireLightness += (1 - (fireLightness)/80) > random.nextDouble() ? 1 : -1;
    }
    canvas.context2D..setFillColorHsl(50, 100, 50)
                    ..fillRect(0, 0, 300, 300)
                    ..setFillColorHsl(50, 0, 100)
                    ..fillRect(300, 0, 300, 300)
                    ..setFillColorHsl(200, 100, 50)
                    ..fillRect(0, 300, 300, 300)
                    ..setFillColorHsl(0, 100, 50)
                    ..fillRect(300, 300, 300, 300)
                    ..save()
                    ..globalCompositeOperation = 'luminosity'
                    ..drawImage(light.canvas, x - 300, y - 300)
                    ..setFillColorHsl(fireHue, 100, fireLightness)
                    ..globalCompositeOperation = 'overlay'
                    ..globalAlpha = 0.8
                    ..fillRect(x - 300, y - 300, 600, 600)
                    ..restore();


  }
}