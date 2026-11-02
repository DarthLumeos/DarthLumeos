// Holder that keeps a Yonvim DC339 / DC339CT (Style-B) dash cam against the
// outside of a Bambu Lab P1S (or X1) glass door.
//
// The lens faces the glass. The screen faces the room. Two screws already in
// the upper door hinge (the bar marked SJ-TOP) carry the mount. Nothing is
// drilled, and the door still comes off the way it does now.
//
// Measure the camera and edit the Camera block if it is not the size below.
// The listing says 0.78 x 3.62 x 1.67 in, which is 19.8 x 91.9 x 42.4 mm.
// Height is the body only. The flip-up windshield bracket sticks out the
// open middle of the top and is not part of that height.
//
// Re-export one part:
//   openscad -D 'part="cradle"' -o cradle.stl p1s_dashcam_mount.scad
// part: rail, arm, cradle, retainer, shim, pin, assembly, section

/* [Camera] */
camera_w = 92.0;
camera_h = 43.0;
camera_d = 21.0;
play = 0.7;

/* [Mount] */
// Glass-contact face of the front posts, measured from the hinge-screw
// centerline toward the room. Shims move the camera further into the room
// if the posts press too hard on the glass.
post_face_y = 3.0;
flange_t = 2.0;
rail_len = 128;
slot_len = 100;
slot_w = 4.4;

/* [Hardware] */
pin_d = 4.9;
pin_hole = 5.6;
m3_hole = 3.4;
pin_from_plate = 2.2;   // retainer pin is this far toward the glass from the plate

/* [Export] */
part = "assembly";
shim_t = 1.5;

/* [Hidden] */
$fn = 48;
iw = camera_w + 2 * play;
ih = camera_h + 2 * play;
wt = 3.6;
ft = 3.4;
bearing_y = 2.4;
plate_t = 3.2;
// Room-side clearance between the retainer plate and the arm.
arm_gap = 7.0;
rail_glass_y = bearing_y + camera_d + 1.4 + plate_t + arm_gap;
rail_t = 7.0;
pin_boss_w = 9.2;
pin_x = iw / 2 + 0.8 + pin_boss_w / 2;
pad_w = 16;
// Pad overlaps the side wall so the cradle is one piece.
pad_x = iw / 2 + wt - 0.6 + pad_w / 2;
pin_ys = [15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45];
eps = 0.04;

function snap_pin() =
    let (
        camera_back = bearing_y + camera_d,
        want = camera_back + 0.8 - pin_from_plate,
        fit = [for (y = pin_ys) if (y + 0.01 >= want) y]
    )
    len(fit) == 0 ? pin_ys[len(pin_ys) - 1] : min(fit);

module slot_y(x, z0, z1, y0, depth) {
    hull() {
        translate([x, y0 - 1, z0])
            rotate([-90, 0, 0])
                cylinder(d = m3_hole, h = depth + 2);
        translate([x, y0 - 1, z1])
            rotate([-90, 0, 0])
                cylinder(d = m3_hole, h = depth + 2);
    }
}

// ---------------------------------------------------------------------------
// Hinge rail. Flange sits on the door top, under the SJ-TOP screws.
// ---------------------------------------------------------------------------
module hinge_rail() {
    lip_h = 30;
    lip_t = 8;
    lip_y0 = 12;
    flange_y0 = -6;
    difference() {
        union() {
            translate([-rail_len / 2, flange_y0, -flange_t])
                cube([rail_len, lip_y0 - flange_y0 + 0.4, flange_t]);
            translate([-rail_len / 2, lip_y0 - 0.2, -lip_h])
                cube([rail_len, lip_t + 0.2, lip_h]);
        }
        hull() {
            translate([-slot_len / 2, 0, -flange_t - 1])
                cylinder(d = slot_w, h = flange_t + 2);
            translate([ slot_len / 2, 0, -flange_t - 1])
                cylinder(d = slot_w, h = flange_t + 2);
        }
        for (x = [-36:12:36])
            translate([x, lip_y0 - 1, -16])
                rotate([-90, 0, 0])
                    cylinder(d = pin_hole, h = lip_t + 2);
    }
}

// ---------------------------------------------------------------------------
// Drop arm. Slides onto the lip from either end, then jogs into the room
// so the lower rails clear the camera.
// ---------------------------------------------------------------------------
module drop_arm() {
    hook_x0 = -18;
    hook_x1 = 18;
    room_y0 = 20.35;
    room_y1 = 24.6;
    spine_y0 = 20.35;
    spine_y1 = 27.6;
    rail_y0 = rail_glass_y;
    rail_y1 = rail_glass_y + rail_t;
    rail_top = -84;
    rail_bot = -232;

    difference() {
        union() {
            translate([hook_x0, room_y0, -31.6])
                cube([hook_x1 - hook_x0, room_y1 - room_y0, 27.0]);
            // Underside catch. Stops short of the door frame (frame face ~ y=12).
            translate([hook_x0, 14.4, -34.6])
                cube([hook_x1 - hook_x0, room_y1 - 14.4, 4.2]);
            translate([-15, spine_y0, -50])
                cube([30, spine_y1 - spine_y0, 18]);
            // Two braces, one into each lower rail, instead of a solid wedge.
            for (s = [-1, 1])
                hull() {
                    translate([-12, spine_y0, -50])
                        cube([24, spine_y1 - spine_y0, 2]);
                    translate([s * pad_x - (pad_w / 2) - 1, rail_y0, rail_top])
                        cube([pad_w + 2, rail_t, 2]);
                }
            for (s = [-1, 1])
                translate([s * pad_x - pad_w / 2 - 1, rail_y0, rail_bot])
                    cube([pad_w + 2, rail_t, rail_top - rail_bot]);
            translate([-pad_x - pad_w / 2 - 1, rail_y0, rail_bot])
                cube([2 * pad_x + pad_w + 2, rail_t, 10]);
            // Cable hook on the right rail.
            translate([pad_x + pad_w / 2 + 1, rail_y0, -150])
                cube([8, rail_t, 22]);
            translate([pad_x + pad_w / 2 + 1, rail_y1 - 2.4, -150])
                cube([8, 2.4, 6]);
        }
        for (x = [-12, 12])
            translate([x, room_y0 - 1, -16])
                rotate([-90, 0, 0])
                    cylinder(d = pin_hole, h = room_y1 - room_y0 + 2);
        // Slot stops high enough that the camera body cannot climb into the braces.
        for (s = [-1, 1])
            slot_y(s * pad_x, -210, -108, rail_y0, rail_t);
        // Open the cable hook into a sideways slot.
        translate([pad_x + pad_w / 2 - 1, rail_y0 + 2.2, -144])
            cube([14, rail_t, 10]);
    }
}

// ---------------------------------------------------------------------------
// Cradle. Same coordinates as the assembly, plus a later translate that
// plants the posts on the glass and drops the pocket down the door.
// ---------------------------------------------------------------------------
module cradle() {
    x0 = -iw / 2 - wt;
    x1 =  iw / 2 + wt;
    mate_y = rail_glass_y - post_face_y;

    difference() {
        union() {
            translate([x0, -0.2, -ft])
                cube([x1 - x0, mate_y + 0.2, ft]);
            for (s = [-1, 1])
                translate([s > 0 ? iw / 2 : x0, -0.2, -ft])
                    cube([wt, mate_y + 0.2, ih + ft]);
            for (sx = [-1, 1], sz = [0, 1])
                translate([
                    sx > 0 ? iw / 2 - 6.5 : -iw / 2,
                    0,
                    sz > 0 ? ih - 7.5 : 0
                ])
                    cube([6.5, bearing_y, 7.5]);
            // Bolt pads, full contact with the bed when the floor is down.
            for (s = [-1, 1])
                translate([s * pad_x - pad_w / 2, mate_y - 24, -ft])
                    cube([pad_w, 24, 38]);
            // Pin bosses outside the pocket. They stop at the top of the wall
            // so the retainer tabs can sit on them.
            for (s = [-1, 1])
                translate([s * pin_x - pin_boss_w / 2, 12, ih - 14])
                    cube([pin_boss_w, max(10, mate_y - 16), 14]);
        }
        // Cable exit. A strip of floor along the glass edge keeps left and right joined.
        translate([-24, 5, -ft - 1])
            cube([48, mate_y, ft + 2]);
        // microSD finger notches, open toward the room.
        for (s = [-1, 1])
            translate([
                s > 0 ? iw / 2 - 0.1 : -iw / 2 - wt - 0.1,
                mate_y - 12,
                ih * 0.35
            ])
                cube([wt + 0.4, 14, 12]);
        for (s = [-1, 1], z = [10, 28])
            translate([s * pad_x, mate_y - 28, z])
                rotate([-90, 0, 0])
                    cylinder(d = m3_hole, h = 32);
        for (s = [-1, 1], y = pin_ys)
            if (y >= 14 && y <= mate_y - 6)
                translate([s * pin_x, y, ih - 14])
                    cylinder(d = 5.2, h = 22);
    }
}

// ---------------------------------------------------------------------------
// Retainer, in cradle coordinates. One pin hole per side; it lands on the
// cradle hole that puts the plate just behind this camera depth.
// ---------------------------------------------------------------------------
module retainer() {
    pin_y = snap_pin();
    plate_inner = pin_y + pin_from_plate;
    // Plate covers the camera back only. It stays clear of the pin bosses,
    // which stand just outside the pocket. Tabs on top tie the plate to the pins.
    difference() {
        union() {
            translate([-iw / 2, plate_inner, 0])
                cube([iw, plate_t, ih]);
            for (s = [-1, 1])
                translate([s > 0 ? iw / 2 - 14 : -pin_x - pin_boss_w / 2, 6, ih])
                    cube([pin_x + pin_boss_w / 2 - (iw / 2 - 14), plate_inner + plate_t - 6, 3.8]);
            for (s = [-1, 1])
                translate([s > 0 ? iw / 2 - 12 : -iw / 2, 3, ih])
                    cube([12, 16, 3.8]);
        }
        translate([-iw / 2 + 8, plate_inner - 1, 6.5])
            cube([iw - 16, plate_t + 2, ih - 13]);
        for (s = [-1, 1])
            translate([s * pin_x, pin_y, ih - 1])
                cylinder(d = 5.2, h = 8);
    }
}

module shim() {
    difference() {
        cube([pad_w, 36, shim_t]);
        for (z = [10, 28])
            translate([pad_w / 2, z, -1])
                cylinder(d = m3_hole, h = shim_t + 2);
    }
}

module pin() {
    cylinder(d = 8.6, h = 2.3);
    translate([0, 0, 2.3])
        cylinder(d = pin_d, h = 15);
    translate([0, 0, 17.3])
        cylinder(d1 = pin_d, d2 = pin_d - 1.6, h = 1.5);
}

module camera_mock() {
    translate([-camera_w / 2, post_face_y + bearing_y, -168])
        cube([camera_w, camera_d, camera_h]);
    translate([-15, post_face_y + bearing_y + 3, -168 + camera_h])
        cube([30, 12, 15]);
    translate([camera_w * 0.16, post_face_y + 0.15, -168 + camera_h / 2])
        rotate([90, 0, 0])
            cylinder(d = min(24, camera_h - 12), h = 1.4);
}

module assembly() {
    color("AliceBlue", 0.45)
        translate([-90, post_face_y - 1.2, -250])
            cube([180, 1.2, 250]);
    color("SteelBlue") hinge_rail();
    color("DimGray") drop_arm();
    color("BurlyWood") translate([0, post_face_y, -168]) cradle();
    color("Wheat") translate([0, post_face_y, -168]) retainer();
    color("Gainsboro") camera_mock();
}

module section() {
    intersection() {
        assembly();
        translate([-8, -30, -260])
            cube([8, 140, 280]);
    }
}

module export_part() {
    if (part == "rail")
        rotate([180, 0, 0]) hinge_rail();
    else if (part == "arm")
        translate([0, 0, rail_glass_y + rail_t])
            rotate([-90, 0, 0])
                drop_arm();
    else if (part == "cradle")
        translate([0, 0, ft])
            cradle();
    else if (part == "retainer")
        // Outer face of the back plate on the bed. Tabs and lips print upward.
        translate([0, 0, snap_pin() + pin_from_plate + plate_t])
            rotate([-90, 0, 0])
                retainer();
    else if (part == "shim")
        shim();
    else if (part == "pin")
        translate([0, 0, 4.4])
            rotate([0, 90, 0])
                pin();
    else if (part == "assembly")
        assembly();
    else if (part == "section")
        section();
}

export_part();

echo("pocket_mm", iw, ih);
echo("pad_x", pad_x);
echo("pin_x", pin_x);
echo("rail_glass_y", rail_glass_y);
echo("retainer_pin_y", snap_pin());
echo("plate_inner_y", snap_pin() + pin_from_plate);
echo("camera_back_y", bearing_y + camera_d);
echo("gap_behind_camera_mm", (snap_pin() + pin_from_plate) - (bearing_y + camera_d));
