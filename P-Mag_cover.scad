include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

magY = 61.66;
magWithRibY = 64.21;
magX = 22.6;
magRibX = 11.8;

magBodyInteriorX = magX + 0.5;
magBodyInteriorY = magWithRibY + 0.5;

wallXY = 2;
wallZ = 2;

magBodyExteriorX = magBodyInteriorX + wallXY;
magBodyExteriorY = magBodyInteriorY + wallXY;
magBodyExteriorZ = 10;

echo(str("magBodyExteriorX = ", magBodyExteriorX));
echo(str("magBodyExteriorY = ", magBodyExteriorY));

magBodyExteriorDia = 6;
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
        hull()
        {
            // tcu([], [magBodyInteriorX, magBodyInteriorY, 100]);
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
