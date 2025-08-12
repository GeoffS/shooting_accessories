include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

brassOD = 5.75 + 0.3;
brassRimOD = 6.9 + 0.25 ;
brassRimThickness = 1.1;
cartridgeLen = 26;

cartridgeSpacingX = 20;
cartridgeSpacingY = 20;

cartridgeAreaOutsideX = 12;
cartridgeAreaOutsideY = 6;

cartridgeRecessDia = brassRimOD;
cartridgeRecessZ = 13;
cartridgeRecessOffsetZ = 3;

numCartridgesPerRow = 5;
numRows = 8;

baseX = 2*cartridgeAreaOutsideX + (numCartridgesPerRow-1) * cartridgeSpacingX;
baseY = 2*cartridgeAreaOutsideY + numRows * cartridgeSpacingY;
baseZ = cartridgeRecessZ + cartridgeRecessOffsetZ;

holderBaseCornerDia = 20;

holderBaseCZ = 2;

holderBaseCornerOffsetX = baseX/2 - holderBaseCornerDia/2;
holderBaseCornerOffsetY = baseY/2 - holderBaseCornerDia/2;

module itemModule()
{
	difference() 
    {
        // Base exterior:
		hull() doubleX() doubleY() 
            translate([holderBaseCornerOffsetX, holderBaseCornerOffsetY, 0]) 
                simpleChamferedCylinderDoubleEnded(d=holderBaseCornerDia, h=baseZ, cz=holderBaseCZ);

        // Cartridge holes:
        translate([-baseX/2, -baseY/2, 0]) 
        {
            for(rowIndex = [0 : (numRows-1)])
            {
                y = cartridgeAreaOutsideY + (rowIndex+0.5) * cartridgeSpacingY;
                echo(str("y = ", y));
                for(columnIndex = [0 : (numCartridgesPerRow-1)])
                {
                    x = cartridgeAreaOutsideX + columnIndex*cartridgeSpacingX;
                    echo(str("x = ", x));
                    cartridgeRecess(x, y);
                }
            }
        }
    }
}

module cartridgeRecess(x, y)
{
    translate([x, y, 0])
    {
        tcy([0,0,cartridgeRecessOffsetZ], d=cartridgeRecessDia, h=100);
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
