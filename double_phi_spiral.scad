//$fn = 90;

n_rot = 5;
rotmax = 360;
rotstep = rotmax/n_rot;

//thetastep = 4;
thetastep = 20;
thetamax = 2*360;
n_theta = thetamax/thetastep;

scale = 12;
thickness = .05;

line_width = .4;

lamp_radius = 90;
lamp_z = lamp_radius*3/2;
lamp_thickness = line_width * 6;

signums = [-1, 1];

base_radius = 30;
base_height = 7;
base_thickness = 1;

phi = (1 + sqrt(5)) / 2; // =~ 1.618


function radius(theta) = base_radius + scale * (pow(phi, (theta / 90)) - 1);

function spiral(theta, m) = 
    let (d = radius(abs(theta)) * m)
        [sin(theta) * d, cos(theta) * d];

module projected_spiral(height) {
    for (ang = [0:rotstep:rotmax]) 
        rotate([0, 0, ang])
        for (signum = signums)
            let (iter = signum < 0 ? [n_theta:-1:0] : [0:n_theta], offs = 180/n_rot)
            polyhedron(
                points = [
                    /*  0 */ 
                    for (i = iter) 
                        concat(spiral(signum * (i * thetastep + offs), (1 + thickness)), [-height]),
                    /* (n_theta + 1) * 1 */ 
                    for (i = iter) 
                        concat(spiral(signum * (thetamax - i * thetastep + offs), (1 - thickness)), [-height]),
                    /* (n_theta + 1) * 2 */ 
                    [0, 0, 0],                    
                ]
                ,faces = [ 
                    for (i = [0:n_theta*2 + 1]) [
                        2 * n_theta + 2, 
                        i % (n_theta*2 + 2), 
                        (i + 1) % (n_theta * 2 + 2)
                    ]
                    ,[ for (i = [n_theta*2 + 1:-1:0]) i ]
                ],
                convexity=20
            );
}

module lamp_shell(z) {
    scale([1, 1, 1])
    difference() {
        sphere(lamp_radius);
        sphere(lamp_radius - lamp_thickness);
    }    
}

cyl_radius = base_radius*0.75;

module shell_support() {
    support_thickness = line_width * 1.0;
    scale([1, 1, 1])
    union() {
        difference() {
            sphere(lamp_radius);
            sphere(lamp_radius - support_thickness);
            cylinder(lamp_radius*4, cyl_radius, base_radius);
            translate([0, 0, lamp_radius]) cube(lamp_radius*2, center=true);
        }
        difference() {
            support_thickness = line_width * 1.0;
            sphere(lamp_radius - lamp_thickness + support_thickness);
            sphere(lamp_radius - lamp_thickness);
            cylinder(lamp_radius*4, cyl_radius, base_radius);
            translate([0, 0, -lamp_radius]) cube(lamp_radius*2, center=true);
        }    
    }
}

module shell_support2() {
    support_thickness = lamp_thickness / 2;
    intersection() {
        difference() {
            sphere(lamp_radius - lamp_thickness/2 + support_thickness/2);
            sphere(lamp_radius - lamp_thickness/2 - support_thickness/2);
            translate([0, 0, -lamp_radius*2]) cylinder(lamp_radius*4, cyl_radius, base_radius);
        };  
        step = 360/90;
        for (i = [0:step:360-step]) 
            rotate([0, 0, i])
                cube([line_width*1.5, lamp_radius*2, lamp_radius*2], center = true);
/*
        Linear extrude des Todes 
        
        for (i = [0:step:360 - step]) 
            rotate([0, 0, i])
                linear_extrude(lamp_radius*2, center = true, twist = 60, slices = 200)
                    square([line_width*1.5, lamp_radius*2], center = true);
*/
    }
}

module shell_support3() {
    thickness = 0.4;
    module z_view() {
        intersection() {
            difference() {
                offset(thickness/2) children(0);
                offset(-thickness/2) children(0);
            }
            difference() {
                offset(-thickness) hull() children(0);
                circle(base_radius * 0.7);
            }
        }
    }
    
    union() {
        linear_extrude(lamp_radius) z_view() projection() lamp();
        translate([0, 0, lamp_radius])
            intersection() {
                sphere(lamp_radius);
                linear_extrude(lamp_radius) z_view() projection() lamp();
            }
    }
}


module mirrored_projected_spiral(d) {
    union() {
        translate([0, 0, +d]) projected_spiral(lamp_z);
        translate([0, 0, -d]) projected_spiral(-lamp_z);
    }                
}

module lamp() {
    intersection() { 
        d_projection_center = lamp_radius*lamp_radius/(radius(thetamax - 36) - lamp_radius);
        lamp_shell();
        mirrored_projected_spiral(d_projection_center);
    }
}

module complete() {
    difference() {
        union() {
            translate([0, 0, lamp_radius]) lamp();
            cylinder(base_height, base_radius, base_radius);
        }
        translate([0,0, base_thickness]) 
            cylinder(base_height*2, base_radius - base_thickness, base_radius - base_thickness);
    }
    //shell_support3();
}

module bulb() {
    translate([0, 0, lamp_z]) sphere(5);
}

complete();
//shell_support3();
