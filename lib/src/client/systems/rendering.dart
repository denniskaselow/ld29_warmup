part of client;


class LightRenderingSystem extends VoidEntitySystem {
  CanvasElement canvas;
  CanvasQuery light;
  CanvasElement buffer;
  int index = 0;
  int fireHue = 0;
  int fireLightness = 50;
  int x = 300, y = 300;
  List<String> modes = ['normal', 'multiply', 'screen', 'overlay', 'darken', 'lighten', 'color-dodge', 'color-burn', 'hard-light', 'soft-light', 'difference', 'exclusion', 'hue', 'saturation', 'color', 'luminosity'];

  LightRenderingSystem(this.canvas);

  @override
  void initialize() {
    light = cq(canvas.width * 2, canvas.height * 2);
    var grd = light.createRadialGradient(canvas.width, canvas.height, 0, canvas.width, canvas.height, 300);
    grd.addColorStop(0, 'rgba(200,200,200,0.8)');
    grd.addColorStop(0.4, 'rgba(150,150,150,0.4)');
    grd.addColorStop(0.8, 'rgba(100,100,100,0.2)');
    grd.addColorStop(1, 'rgba(50,50,50,0.1)');
    light..fillStyle = 'black'
         ..fillRect(0, 0, 1200, 1200)
         ..fillStyle = grd
         ..fillRect(0, 0, 1200, 1200);
    canvas.onMouseMove.listen((event) {
      x = event.offset.x;
      y = event.offset.y;
    });

    buffer = new CanvasElement(width: 600, height: 600);
    buffer.context2D..setFillColorHsl(50, 100, 50)
        ..fillRect(0, 0, 300, 300)
        ..setFillColorHsl(50, 0, 100)
        ..fillRect(300, 0, 300, 300)
        ..setFillColorHsl(200, 100, 50)
        ..fillRect(0, 300, 300, 300)
        ..setFillColorHsl(0, 100, 50)
        ..fillRect(300, 300, 300, 300);
  }

  @override
  void processSystem() {
    if (world.frame % 240 == 0) {
      index++;
    }
    if (world.frame % 6 == 0) {
      fireHue += (1 - fireHue/60) > random.nextDouble() ? 4 : -4;
      fireLightness += (1 - (fireLightness)/80) > random.nextDouble() ? 4 : -4;
    }
    canvas.context2D..drawImage(buffer, 0, 0)
                    ..save()
                    ..globalCompositeOperation = 'luminosity'
                    ..drawImage(light.canvas, x - 600, y - 600)
                    ..setFillColorHsl(fireHue, 100, fireLightness)
                    ..globalCompositeOperation = 'overlay'
                    ..globalAlpha = 0.8
                    ..fillRect(x - 600, y - 600, 1200, 1200)
                    ..restore();


  }
}

class RaycastingSystem extends EntitySystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Body> bm;
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  int x = 300, y = 300;
  RaycastingSystem(this.canvas, this.ctx) : super(Aspect.getAspectForAllOf([Transform, Body]));

  @override
  void initialize() {
    canvas.onMouseMove.listen((event) {
      x = event.offset.x;
      y = event.offset.y;
    });
  }

  @override
  void processEntities(Iterable<Entity> entities) {
    List<List<double>> anglesAndPos = [];
    var rotate1 = new Matrix2.rotation(0.0001);
    var rotate2 = new Matrix2.rotation(-0.0001);
    entities.forEach((entity) {
      var t = tm.get(entity);
      var body = bm.get(entity);

      body.vertices.forEach((vertexToTest) {
        var ray = new Vector2(t.pos.x + vertexToTest.x - x, t.pos.y + vertexToTest.y - y);
        [rotate1 * ray, ray, rotate2 * ray].forEach((ray) {
          double minB;
          entities.forEach((entity) {
            var body = bm.get(entity);
            var t = tm.get(entity);
            for (int i = 0; i < body.vertices.length; i++) {
              var vertex = body.vertices[i] + t.pos;
              var nextVertex = body.vertices[(i + 1) % body.vertices.length] + t.pos;
              var segment = nextVertex - vertex;

              // vertex + a * segment = (x,y) + b * ray
              var b = (segment.x * (y - vertex.y) + segment.y * (vertex.x - x)) / (segment.y * ray.x - segment.x * ray.y);
              if (segment.x != 0) {
                var a = (x + b * ray.x - vertex.x) / segment.x;

                if (b >= 0 && a >= 0 && a <= 1.0 && (minB == null || b < minB)) {
                  minB = b;
                }
              } else {
                var yOnSegment = y + b * ray.y;
                if (yOnSegment > min(vertex.y, nextVertex.y) && yOnSegment < max(vertex.y, nextVertex.y)) {
                  if (b >= 0 && (minB == null || b < minB)) {
                    minB = b;
                  }
                }
              }
            }
          });
//          if (null == minB) {
//            minB = 1.0;
//          }
          if (null != minB) {
            anglesAndPos.add([atan2(ray.y, ray.x), x + minB * ray.x, y + minB * ray.y]);
          }
        });
      });
    });
    anglesAndPos.sort((a, b) => a[0].compareTo(b[0]));

    ctx..save()
       ..globalCompositeOperation = 'destination-in'
       ..strokeStyle = 'white'
       ..fillStyle = 'white'
       ..beginPath()
       ..moveTo(anglesAndPos.last[1], anglesAndPos.last[2]);
    anglesAndPos.forEach((angleAndPos) {
       ctx.lineTo(angleAndPos[1], angleAndPos[2]);
    });
    ctx
       ..fill()
       ..closePath()
       ..restore();
  }

  @override
  bool checkProcessing() => true;
}