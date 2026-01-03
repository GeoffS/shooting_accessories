include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

magY = 61.66;
magWithRibY = 64.21;
magX = 22.6;
magRibX = 11.8;

magBodyInteriorX = magX + 0.5;
magBodyInteriorRibX = magRibX + 0.5;
magBodyInteriorY = magY + 0.5;
magBodyInteriorWithRibY = magWithRibY + 0.5;

wallXY = 3;
wallZ = 2;

magBodyExteriorX = magBodyInteriorX + 2*wallXY;
magBodyExteriorY = magBodyInteriorWithRibY + 2*wallXY;
magBodyExteriorZ = 10;

echo(str("magBodyExteriorX = ", magBodyExteriorX));
echo(str("magBodyExteriorY = ", magBodyExteriorY));

magBodyExteriorDia = 5;
magBodyExteriorCZ = 2;

exteriorXYCtrX = magBodyExteriorX/2 - magBodyExteriorDia/2;
exteriorXYCtr1Y = magBodyExteriorDia/2;
exteriorXYCtr2Y = magBodyExteriorY - magBodyExteriorDia/2;

// interiorXYCtrX = magBodyInteriorX/2 - magBodyInteriorDia/2;
// interiorXYCtr1Y = magBodyInteriorDia/2;
// interiorXYCtr2Y = magBodyInteriorY - magBodyInteriorDia/2;

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
        tcu([-magBodyInteriorX/2, wallXY, wallZ], [magBodyInteriorX, magBodyInteriorY, 200]);
        tcu([-magBodyInteriorRibX/2, wallXY, wallZ], [magBodyInteriorRibX, magBodyInteriorWithRibY, 200]);
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
