
/* [base] */
// width of clamp
w = 40; //.1
// height of clamp base
h = 6;//.1
// min frame width
wm = 3;//.1

/* [hooks] */
// nominal distance between hooks (width of profile)
hl = 35;//.1
// pretension (hook with springs will be offset by this amount
hp = 2;//.1
// height of hook
hh = 4.2;//.1
// clamping heigth of hook
hc = 0.9;//.1
// thickness of hook
ht = 6;//.1
// min thickness of hook
htm = 4.2;//.1
// minimum slide len
hsl = 15;//.1
// hook x center offset 0 = centered on profile
hox = 0;//.1
// number of slides
hsc = 1;

/* [springs] */
// spring mode
sm = "both"; //["push","pull","both"]
// minimal spacing between spring elements
sms = 2;//.1
// thickness of springs
st = 2.4;//.1

/* [hole dimensions] */
// hole shape
hss = 0; //[0:"straight", 1:"countersunk flat", 2:"hex nut", 3: "square nut", 4: "countersunk 90°"]
// hole size (diameter)
hs = 4.4; // voron M3
// size of countersinking (key size for nuts)
hsz = 5.5;//.05
// height of countersinking (only for flat types)
hszh = 2.4;

/* [hole placement] */
// hole positioning
hop = 2; //[0:"center of clamp", 1: "centered to each slide", 2: "4 holes with set distance", 3: "set interval", 4:"custom X-positions"]
// distance between holes along x
hd = 72;//.1
// min wall around holes
hw = 2.2;//.1
// hole distance y (4 holes / interval only)
hdx = 32;//.1
// custom hole positions - edit in line 58 for different quantities (each number will result in a pair of holes)
hdxc = [5, 12, 19, 26];//.1

/* [quality] */
$fs = 0.2;
$fa = 2;
// chamfer on top and bottom
c = 0.3;
// radius in corners
r = 2;
// tolerance (spacing between slide and frame)
t = 0.4;

/*
    some calculations
*/
// max hole size
hdmax = hss==0? hs:hsz;

// total len
l= hd + hdmax + 2* hw;
// cut start
cs = l/2 - hl/2 +hox;
//cut len 
cl = l -cs - hdmax -2 * hw;
// max len of spring
sml = hl -hp;
// spring len 50/50
smf = (cl - hsl)/2;
//guide size 
gw = h/4;
// cut width
cw = hsc>1?(w - (max(1,hsc)+1)* wm - ((max(1,hsc)*2)-1)* gw)/max(1,hsc):w - 2* wm - 2* gw;
// slide width
sw = cw - 2*t;

/*
    @param l: usable length of spring
    @param w: total width of spring
    @param h: heigth
    @param s: spacing between elements
    @param t: thickness / width of spring elements
    @param c: chamfer on top and bottom
*/
module spring(l,w,h,s,t,c=0.3){
    n= floor((l+s)/(t+s));
    // actual spacing
    as = (l-(n*t))/(n-1);
    ro = t+as/2;
    ri = as/2;
    assert(2*ro < w, "Error: impossible to create spring! make t smaller or w larger");
    
    echo("actial spring spacing: ",as);
    ls = w-2*ro;
    yofs = ls/2;
    p = [[ri+c,0],[ro-c,0],[ro,c],[ro,h-c],[ro-c,h],[ri+c,h],[ri,h-c],[ri,c]];
    for(x=[ro:2*ro+as:l+ro]){
        translate([x,yofs,0])rotate_extrude(angle=180){polygon(p);}
    }
    for(x=[-ro+t/*2*ro+as/2*/:2*ro+as:l+ro]){
        translate([x,-yofs,0])rotate_extrude(angle=-180){polygon(p);}
    }
    for(x=[0:t+as:l]){
        translate([x,0,0])hull(){
            for(x=[c,t-c], y=[-yofs,yofs]){
                translate([x,y,0])cylinder(c,r1=0,r2=c);
                translate([x,y,h-c])cylinder(c,r1=c,r2=0);
            }
        }
    }
    // connection to body
    linear_extrude(h){
    ymax = ls/2+ri+c;
    ymin = ls/2;
    difference(){
        polygon([[-c*1.5,-ymax],[c,-ymax],[t-c,ymin+c],[-c*1.5,ymin+c]]);
        translate([0,ymin+c])circle(c);
        }
        if (n % 2 == 0){
            difference(){
                polygon([[l-t/2,-ymax],[l+c,-ymax],[l+c,ymin+c],[l-t+c,ymin+c]]);
                translate([l,ymin+c])circle(c);
                }
        } else {
            difference(){
                polygon([[l-t+c,-ymin-c],[l+c,-ymin-c],[l+c,ymax],[l-t/2,ymax]]);
                translate([l,-ymin-c])circle(c);
                }
        }
    } 
}
/*
    @param l: length
    @param w: width
    @param h: height
    @param r: corner radius
    @param gw: size of guide
    @param el: extra h for cut
    @param c: camfer on top and bottom
*/
module bodyCut(l,w,h,r,gw,el=0.01, c=0.3){
    assert(gw < h/3, "guide to big");
    difference(){
        translate([0,-w/2])union(){
            translate([0,0,-el])linear_extrude(h+2*el)hull()for(x=[r,l-r], y=[r,w-r])translate([x,y])circle(r);
            translate([0,0,-el])hull()for(x=[r,l-r], y=[r,w-r])translate([x,y])cylinder(c+el,r1=r+c+el,r2=r);
            translate([0,0,h-c])hull()for(x=[r,l-r], y=[r,w-r])translate([x,y])cylinder(c+el,r2=r+c+el,r1=r);
            hull(){
                translate([r,0,h/2-1.5*gw])cube([l-2*r,el,3*gw]);
                for(x=[r+gw,l-r-gw])translate([x,0,h/2-gw/2])cylinder(gw,r=gw);
            }
            hull(){
                translate([r,w-el,h/2-1.5*gw])cube([l-2*r,el,3*gw]);
                for(x=[r+gw,l-r-gw])translate([x,w,h/2-gw/2])cylinder(gw,r=gw);
            }
        }
        translate([-1.5*c,-w,c])cube([1.5*c,2*w,h]);
    }
}

/*
    @param l: length
    @param w: width
    @param h: height
    @param r: corner radius
    @param gw: size of guide
    @param el: extra h for cut
    @param c: camfer on top and bottom
*/
module slide(l,w,h,r,gw,el=0.0, c=0.3){
    assert(gw < h/3, "guide to big");

    translate([0,-w/2])union(){
        translate([0,0,-el])hull(){for(x=[r,l-r], y=[r,w-r])translate([x,y])rotate_extrude()polygon([[0,-el],[r-c-el,-el],[r,c],[r,h-c],[r-c-el,h+el],[0,h+el]]);}
        hull(){
            echo(l-2*r);
            translate([r,0,h/2-1.5*gw])cube([l-2*r,max(el,0.01),3*gw]);
            for(x=[r+gw,l-r-gw])translate([x,0,h/2-gw/2])cylinder(gw,r=gw);
        }
        hull(){
            translate([r,w-el,h/2-1.5*gw])cube([l-2*r,max(el,0.01),3*gw]);
            for(x=[r+gw,l-r-gw])translate([x,w,h/2-gw/2])cylinder(gw,r=gw);
        }
        
    }
}

/*
    @param l: len
    @param w: width
    @param h: height
    @param lm: min len
    @param hc: h start chamfer for clamping
*/
module hook (l,w,h,lm,hc, el=0.01){
    assert(l-lm <= h-hc);
    intersection(){
        translate([0,w/2])rotate([90,0,0])linear_extrude(w)polygon([[0,-el],[lm,-el],[lm,hc],[l,hc+l-lm],[l,h],[0,h]]);
        hull()for(y=[-w/2+l/2,w/2-l/2])translate([l/2,y,-el])cylinder(h+el,d=l);
    }
}

module baseBdy(){
    hull()for(x=[r,l-r], y=[-w/2+r,w/2-r])translate([x,y])rotate_extrude()polygon([[0,0],[r-c,0],[r,c],[r,h-c],[r-c,h],[0,h]]);
}
/*
    this module just multiplies components of the slides. Made for easier adjustment
*/
module alignSlides(){
    if (hsc>1){
        for(y=[-w/2+wm+1*gw+cw/2:cw+wm+gw:w/2])translate([0,y,0])children();
    } else {
        children();
    }
}
/*
    this module creates the negative volume for the mounting holes. Modify here for different hole geometry
*/
module hole(el = 0.01){
    // straight hole - always created
    rotate_extrude()polygon([[0,-el],[hs/2+c+el,-el],[hs/2,c],[hs/2,h-c],[hs/2+c+el,h+el],[0, h+el]]);
    r = hsz/2;
    p = h-hszh;
    if(hss == 1) { // flat
        rotate_extrude()polygon([[0,p],[r,p],[r,h-c],[r+c+el,h+el],[0,h+el]]);
    } else if(hss==2) { // hex
        d = hsz/0.866;
        a = 30;
        rotate([0,0,a])translate([0,0,p])cylinder(h,d=d,$fn=6);
        rotate([0,0,a])translate([0,0,h-c])cylinder(c+el,d1=d, d2=d+2*c+2*el,$fn=6);
    } else if(hss==3) { // square
        translate([-r,-r,p])cube([hsz,hsz,h]);
        translate([-r,-r,h-c])hull(){
            cube([hsz,hsz,c]);
            translate([-c,-c,c])cube([hsz+2*c, hsz+2*c,el]);
        }
    } else if(hss==4) { // 90° cone
        translate([0,0,h-hsz/2])cylinder(hsz/2+el,d1=0,d2=hsz+2*el);
    }
        
}
/*
    this module generates all negative volumes for mounting holes. Change here when you need a different placement
*/
module holes(){
    xpos = [hw+hdmax/2, hd+hw + hdmax/2];
    if (hop<=0){ // one centered set of holes
        for(x=xpos)translate([x,0,0])hole();
     } else if(hop==1) { // a set of holes at each slide
        alignSlides()for(x=xpos)translate([x,0,0])hole();
    } else if(hop==2) { // four holes
        for(x=xpos, y=[-hdx/2, hdx/2])translate([x,y,0])hole();
    } else if(hop==3) { // fixed interval
        
        ys = ((w-hdmax-2*hw)%hdx)/2+hw+hdmax/2;
        echo(ys);
        for(x=xpos, y=[-w/2+ys:hdx:w/2-ys+0.1])translate([x,y,0])hole();
    } else if(hop==4) { // custom positions
        for(x=xpos, y=hdxc)translate([x,y-w/2,0])hole();
    }
}


/*
    module generating the push-pull spring configuration
*/
module dblSpring(){
sl = smf >= sml? sml: smf + hsl > hl-hp+htm? smf:cl-sml-htm;
// slide len
sll = cl-2*sl;
difference(){
    union(){
        difference(){
            baseBdy();
            alignSlides()translate([cs,0,0])bodyCut(l=cl,w=cw,h=h, r=r +t,gw=gw, c=c);
        }
        alignSlides()translate([cs+sl,0,0])slide(l=sll,w=sw,h=h,r=r, gw=gw,c=c,el=0.0);
        alignSlides()translate([cs-htm,0,h])hook(l=ht,w=cw-2*r*2*t,h=hh,lm=htm,hc=hc);
        alignSlides()translate([cs+htm+hl-hp,0,h])rotate([0,0,180])hook(l=ht,w=sw-2*c-t,h=hh,lm=htm,hc=hc,el=c*2);
        alignSlides()translate([cs,0,0])spring(l=sl,w=sw-2*r-2*t,h=h,s=sms,t=st,c=c);
        alignSlides()translate([cs+sl+sll,0,0])spring(l=sl,w=sw-2*r-2*t,h=h,s=sms,t=st,c=c);
    }
    
    holes();
    }
}

/*
    module generating the pull spring configuration
*/
module pullSpring(){
    // travel len 
    tl = 2*hp +htm;
    // spring len
    sl = cl - hsl - tl >= sml? sml: cl - hsl-tl;
    //echo(sl);
    // slide len
    sll = cl-sl-tl;

    difference(){
        union(){
            difference(){
                baseBdy();
                alignSlides()translate([cs,0,0])bodyCut(l=cl,w=cw,h=h, r=r +t,gw=gw, c=c);
            }
            alignSlides()translate([cs+sl,0,0])slide(l=sll,w=sw,h=h,r=r, gw=gw,c=c,el=0.0);
            alignSlides()translate([cs-htm,0,h])hook(l=ht,w=cw-2*r*2*t,h=hh,lm=htm,hc=hc);
            alignSlides()translate([cs+htm+hl-hp,0,h])rotate([0,0,180])hook(l=ht,w=sw-2*c-2*r,h=hh,lm=htm,hc=hc,el=c*2);
            alignSlides()translate([cs,0,0])spring(l=sl,w=sw-2*r-2*t,h=h,s=sms,t=st,c=c);
        }
        holes();
    }
}

/*
    module generating the push spring configuration
*/
module pushSpring(){
    // travel len 
    tl = 2*hp +htm;
    // spring len
    sl = hsl < hl-hp+tl? cl-hl+hp-htm: cl - hsl-tl;
    //echo(sl);
    //echo(hsl);
    // slide len
    sll = cl-sl-tl;

    difference(){
        union(){
            difference(){
                baseBdy();
                alignSlides()translate([cs,0,0])bodyCut(l=cl,w=cw,h=h, r=r +t,gw=gw, c=c);
            }
            alignSlides()translate([cs+tl,0,0])slide(l=sll,w=sw,h=h,r=r, gw=gw,c=c,el=0.0);
            alignSlides()translate([cs-htm,0,h])hook(l=ht,w=cw-2*r*2*t,h=hh,lm=htm,hc=hc);
            alignSlides()translate([cs+htm+hl-hp,0,h])rotate([0,0,180])hook(l=ht,w=sw-2*c-2*r,h=hh,lm=htm,hc=hc,el=c*2);
            alignSlides()translate([cs+tl+sll,0,0])spring(l=sl,w=sw-2*r-2*t,h=h,s=sms,t=st,c=c);
        }
        holes();
    }
}

if(sm == "both")dblSpring();
if(sm == "pull")pullSpring();
if(sm == "push")pushSpring();
