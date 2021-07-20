raum_hoehe = 245;
raum_durchmesser = 226;
cut_hoehe = 26;

regal_tiefe = 60;
regal_abstand = 40;

module draufsicht() {
    intersection() {
        difference() {
            circle(d = raum_durchmesser);
            circle(d = raum_durchmesser - regal_tiefe);
            square([50, raum_durchmesser], center = true);
        }
        translate([0, cut_hoehe, 0])
            square(raum_durchmesser, center = true);
    }
}

module ebene() {
    linear_extrude(3)
    draufsicht();    
}    

for(i = [regal_abstand:regal_abstand:raum_hoehe])
    translate([0, 0, i]) ebene();

