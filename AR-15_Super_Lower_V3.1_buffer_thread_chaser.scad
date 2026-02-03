include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

guideOD = 29.5;
guideZ = 50;
guideCZ = 3;
tapOD = (3/8) * 25.4; // 3/8 inch in mm
tapOffsetAdj = 0.0;

tapRecessCtr = guideOD/2-tapOD/2+tapOffsetAdj;

tapOpeningY = 7;

$fn=180;

module itemModule()
{
	difference()
    {
        union()
        {
            difference()
            {
                simpleChamferedCylinderDoubleEnded(d=guideOD, h=guideZ, cz=guideCZ);

                // Tap opening trim:
                tcu([tapRecessCtr, -tapOpeningY/2, -10], [100, tapOpeningY, 100]);
            }

            // Tap opening trim rounding:
            tapOpeningRouindingDia = 2*1.125;
            tapOpeningRouindingCZ = tapOpeningRouindingDia/2;
            tapOpeningRouindingAngle = 14;
            tapOpeningRouindingZ = guideZ - 2*guideCZ + 2*tapOpeningRouindingCZ;
            tapOpeningRouindingOffsetZ = guideCZ - tapOpeningRouindingCZ;
            doubleY() 
                rotate([0,0,tapOpeningRouindingAngle]) 
                    translate([guideOD/2-tapOpeningRouindingDia/2,0,tapOpeningRouindingOffsetZ])
                        simpleChamferedCylinderDoubleEnded(d=tapOpeningRouindingDia, h=tapOpeningRouindingZ, cz=tapOpeningRouindingCZ);
        }

        // Tap recess:
        translate([tapRecessCtr, 0, -10])
        {
            tcy([0,0,-10], d=tapOD, h=100);
        }
    }

    
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
