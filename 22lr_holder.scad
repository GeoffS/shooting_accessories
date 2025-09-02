include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>
include <../OpenSCAD_Lib/torus.scad>

layerThickness = 0.2;

makeHolder = false;
makeLoader = false;
makeLoader2 = false;

brassClearanceOD = 5.75 + 0.6;
brassRimClearanceOD = 6.9 + 0.25;
brassRimThickness = 1.1;
cartridgeLen = 26;

echo(str("brassRimClearanceOD = ", brassRimClearanceOD));

cartridgeBoxSpacingX = 7.52;
cartridgeBoxLipZ = 2.2;
cartridgeBoxLipX = 39;
cartridgeBoxExteriorX = 43.5;

cartridgeSpacingX = 17;
cartridgeSpacingY = 20;

holderBaseCZ = 2;

incrementZ = holderBaseCZ + 2;

cartridgeAreaOutsideX = 14;
cartridgeAreaOutsideY = 4;

cartridgeRecessDia = brassClearanceOD;
cartridgeRecessZ = 13;
cartridgeRecessOffsetZ = 3;
cartridgeRecessCZ = 4*layerThickness;

numCartridgesPerRow = 5;
numRows = 5;

baseX = 2*cartridgeAreaOutsideX + (numCartridgesPerRow-1) * cartridgeSpacingX;
baseY = numRows * cartridgeSpacingY;
baseZ = cartridgeRecessZ + cartridgeRecessOffsetZ;

holderBaseCornerDia = cartridgeSpacingY + holderBaseCZ;

holderBaseCornerOffsetX = baseX/2 - holderBaseCornerDia/2;
holderBaseCornerOffsetY = baseY;
holderBaseCornerOffsetZ = cartridgeRecessZ + cartridgeRecessOffsetZ + ((numRows)*incrementZ);

echo(str("holderBaseCornerOffsetZ = ", holderBaseCornerOffsetZ));

loader2BaseCornerDia = 4;

loader2SubBaseX = baseX - 0.5;
loader2SubBaseY = 14;
loader2SubBaseOffsetY = holderBaseCornerDia/2 - 3; //-loader2SubBaseY/2 + holderBaseCZ;
loader2SubBaseZ = 4; //19*layerThickness;

echo(str("loader2SubBaseZ = ", loader2SubBaseZ));

loader2SubBaseCZ = 1;
loader2SubBaseCornerOffsetX = loader2SubBaseX/2 - loader2BaseCornerDia/2;
loader2SubBaseCornerOffsetY = loader2SubBaseY/2;

loader2CZ = 1;

loader2BaseY = 70; //60;

loader2GuideExitHoleZ = cartridgeLen + 3;
loader2GuideTopY = loader2BaseY - 5;
loader2GuideTopZ = loader2GuideExitHoleZ + 12;

loader2BaseX = loader2SubBaseX;
loader2BaseOffsetY = -7; //-2;

loader2BaseCornerOffsetX = loader2BaseX/2 - loader2BaseCornerDia/2;
loader2BaseCornerOffsetY = loader2BaseY/2 - loader2BaseCornerDia/2;
loader2Z = loader2GuideTopZ + cartridgeLen + 1;

m3SocketHeadDia = 5.6;

loader3X = 20;
loader3Y = 2*cartridgeLen + 10;
loader3Z = 2*cartridgeLen + 10;

loader3EntryOffsetY = -5;

loader3SlopeOffsetY = -cartridgeLen/2;
loader3SlopeOffsetZ = -10;

module loader3()
{
    difference()
    {
        // Exterior:
        tcu([-loader3X/2, 0, 0], [loader3X, loader3Y, loader3Z]);

        // Entry:
        translate([0, 55, 0])  
        {
            // Rim:
            hull()
            {
                tcy([0, loader3EntryOffsetY, loader3Z], d=brassRimClearanceOD, h=1);
                tcy([0, 0, loader3Z-cartridgeLen+1.7], d=brassRimClearanceOD, h=1);
            }
            // Entry Slot:
            difference()
            {
                hull()
                {
                    tcu([-brassClearanceOD/2, -cartridgeLen+loader3EntryOffsetY, loader3Z], [brassClearanceOD, cartridgeLen, 1]);
                    tcu([-brassClearanceOD/2, -cartridgeLen+loader3EntryOffsetY, loader3Z-cartridgeLen-1.7], [brassClearanceOD, cartridgeLen-loader3EntryOffsetY, 1]);
                }
                translate([0,0,40]) rotate([13,0,0]) tcu([-200,-200, -400], 400);
            }
            // // Entry Slot:
            // hull()
            // {
            //     tcu([-brassClearanceOD/2, -cartridgeLen+loader3EntryOffsetY, loader3Z], [brassClearanceOD, cartridgeLen, 1]);
            //     tcu([-brassClearanceOD/2, -cartridgeLen+loader3EntryOffsetY, loader3Z-cartridgeLen], [brassClearanceOD, cartridgeLen-loader3EntryOffsetY, 1]);
            // }
            // // Slope Slot:
            // hull()
            // {
            //     tcu([-brassClearanceOD/2, -cartridgeLen+loader3EntryOffsetY, loader3Z-cartridgeLen], [brassClearanceOD, cartridgeLen-loader3EntryOffsetY, 1]);
            //     tcu([-brassClearanceOD/2, -cartridgeLen+loader3EntryOffsetY+loader3SlopeOffsetY, loader3Z-cartridgeLen+loader3SlopeOffsetZ], [brassClearanceOD, 1, brassClearanceOD]);
            // }
            // Slope Rim:
            hull()
            {
                dy = 4;
                dz = -1;
                translate([0, 0, loader3Z-cartridgeLen+brassRimClearanceOD/2]) 
                    rotate([90,0,0]) cylinder(d=brassRimClearanceOD, h=1);
                translate([0, dy, loader3Z-cartridgeLen+brassRimClearanceOD/2+dz]) 
                    rotate([90,0,0]) cylinder(d=brassRimClearanceOD, h=1);

                translate([0, -cartridgeLen+loader3EntryOffsetY+loader3SlopeOffsetY+1, loader3Z-cartridgeLen+loader3SlopeOffsetZ+brassRimClearanceOD/2]) 
                    rotate([90,0,0]) cylinder(d=brassRimClearanceOD, h=1);
                translate([0, -cartridgeLen+loader3EntryOffsetY+loader3SlopeOffsetY+1, loader3Z-cartridgeLen+loader3SlopeOffsetZ+brassRimClearanceOD/2+dz-0.7]) 
                    rotate([90,0,0]) cylinder(d=brassRimClearanceOD, h=1);
            }
            // Slot to exit:
            difference()
            {
                esz = cartridgeLen;
                tcu(
                    [-brassClearanceOD/2, -cartridgeLen+loader3EntryOffsetY+loader3SlopeOffsetY, loader3Z-cartridgeLen+loader3SlopeOffsetZ+brassRimClearanceOD/2+1.5-esz], 
                    [brassClearanceOD, cartridgeLen+5, esz]);
                translate([0,-48,0]) rotate([50,0,0]) tcu([-200,-200, -400], 400);
            }
            // Exit:
            tcy([0, -cartridgeLen+loader3EntryOffsetY+loader3SlopeOffsetY, loader3Z-cartridgeLen+loader3SlopeOffsetZ-100+brassRimClearanceOD], d=brassRimClearanceOD, 100);
        }
    }
}

module loader2()
{
    difference()
    {
        union()
        {
        // Sub-base:
            difference()
            {
                union()
                {
                    translate([0, loader2SubBaseOffsetY, 0]) hull()
                    {
                        // Main body:
                        doubleX() doubleY()
                            translate([loader2SubBaseCornerOffsetX, loader2SubBaseCornerOffsetY, 0]) 
                                simpleChamferedCylinderDoubleEnded(d=loader2BaseCornerDia, h=loader2SubBaseZ, cz=loader2CZ);
                    }

                    // Exterior:
                    translate([0, loader2BaseOffsetY, 0]) hull()hull()
                    {
                        // Main body:
                        doubleX() doubleY()
                            translate([loader2BaseCornerOffsetX, loader2BaseCornerOffsetY, 0]) 
                                simpleChamferedCylinderDoubleEnded(d=loader2BaseCornerDia, h=loader2Z, cz=loader2CZ);
                    }
                }

                // Trim the loader to fit the holder:
                translate([0,0,-(cartridgeRecessZ + cartridgeRecessOffsetZ)]) holderExterior();
            }            
        }

        // Holes for M3 socket-head screws to guide the box:
       
        // doubleX() tcy([boxGuideScrewsCtrX, 0, loader2Z-16], d=3, h=100);
        cartridgeBoxGuideScrewHoles(y=-2);
        rearGuideScrewCtrsY = -loader2BaseY/2 + loader2BaseOffsetY + loader2CZ + 0.5 + m3SocketHeadDia/2;
        cartridgeBoxGuideScrewHoles(y=rearGuideScrewCtrsY);

        // Trough:
        troughXform()
        {
            hull()
            {
                tcy([0, 0, loader2GuideExitHoleZ], d=brassRimClearanceOD, h=100);
                tcy([0, 0, loader2Z], d=brassRimClearanceOD, h=100);
            }
            translate([0, 0, loader2GuideTopZ]) cylinder(d=brassRimClearanceOD, h=100);
        }

        // Slot:
        difference()
        {
            troughXform()
            {
                tcy([0, 0, -1], d=brassClearanceOD, h=100);
                translate([0, 0, -1]) cylinder(d=brassClearanceOD, h=100);
            }
            hull()
            {
                tcu([-200, -400-loader2BaseY/2-5, -400+loader2GuideTopZ], 400);
                tcu([-200, -400, -400-5], 400);
            }
        }

        // Exit holes:
        for(columnIndex = [0 : (numCartridgesPerRow-1)])
        {
            x = cartridgeAreaOutsideX + columnIndex*cartridgeSpacingX - baseX/2;

            // Guide hole:
            tcy([x,0,-1], d=brassRimClearanceOD, h=100);

            // Extra clearance at bottom of slope:
            clearanceZ = 8;
            translate([0,0,loader2GuideExitHoleZ-clearanceZ/2+0.5]) 
            {
                // simpleChamferedCylinder(d=brassRimClearanceOD+2, h=clearanceZ, cz=2);
                cylinder(d=brassRimClearanceOD+2, h=100);
                translate([0,0,-clearanceZ/2-4+nothing]) cylinder(d1=brassRimClearanceOD+nothing, d2=brassRimClearanceOD+2, h=8);
            }

            // Bottom chamfer:
            translate([x,0,-10+brassRimClearanceOD/2+cartridgeRecessCZ]) cylinder(d1=20, d2=0, h=10);
        }
    }
}

module cartridgeBoxGuideScrewHolesXform(y)
{
    boxGuideScrewsCtrX = cartridgeBoxExteriorX/2 + m3SocketHeadDia/2;
    doubleX() translate([boxGuideScrewsCtrX, y, loader2Z]) children();
}

module cartridgeBoxGuideScrewHoles(y)
{
    cartridgeBoxGuideScrewHolesXform(y) 
    {
        screHoleDia = 3;
        tcy([0,0,-16], d=screHoleDia, h=100);
        translate([0,0,-screHoleDia/2-0.5]) cylinder(d2=10, d1=0, h=5);
    }
}

module troughXform()
{
    for(columnIndex = [0 : (numCartridgesPerRow-1)])
    hull() 
    {
        // Front/bottom end:
        frontX = cartridgeAreaOutsideX + columnIndex*cartridgeSpacingX - baseX/2;
        translate([frontX,0,0]) children(0);

        // Rear/top end:
        rearY = -loader2BaseY/2 + loader2BaseOffsetY + brassRimClearanceOD/2 + loader2CZ + 2 + loader2CZ;
        boxCartridgeAreaOutsideX = -(numCartridgesPerRow-1)/2 * cartridgeBoxSpacingX;
        rearX = boxCartridgeAreaOutsideX + columnIndex*cartridgeBoxSpacingX;
        translate([rearX, rearY, 0]) children(1);
    }
}

loaderBaseCornerDia = 4;
loadeCZ = 1;
loaderBaseCornerOffsetX = 10;
loaderBaseExtraY = 4;
loaderBaseCornerOffsetY = cartridgeSpacingY/2 - holderBaseCZ - loadeCZ + loaderBaseExtraY; //7;

loaderExtraZ = 8;
loaderZ = 2*cartridgeLen + loaderExtraZ;

loaderEntryGuideHoleCtrY = brassRimClearanceOD * 0.8;

flipBumpDY = 2.5;
flipBumpOD = 30;
flipBumpZ = cartridgeLen - flipBumpOD*0.38; //0.28;

frontYTop = loaderEntryGuideHoleCtrY - cartridgeLen - 3; 
echo(str("frontYTop = ", frontYTop));

slotOuterExtraDia = 2;
slotMidY = -3.4; 
slotOuterY = frontYTop + slotOuterExtraDia/2;
slotOuterDia = brassClearanceOD + slotOuterExtraDia; 
                
module loader()
{
    difference()
    {
        union()
        {
            difference()
            {
                // Exterior:
                hull()
                {
                    // Main body:
                    translate([0,loaderBaseExtraY,0])
                        doubleX() doubleY()
                            translate([loaderBaseCornerOffsetX, loaderBaseCornerOffsetY, 0]) 
                                simpleChamferedCylinder(d=loaderBaseCornerDia, h=loaderZ, cz=loadeCZ);
                    
                    // Cartridge tip protector:
                    hull()
                    {
                        cartridgeTipProtectorDisk(frontY=frontYTop, topZ=loaderZ);
                        cartridgeTipProtectorDisk(frontY=frontYTop, topZ=30);
                    } 
                }

                // Trim the loader to fit the holder:
                translate([0,0,-(cartridgeRecessZ + cartridgeRecessOffsetZ)]) holderExterior();

                // Guide-hole into loader:
                translate([0,loaderEntryGuideHoleCtrY, cartridgeLen+loaderExtraZ])
                {
                    // Guide hole:
                    cylinder(d=brassRimClearanceOD, h=100);

                    // Clearance for rim at bump to force flip:
                    difference()
                    {
                        translate([0, flipBumpOD/2-brassRimClearanceOD/2-flipBumpDY, flipBumpZ]) 
                            rotate([0,90,0]) 
                                hull() torus3(outsideDiameter=flipBumpOD, circleDiameter=brassRimClearanceOD);

                        // Trim +Y:
                        tcu([-50,0,-50], 100);
                    }

                    // Slot to allow rotation:
                    hull()
                    {
                        cylinder(d=brassClearanceOD, h=100);
                        tcy([0,slotMidY-loaderEntryGuideHoleCtrY,0], d=brassClearanceOD, h=100);
                    }
                    hull()
                    {
                        tcy([0,slotMidY-loaderEntryGuideHoleCtrY,0], d=brassClearanceOD, h=100);
                        tcy([0,slotOuterY-loaderEntryGuideHoleCtrY,0], d=slotOuterDia, h=100);
                    }
                }

                // Transition between guide-holes:
                dy = 2;
                dd = 0.3;
                td = brassRimClearanceOD + dd;
                hull()
                {
                    tcy([0, loaderEntryGuideHoleCtrY, cartridgeLen+loaderExtraZ*2], d=brassRimClearanceOD, h=nothing);
                    tcy([0, loaderEntryGuideHoleCtrY,      cartridgeLen+loaderExtraZ], d=td, h=nothing);
                    tcy([0,                      dd,      cartridgeLen+loaderExtraZ], d=td, h=nothing);
                }
                hull()
                {
                    tcy([0, loaderEntryGuideHoleCtrY-dy,           cartridgeLen+loaderExtraZ], d=td, h=nothing);
                    tcy([0,                          dd,           cartridgeLen+loaderExtraZ], d=td, h=nothing);
                    tcy([0,                           0, cartridgeLen+loaderExtraZ/2-nothing], d=brassRimClearanceOD, h=nothing);
                }

                // Guide-hole into holder:
                union()
                {
                    // Guide hole:
                    translate([0,0,-1]) cylinder(d=brassRimClearanceOD, h=cartridgeLen+loaderExtraZ/2+1);

                    // Slot to allow rotation:
                    difference()
                    {
                        // Slot:
                        union()
                        {
                            hull()
                            {
                                cylinder(d=brassClearanceOD, h=100);
                                tcy([0,slotMidY,0], d=brassClearanceOD, h=100);
                            }
                            hull()
                            {
                                tcy([0,slotMidY,0], d=brassClearanceOD, h=100);
                                tcy([0,slotOuterY,0], d=slotOuterDia, h=100);
                            }
                        }
                        // Trim angle to guide tip into holder:
                        translate([0,0,3]) rotate([70,0,0]) tcu([-50,-100,-50], 100);
                    }
                }
            }

            // Flip-bump:
            translate([0, loaderEntryGuideHoleCtrY+brassRimClearanceOD/2, cartridgeLen+loaderExtraZ]) difference()
            {
                translate([0,0, 0]) 
                    translate([0, flipBumpOD/2-flipBumpDY, flipBumpZ]) 
                        rotate([0,90,0]) 
                            hull() torus3(outsideDiameter=flipBumpOD, circleDiameter=3);

                // Trim +Y:
                tcu([-50, 0, -50], 100);
            }
        }

        // Chamfer top:
        translate([0, loaderEntryGuideHoleCtrY-0.5, loaderZ-brassRimClearanceOD/2-3.7]) cylinder(d1=0, d2=20, h=10);

        // Chamfer bottom:
        translate([0, 0, -10+brassRimClearanceOD/2+1.5]) cylinder(d2=0, d1=20, h=10);
    }
}

module cartridgeTipProtectorDisk(frontY, topZ)
{
    // MAGIC NUMBER!!!!!!
    // ---------------------vvvvvvv
    octagonDiameterFactor = 1.01268;
    od = 20;
    yo = frontY*octagonDiameterFactor + od/2;
    zo = topZ*octagonDiameterFactor - od/2;
    translate([0, yo, zo]) 
        rotate([0,90,0]) 
            rotate([0,0,22.5])
                hull() torus2fn(outsideDiameter=od, outsideFN=8, circleDiameter=brassRimClearanceOD+6);
}

module holderExterior()
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

module holder()
{
    difference()
    {
        holderExterior();
                
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
    
    // display() loader();
    // displayGhost() holderGhost();

    // display() loader2();
    // displayGhost() holderGhost();

    display() loader3();
    // displayGhost() holderGhost();

    // display() rotate([180,0,0]) loader();
    displayGhost() translate([-150,100,0])  loader();
    displayGhost() translate([-150,0,0])  loader2();
    displayGhost() translate([-150,-180,0])  holderGhost();
}
else
{
	if(makeHolder) holder();
    if(makeLoader) rotate([180,0,0]) loader();
    if(makeLoader2) rotate([180,0,0]) loader2();
    if(makeLoader3) rotate([180,0,0]) loader3();
}

module holderGhost()
{
    translate([0,0,-(cartridgeRecessZ + cartridgeRecessOffsetZ)]) holder();
}
