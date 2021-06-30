radius = 10;
thickness = 0.5;
steps = 6;
step_angle = 360/steps;
recursion_depth = 3;
offset_angle_leaf = asin(thickness/radius);
offset_angle_tri = 12; // guesstimate...
equi_tri_height = radius/2 * sqrt(3);

// basic hollow circle
module base(center) {
    translate(center)
    difference() {
        circle(radius + thickness/2);
        circle(radius - thickness/2);
    }
}

// ...recursively spread
module cluster(center, depth) {
    
    if (depth) {
          points = [ for (i = [0:steps]) 
              let( 
                    angle = i * 360 / steps                
              ) 
              [radius*cos(angle) + center[0], radius*sin(angle) + center[1]]
          ];
        //base(center); // redundant when recursive
        for (i = [0:steps]) {
            base(points[i]);
            cluster(points[i], depth - 1);
        }
    }
    else {
    }
}

module leaf(center, seg_num) {    
    points_outer = arc(center, seg_num, -1, offset_angle_leaf);    
    points_inner = arc([center[0] + 2*equi_tri_height*sin(normal(seg_num))  , center[1] + 2*equi_tri_height*cos(normal(seg_num))], seg_num + steps/2, -1, offset_angle_leaf);
    polygon(concat(points_inner, points_outer));    
}

module tri(center, seg_num) {
    points_1 = arc([center[0] + 2*equi_tri_height*sin(normal(seg_num))  , center[1] + 2*equi_tri_height*cos(normal(seg_num))], seg_num + steps/2, 1, offset_angle_tri);
    points_2 = arc(get_node(center, seg_num+2), seg_num+(steps-1), 1, offset_angle_tri);
    points_3 = arc(get_node(center, seg_num-1), seg_num+(steps+1), 1, offset_angle_tri);
    polygon(concat(points_1, points_3, points_2));
}

// returns (n=steps) nodes surrounding center
function get_nodes(center) =     
    [
        for(a = [step_angle/2:step_angle:step_angle*(steps-0.5)]) [center[0] + sin(a) * radius , center[1] + cos(a) * radius]
    ];
        
//color("green") polygon(concat(get_nodes([0,0])));

// returns nth node surrounding center        
function get_node(center, seg_num) = 
        let (a = seg_num * step_angle + step_angle/2)
        [center[0] + sin(a) * radius , center[1] + cos(a) * radius];

// returns centered orthogonal angle        
function normal(seg_num) = (seg_num + 0.5) * step_angle + step_angle/2;

function arc(center, seg_num, polarity, offset_a) = 
    let (angles = [seg_num * step_angle + step_angle/2 + offset_a, (seg_num + 1) * step_angle + step_angle/2 - offset_a]) 
        [
            for(a = [angles[0]:10:angles[1]]) [center[0] + (radius + polarity*thickness/2) * sin(a), center[1] + (radius + polarity*thickness/2) * cos(a)]
        ];
            
module flower(center, depth) {
    
    if (depth) {
        for (n = [0:1:steps]) leaf(center, n);
        for (n = [0:1:steps]) tri(center, n);
            
        for (i = [0:steps]) {
            leaf(get_node(center,i), i+steps/2);
            flower(get_node(center,i), depth -1);
        }
    }
    else {        
    }
}

flower([0,0], 4);



