include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

layerThickness = 0.2;

makeHolder = false;
makeLoader = false;

brassOD = 5.75 + 0.3;
brassRimOD = 6.9 + 0.25 ;
brassRimThickness = 1.1;
cartridgeLen = 26;

cartridgeBoxSpacingY = 7.52;
cartridgeBoxLipZ = 2.2;
cartridgeBoxLipX = 39;

cartridgeSpacingX = 17;
cartridgeSpacingY = 20;

holderBaseCZ = 2;

incrementZ = holderBaseCZ + 2;

cartridgeAreaOutsideX = 14;
cartridgeAreaOutsideY = 4;

cartridgeRecessDia = brassOD;
cartridgeRecessZ = 13;
cartridgeRecessOffsetZ = 3;
cartridgeRecessCZ = 4*layerThickness;

numCartridgesPerRow = 5;
numRows = 3;

baseX = 2*cartridgeAreaOutsideX + (numCartridgesPerRow-1) * cartridgeSpacingX;
baseY = numRows * cartridgeSpacingY;
baseZ = cartridgeRecessZ + cartridgeRecessOffsetZ;

holderBaseCornerDia = cartridgeSpacingY + holderBaseCZ;

holderBaseCornerOffsetX = baseX/2 - holderBaseCornerDia/2;
holderBaseCornerOffsetY = baseY;
holderBaseCornerOffsetZ = cartridgeRecessZ + cartridgeRecessOffsetZ + ((numRows)*incrementZ);

echo(str("holderBaseCornerOffsetZ = ", holderBaseCornerOffsetZ));

module loader()
{

}

module holder()
{
    difference()
    {
        union()
        {
            // Exterior steps except the last one:
            for(rowIndex = [0 : (numRows-1)])
            {
                z = cartridgeRecessZ + cartridgeRecessOffsetZ + (rowIndex*incrementZ);
                y = rowIndex * cartridgeSpacingY;
                echo(str("Exterior y = ", y));

                hull() 
                {
                    step(y, z);
                    step(holderBaseCornerOffsetY, z);
                }
            }
            // Last (biggest Y) step:
            hull() step(holderBaseCornerOffsetY, holderBaseCornerOffsetZ);
        }
                
        // Cartridge recesses except the last one:
        for(rowIndex = [0 : (numRows-1)])
        {
            z = cartridgeRecessZ + cartridgeRecessOffsetZ + (rowIndex*incrementZ);
            y = rowIndex * cartridgeSpacingY;

            cartridgeRecesses(y, z);
        }

        // Text on top step:
        ts = 5.2;
        translate([0, holderBaseCornerOffsetY-(ts*0.1), holderBaseCornerOffsetZ-layerThickness])
        {
            makeText(text="22lr Cartridge Holder", textSize=ts, spacing=1.15);
        }
    }

}

module makeText(
	text="Hello World",
	textSize = 6,
	spacing = 1.0,
	font="Arial:style=Bold",
	halign="center",
	valign="center")
{
	echo("makeText: text = ", text);
	echo("makeText: textSize = ", textSize);
	echo("makeText: font = ", font);
	echo("makeText: halign = ", halign);
	echo("makeText: valign = ", valign);
	linear_extrude(height = 2)
	{
	text(
		text=text,
		font=font,
		size=textSize,
		spacing=spacing,
		halign=halign,
		valign=valign);
	}
}

module step(y, z)
{
    translate([0,y,0])
        doubleX()
            translate([holderBaseCornerOffsetX, 0, 0]) 
                simpleChamferedCylinderDoubleEnded(d=holderBaseCornerDia, h=z, cz=holderBaseCZ);
}

module cartridgeRecesses(y, z)
{
    echo(str("Recess y = ", y));
    for(columnIndex = [0 : (numCartridgesPerRow-1)])
    {
        x = cartridgeAreaOutsideX + columnIndex*cartridgeSpacingX - baseX/2;
        cartridgeRecess(x, y, z);
    }
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
	// display() holder();

    displayGhost() translate([0,0,-(cartridgeRecessZ + cartridgeRecessOffsetZ)]) holder();
    display() loader();
}
else
{
	if(makeHolder) holder();
    if(makeLoader) loader();
}
