package opentype;

class BoundingBox {
	public function new() {}

	public var x1(default, null):Float = null;
	public var y1(default, null):Float = null;
	public var x2(default, null):Float = null;
	public var y2(default, null):Float = null;

	public function addPoint(x:Float, y:Float) {
		if (x != null) {
			if (this.x1 == null || this.x2 == null) {
				this.x1 = x;
				this.x2 = x;
			}
			if (x < this.x1)
				this.x1 = x;
			if (x > this.x2)
				this.x2 = x;
		}
		if (y != null) {
			if (this.y1 == null || this.y2 == null) {
				this.y1 = y;
				this.y2 = y;
			}
			if (y < this.y1)
				this.y1 = y;
			if (y > this.y2)
				this.y2 = y;
		}
	}

	public function addX(x:Float)
		this.addPoint(x, null);

	public function addY(y:Float)
		this.addPoint(null, y);

	public function isEmpty():Bool
		return this.x1 == null || this.y1 == null || this.x2 == null || this.y2 == null;

	function derive(v0:Float, v1:Float, v2:Float, v3:Float, t:Float)
		return Math.pow(1 - t, 3) * v0 + 3 * Math.pow(1 - t, 2) * t * v1 + 3 * (1 - t) * Math.pow(t, 2) * v2 + Math.pow(t, 3) * v3;

	public function addBezier(x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float, x:Float, y:Float) {
		// This code is based on http://nishiohirokazu.blogspot.com/2009/06/how-to-calculate-bezier-curves-bounding.html
		// and https://github.com/icons8/svg-path-bounding-box

		final p0 = [x0, y0];
		final p1 = [x1, y1];
		final p2 = [x2, y2];
		final p3 = [x, y];

		this.addPoint(x0, y0);
		this.addPoint(x, y);

		for (i in 0...1) {
			final b = 6 * p0[i] - 12 * p1[i] + 6 * p2[i];
			final a = -3 * p0[i] + 9 * p1[i] - 9 * p2[i] + 3 * p3[i];
			final c = 3 * p1[i] - 3 * p0[i];

			if (a == 0) {
				if (b == 0)
					continue;
				final t = -c / b;
				if (0 < t && t < 1) {
					if (i == 0)
						this.addX(derive(p0[i], p1[i], p2[i], p3[i], t));
					if (i == 1)
						this.addY(derive(p0[i], p1[i], p2[i], p3[i], t));
				}
				continue;
			}

			final b2ac = Math.pow(b, 2) - 4 * c * a;
			if (b2ac < 0)
				continue;
			final t1 = (-b + Math.sqrt(b2ac)) / (2 * a);
			if (0 < t1 && t1 < 1) {
				if (i == 0)
					this.addX(derive(p0[i], p1[i], p2[i], p3[i], t1));
				if (i == 1)
					this.addY(derive(p0[i], p1[i], p2[i], p3[i], t1));
			}
			final t2 = (-b - Math.sqrt(b2ac)) / (2 * a);
			if (0 < t2 && t2 < 1) {
				if (i == 0)
					this.addX(derive(p0[i], p1[i], p2[i], p3[i], t2));
				if (i == 1)
					this.addY(derive(p0[i], p1[i], p2[i], p3[i], t2));
			}
		}
	}

	public function addQuad(x0:Float, y0:Float, x1:Float, y1:Float, x:Float, y:Float) {
		final cp1x = x0 + 2 / 3 * (x1 - x0);
		final cp1y = y0 + 2 / 3 * (y1 - y0);
		final cp2x = cp1x + 1 / 3 * (x - x0);
		final cp2y = cp1y + 1 / 3 * (y - y0);
		this.addBezier(x0, y0, cp1x, cp1y, cp2x, cp2y, x, y);
	};
}
