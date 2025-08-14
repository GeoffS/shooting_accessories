include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

layerThickness = 0.2;

brassOD = 5.75 + 0.3;
brassRimOD = 6.9 + 0.25 ;
brassRimThickness = 1.1;
cartridgeLen = 26;

cartridgeSpacingX = 20;
cartridgeSpacingY = 20;

holderBaseCZ = 2;

incrementZ = holderBaseCZ + 1;

cartridgeAreaOutsideX = 14;
cartridgeAreaOutsideY = 4;

cartridgeRecessDia = brassOD;
cartridgeRecessZ = 13;
cartridgeRecessOffsetZ = 3;
cartridgeRecessCZ = 4*layerThickness;

numCartridgesPerRow = 5;
numRows = 6;

baseX = 2*cartridgeAreaOutsideX + (numCartridgesPerRow-1) * cartridgeSpacingX;
baseY = 2*cartridgeAreaOutsideY + numRows * cartridgeSpacingY;
baseZ = cartridgeRecessZ + cartridgeRecessOffsetZ;

holderBaseCornerDia = 20;

holderBaseCornerOffsetX = baseX/2 - holderBaseCornerDia/2;
holderBaseCornerOffsetY = baseY/2 - holderBaseCornerDia/2;
holderStepCornerOffsetY = cartridgeSpacingY/2 - holderBaseCornerDia/2;

echo(str("holderStepCornerOffsetY = ", holderStepCornerOffsetY));

module itemModule()
{
    // Base:
	// hull() doubleX() doubleY() 
    //     translate([holderBaseCornerOffsetX, holderBaseCornerOffsetY, 0]) 
    //         simpleChamferedCylinderDoubleEnded(d=holderBaseCornerDia, h=cartridgeRecessOffsetZ, cz=holderBaseCZ);

    difference()
    {
        // Step exterior:
        for(rowIndex = [0 : (numRows-1)])
        {
            z = cartridgeRecessZ + cartridgeRecessOffsetZ + (rowIndex*incrementZ);
            y = cartridgeAreaOutsideY + (rowIndex+0.5) * cartridgeSpacingY - baseY/2;

            hull() 
            {
                step(y, z);
                step(holderBaseCornerOffsetY, z);
            }
        }
                
        // Cartridge recesses:
        for(rowIndex = [0 : (numRows-1)])
        {
            z = cartridgeRecessZ + cartridgeRecessOffsetZ + (rowIndex*incrementZ);
            y = cartridgeAreaOutsideY + (rowIndex+0.5) * cartridgeSpacingY - baseY/2;

            // echo(str("y = ", y));
            for(columnIndex = [0 : (numCartridgesPerRow-1)])
            {
                x = cartridgeAreaOutsideX + columnIndex*cartridgeSpacingX - baseX/2;
                // echo(str("x = ", x));
                cartridgeRecess(x, y, z);
            }
        }
    }

    // rowsXform()
    // {
    //     hull() 
    //     {
    //         step(y, z);
    //         step(holderBaseCornerOffsetY, z);
    //     }
    // }
}

// module rowsXform()
// {
//     for(rowIndex = [0 : (numRows-1)])
//     {
//         z = cartridgeRecessZ + cartridgeRecessOffsetZ + (rowIndex*incrementZ);
//         y = cartridgeAreaOutsideY + (rowIndex+0.5) * cartridgeSpacingY - baseY/2;
//         children(y, z);
//     }
// }

module step(y, z)
{
    translate([0,y,0])
        doubleX() doubleY() 
            translate([holderBaseCornerOffsetX, 2*holderBaseCZ, 0]) 
                simpleChamferedCylinderDoubleEnded(d=holderBaseCornerDia, h=z, cz=holderBaseCZ);
}

module cartridgeRecess(x, y, z)
{
    translate([x, y, 0])
    {
        tcy([0,0,z-cartridgeRecessZ], d=cartridgeRecessDia, h=100);
        translate([0,0,z-cartridgeRecessDia/2-cartridgeRecessCZ]) cylinder(d2=14, d1=0, h=7);
    }
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
    tcu([0+d, -200, -200], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
