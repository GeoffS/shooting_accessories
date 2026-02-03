include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

md = 2;

guideODBeforeMinkowski = 29.5;
guideOD = guideODBeforeMinkowski - md;
guideZBeforeMinkowski = 50;

guideZ = guideZBeforeMinkowski - md;
// guideCZ = 0; //3 - md/2;
tapODBeforeMinkowski = (3/8) * 25.4; // 3/8 inch in mm
tapOD = tapODBeforeMinkowski + md;
tapOffsetAdj = 0.3;

tapRecessCtr = guideOD/2 - tapODBeforeMinkowski/2 + tapOffsetAdj + md/2;

// $fn=180;

tapOpeningAngle = 0;

module itemModule()
{
    translate([0, 0, md/2]) minkowski() 
    {
        difference()
        {
            union()
            {
                difference()
                {
                    cylinder(d=guideOD, h=guideZ);

                    // // Tap opening:
                    // translate([tapRecessCtr, 0, -10]) 
                    // {
                    //     #hull() doubleY() rotate([0,0,tapOpeningAngle]) tcu([0,-0.1,0], [30, 0.1, 100]);
                    // }
                }
            }

            // Tap recess:
            translate([tapRecessCtr, 0, -10])
            {
                tcy([0,0,-10], d=tapOD, h=100);
            }
        }

        minkowskiShape();
    }

    // Bumps to index into the tap:
    bumpDia = 4.5;
    bumpAdh = 0.5;
    translate([tapRecessCtr, 0, 0]) 
        for (a = [45, -45]) 
        rotate([0,0,a]) translate([-tapODBeforeMinkowski/2-bumpAdh, 0, 0]) 
            simpleChamferedCylinderDoubleEnded(d = bumpDia, h = guideZBeforeMinkowski, cz = md/2);
}

module minkowskiShape()
{
    doubleZ() cylinder(d1=md, d2=0, h=md/2);
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();

    displayGhost() tcy([tapRecessCtr,0,0], d=3/8*25.4, h=100);
    displayGhost() difference()
    {
        tcy([0,0,-5], d=guideODBeforeMinkowski+10, h=guideZBeforeMinkowski+10);
        tcy([0,0,-50], d=guideODBeforeMinkowski, h=200);
    }

    // display() minkowskiShape();
}
else
{
	itemModule();
}
