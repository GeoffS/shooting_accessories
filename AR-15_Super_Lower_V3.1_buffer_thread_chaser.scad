include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

guideOD = 28.75;
guideZ = 15; //30;
guideCZ = firstLayerHeight + 5*layerHeight;

echo(str("guideCZ = ", guideCZ));

tapOD = 10;
tapOffsetAdj = 0.5;
tapRecessCtr = guideOD/2 - tapOD/2 + tapOffsetAdj;

tapFlutesID = 5.1;

tapFlutesInnerDia = 3.6;
tapFlutesInnerOffset = tapFlutesID/2 + tapFlutesInnerDia/2;
tapFlutesOuterDia = tapFlutesInnerDia;
tapFlutesOuterOffset = tapFlutesInnerOffset + tapFlutesInnerDia/2;
tapFlutesOuterAngle = 0;

// md = 2;

// guideODBeforeMinkowski = 28.8; //28.7; //29.5;
// guideOD = guideODBeforeMinkowski - md;
// guideZBeforeMinkowski = 28;

// guideZ = guideZBeforeMinkowski - md;
// tapODBeforeMinkowski = 10; // (3/8) * 25.4; // 3/8 inch in mm
// echo(str("tapODBeforeMinkowski = ", tapODBeforeMinkowski));
// tapOD = tapODBeforeMinkowski + md;
// tapOffsetAdj = 0.3; //0.1;

// tapRecessCtr = guideOD/2 - tapODBeforeMinkowski/2 + tapOffsetAdj + md/2;

// // $fn=180;

// tapOpeningAngle = 0;

// // Bumps to index into the tap:
// bumpDia = 3.6; //3.8; //4.0;
// bumpsID = 5.1; //5.3; //4.7;

module tap()
{
    translate([tapRecessCtr, 0, -10]) difference()
    {
        // Core:
        translate([0, 0, -10]) cylinder(d=tapOD, h=200);

        // Flutes:
        for (a = [45, -45, 135, -135]) rotate([0,0,a])
        {
            hull()
            {
                translate([tapFlutesInnerOffset,0,-20]) cylinder(d=tapFlutesInnerDia, h=300);
                rotate([0,0,tapFlutesOuterAngle]) translate([tapFlutesOuterOffset,0,-20]) cylinder(d=tapFlutesOuterDia, h=300);
            }
        }
    }
}

module itemModule()
{
    difference()
    {
        simpleChamferedCylinderDoubleEnded(d=guideOD, h=guideZ, cz=guideCZ);

        tap();
    }
    // translate([0, 0, md/2]) minkowski() 
    // {
    //     difference()
    //     {
    //         union()
    //         {
    //             difference()
    //             {
    //                 cylinder(d=guideOD, h=guideZ);

    //                 // // Tap opening:
    //                 // translate([tapRecessCtr, 0, -10]) 
    //                 // {
    //                 //     #hull() doubleY() rotate([0,0,tapOpeningAngle]) tcu([0,-0.1,0], [30, 0.1, 100]);
    //                 // }
    //             }
    //         }

    //         // Tap recess:
    //         translate([tapRecessCtr, 0, -10])
    //         {
    //             tcy([0,0,-10], d=tapOD, h=100);
    //         }
    //     }

    //     minkowskiShape();
    // }

    // // Bumps to index into the tap:
    // translate([tapRecessCtr, 0, 0]) 
    //     for (a = [45, -45]) rotate([0,0,a]) hull()
    //     {
    //         translate([-bumpsID/2-bumpDia/2, 0, 0]) simpleChamferedCylinderDoubleEnded(d=bumpDia, h=guideZBeforeMinkowski, cz=md/2);
    //         translate([-10, 0, 0]) simpleChamferedCylinderDoubleEnded(d=bumpDia, h=guideZBeforeMinkowski, cz=md/2);
    //     }
}

// module minkowskiShape()
// {
//     doubleZ() cylinder(d1=md, d2=0, h=md/2);
// }

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();

    // displayGhost() tcy([tapRecessCtr,0,0], d=3/8*25.4, h=100);
    displayGhost() tcy([tapRecessCtr,0,0], d=tapFlutesID, h=guideZ);
    // displayGhost() difference()
    // {
    //     tcy([0,0,-5], d=guideODBeforeMinkowski+10, h=guideZBeforeMinkowski+10);
    //     tcy([0,0,-50], d=guideODBeforeMinkowski, h=200);
    // }

    // display() minkowskiShape();
}
else
{
	itemModule();
}
