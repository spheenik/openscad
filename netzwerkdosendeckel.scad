$fn=90;

l = 80;
r = 4;
h = 2;

la = 60;

eps = 0.01;

module deckel() {
    linear_extrude(height = h)
    minkowski() {
        square(l - r*2, center=true);
        circle(r);
    }
}

module loch() {
    translate([0, 0, -eps])
    cylinder(h = h + 2 * eps, r1 = 1.5, r2 = 3);
}

difference() {
    deckel();
    translate([0, -la/2, 0]) loch();
    translate([0, la/2, 0]) loch();
}
