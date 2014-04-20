part of shared;


class Transform extends Component {
  Vector2 pos;
  Transform(num x, num y) : pos = new Vector2(x.toDouble(), y.toDouble());
}

class Body extends Component {
  List<Vector2> vertices;
  Body(List<num> vertices) : vertices = new List.generate(vertices.length ~/ 2,
      (index) => new Vector2(vertices[index * 2].toDouble(), vertices[index * 2 + 1].toDouble()));
}
