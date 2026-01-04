include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

magY = 60.56; //61.66;
magWithRibY = 64.14;
magX = 22.6;
magRibX = 11.8;
magRibOffsetZ = 11.17;
magFrontStepZ = 4.3;

magBodyInteriorX = magX; // + 0.5;
magBodyInteriorRibX = magRibX; // + 0.5;
magBodyInteriorY = magY + 0.5;
magBodyInteriorWithRibY = magWithRibY + 0.5;

wallXY = 3;
wallZ = 2;

magBodyExteriorX = magBodyInteriorX + 2*wallXY;
magBodyExteriorY = magBodyInteriorWithRibY + 2*wallXY;
magBodyExteriorZ = 17;

echo(str("magBodyExteriorX = ", magBodyExteriorX));
echo(str("magBodyExteriorY = ", magBodyExteriorY));

magBodyExteriorDia = 5;
magBodyExteriorCZ = 2;

exteriorXYCtrX = magBodyExteriorX/2 - magBodyExteriorDia/2;
exteriorXYCtr1Y = magBodyExteriorDia/2;
exteriorXYCtr2Y = magBodyExteriorY - magBodyExteriorDia/2;

module itemModule()
{
	difference()
    {
        // Exterior:
        hull() 
        {
            doubleX() translate([exteriorXYCtrX,0,0]) 
            {
                translate([0,exteriorXYCtr1Y,0]) simpleChamferedCylinderDoubleEnded(d=magBodyExteriorDia, h=magBodyExteriorZ, cz=magBodyExteriorCZ);
                translate([0,exteriorXYCtr2Y,0]) simpleChamferedCylinderDoubleEnded(d=magBodyExteriorDia, h=magBodyExteriorZ, cz=magBodyExteriorCZ);
            }
        }

        // Interior: 
        frontStepY = 5;
        frontY = frontStepY + wallXY;
        // Full width recess:
        tcu([-magBodyInteriorX/2, frontY, wallZ], [magBodyInteriorX, magBodyInteriorY-frontStepY, 200]);
        // Front Step:
        tcu([-magBodyInteriorX/2, wallXY, wallZ+magFrontStepZ], [magBodyInteriorX, magBodyInteriorY, 200]);
        // Rear rib recess:
        tcu([-magBodyInteriorRibX/2, frontY, wallZ+magRibOffsetZ], [magBodyInteriorRibX, magBodyInteriorWithRibY-frontStepY, 200]);
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
