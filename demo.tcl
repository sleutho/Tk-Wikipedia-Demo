package require Ttk

#------------------------------------------------------------------------------
# http://wiki.tcl.tk/17065
namespace eval ::canvasdial {
    #--------------------------------------------------------------------------
    proc dial {w x0 y0 x1 y1 args} {
        array set "" {-from 0 -to 100 -needle red
            -bg white -fg black}
        array set "" $args
        $w create oval $x0 $y0 $x1 $y1 -fill $(-bg)
        set xm [expr {($x0+$x1)/2.}]
        set ym [expr {($y0+$y1)/2.}]
        set id [$w create line $xm $ym $xm [+ $y0 10] -fill $(-needle) -width 3]
        $w create oval [- $xm 3] [- $ym 3] [+ $xm 3] [+ $ym 3] -fill $(-fg)
        set r [expr {$ym-$y0-15}]
        foreach i [dial'steps $(-from) $(-to)] {
            set a [dial'angle $(-from) $i $(-to)]
            set x [expr {$xm+$r*cos($a)}]
            set y [expr {$ym+$r*sin($a)}]
            $w create text $x $y -text $i -fill $(-fg)
        }
        trace var ::$(-variable) w [list dial'set $w $id $(-from) $(-to)]
    }

    #--------------------------------------------------------------------------
    foreach op {+ -} {
        proc $op {a b} "expr {\$a $op \$b}"
    }

    #--------------------------------------------------------------------------
    proc dial'steps {min max} {
        set step [expr {($max-$min)/50*10}]
        set res {}
        for {set i $min} {$i<=$max} {incr i $step} {
            lappend res $i
        }
        set res
    }

    #--------------------------------------------------------------------------
    proc dial'angle {min v max} {
        expr {(0.5 + double($v-$min)/($max-$min))*acos(-1)*1.5}
    }

    #--------------------------------------------------------------------------
    proc dial'set {w id min max var el op} {
        set v [uplevel 1 set $var]
        set v [expr {$v<$min? $min: $v>$max? $max: $v}]
        foreach {xm ym x1 y1} [$w coords $id] break
        set r [expr {hypot($y1-$ym,$x1-$xm)}]
        set a [dial'angle $min $v $max]
        set x1 [expr {$xm+$r*cos($a)}]
        set y1 [expr {$ym+$r*sin($a)}]
        $w coords $id $xm $ym $x1 $y1
    }
}

#------------------------------------------------------------------------------
proc createSystemMenu {root pathName} {

    set menu [menu $pathName]

    $root configure -menu $menu
    foreach name [list "Menu-1" "Menu-2" "Menu-3" "Menu-4"] {
        $menu add command -label $name
    }
}

#------------------------------------------------------------------------------
proc createPage {pathName} {

    set page [ttk::panedwindow $pathName -orient horizontal]
    pack $page -fill both -expand yes

    $page add [createTree      $page.tree]
    $page add [createRightSide $page.rightSide]

    return $page
}

#------------------------------------------------------------------------------
proc createTree {pathName} {

    set frame [ttk::frame $pathName]
    set scroll [ttk::scrollbar $frame.y -ori vert -command [list $frame.tree yview]]
    set tree [ttk::treeview $frame.tree -columns [list 1] \
        -yscrollcommand [list $scroll set]]

    grid $tree -row 0 -column 0 -sticky nsew
    grid $scroll -row 0 -column 1 -sticky nsew
    grid columnconfigure $frame 0 -weight 1
    grid rowconfigure $frame 0 -weight 1

    set tkImage [image create photo -file "images/tk_16x16.png"]
    set wishImage [image create photo -file "images/wish_16x16.png"]

    $tree heading #0 -text "Year"
    $tree heading 1  -text "Detail"

    foreach year [list 2009 2010 2011 2012 2013 2014 2015 2016] {
        set entry [$tree insert {} end -text $year -image [list $tkImage]]
        if {$year == 2013 || $year == 2014} {
            $tree item $entry -open true
        }
        $tree set $entry 1 "The year [set year]"
        foreach month [list January February March April May June July \
                            August September October November December] {
            $tree insert $entry end -text $month -image [list $wishImage]
        }
        if {$year == 2013} {
            $tree selection set $entry 
        }
    }

    return $frame
}

#------------------------------------------------------------------------------
proc createCanvas {pathName} {

    set c [canvas $pathName -takefocus 1 -height 140]

    variable V 0

    set x 10
    set y 10
    foreach size [list 110 130 110 110 130 110] {
        ::canvasdial::dial $c $x $y [expr $size + $x] [expr $size + $y] \
            -variable V -to [expr $size + $x] -fg blue
        incr x $size
        incr x 10
    }

    return $c
}

#------------------------------------------------------------------------------
proc createText {pathName} {

    set f [frame $pathName]
    ttk::scrollbar $f.hsb -orient horizontal -command [list $f.t xview]
    ttk::scrollbar $f.vsb -orient vertical -command [list $f.t yview]
    set textBox [text $f.t -xscrollcommand [list $f.hsb set] \
        -yscrollcommand [list $f.vsb set] -height 10]
    grid $f.t -row 0 -column 0 -sticky nsew
    grid $f.vsb -row 0 -column 1 -sticky nsew
    grid $f.hsb -row 1 -column 0 -sticky nsew
    grid columnconfigure $f 0 -weight 1
    grid rowconfigure $f 0 -weight 1

    $textBox insert 1.0 "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent at neque sed dui ultrices volutpat. Nulla porttitor ligula erat, dignissim tincidunt justo porttitor a. Morbi et dolor massa. Phasellus iaculis egestas elementum. Phasellus ac turpis sit amet dolor facilisis finibus quis vel nisi. Pellentesque lobortis odio lorem, sit amet feugiat neque vulputate lobortis. Sed malesuada luctus velit, vel faucibus nibh accumsan ac. Proin feugiat elementum volutpat. Praesent eu mattis leo. 
Etiam sit amet felis mollis, tempus sapien nec, sollicitudin purus. Ut et diam elit. Nam feugiat ac dolor eget ullamcorper. Ut aliquam neque eget nulla maximus eleifend. Aenean non dui vel purus consectetur sodales. Curabitur vitae euismod nibh, vulputate vestibulum leo. Aliquam a suscipit dolor, viverra vehicula arcu. Donec nec velit quis lorem varius malesuada. 
In maximus metus nisi, at efficitur odio elementum vehicula. Aliquam erat volutpat. Donec purus arcu, imperdiet non consequat nec, placerat id diam. Donec tristique venenatis neque sed pharetra. Cras porta consectetur justo non hendrerit. Cras mollis vehicula pulvinar. Fusce id quam pretium purus sodales tincidunt et vel urna. Vivamus dapibus tempus velit, ac vehicula metus tempus eget. Aliquam justo ante, pharetra a magna eget, malesuada luctus elit. Praesent a vehicula sem. Cras dapibus aliquam pulvinar. Proin tempus metus elit, vel gravida diam pharetra eget. Maecenas tempor diam velit, in viverra mi tincidunt id. Ut porttitor sodales semper. 
Maecenas venenatis lorem sapien, eu aliquet nunc aliquet vel. Donec pretium elit erat, pulvinar sollicitudin quam vehicula vel. Vivamus consectetur bibendum nibh ut posuere. Morbi viverra scelerisque gravida. Nulla sed ex in augue ullamcorper cursus sit amet vitae sapien. Maecenas eleifend nisl vel vulputate dignissim. Cras sed turpis facilisis metus varius malesuada. Sed in malesuada tellus. Vestibulum et lacus a nisl ultricies semper. Vestibulum auctor faucibus diam, finibus laoreet neque. Aliquam venenatis, libero tincidunt eleifend commodo, lacus elit iaculis lorem, a auctor libero urna sit amet elit. Etiam lacinia tempor tortor congue accumsan. Vestibulum viverra rhoncus lorem, at molestie erat convallis at. Vivamus nulla purus, scelerisque ut lacus eget, efficitur blandit sem. Etiam in ipsum congue, viverra justo ac, consequat odio. 
Suspendisse tempus turpis sed ipsum aliquam lacinia. Quisque imperdiet ligula erat, non pulvinar ante venenatis in. Vivamus sed quam id libero sodales gravida et quis tortor. Sed eu dui at arcu euismod tristique ut ac magna. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Sed vulputate libero quis auctor suscipit. Sed malesuada aliquam fermentum. Maecenas maximus molestie libero vel sodales. Quisque orci leo, euismod a leo vel, dapibus volutpat urna. Nulla in libero a sem eleifend tincidunt sit amet vel odio. Nullam luctus mauris interdum neque ornare accumsan."

    foreach word [list "Lorem" "dolor" "sit" ] {
        set matches [$textBox search -forwards -nocase -all -- $word 1.0]
        foreach start $matches {
            $textBox tag add $word $start [list $start + [string length $word] chars]
        }
        $textBox tag configure $word -foreground blue -underline 1
    }
    
    return $f
}

#------------------------------------------------------------------------------
proc incrBusyProgress {var} {
    global $var
    incr $var 10
    if {[set $var] > 100} {
        set $var 0
    }
    after 50 [list incrBusyProgress $var]
}

#------------------------------------------------------------------------------
proc createRightSide {pathName} {

    set verticalPane [ttk::frame $pathName]
    pack $verticalPane -fill both -expand yes

    set frame [ttk::frame $verticalPane.f]
    pack $frame -fill x


    set labelFrame1 [ttk::labelframe $frame.labelFrame1 -padding 10 -text "Label 1"]
    pack $labelFrame1 -side left -anchor n -padx 5

    variable checked 1
    variable unchecked 0
    variable radio 1
    variable combo "Combobox Item 1"

    pack [ttk::checkbutton $labelFrame1.chk1 -text "Checkbutton 1" -variable checked]
    pack [ttk::checkbutton $labelFrame1.chk2 -text "Checkbutton 2" -variable unchecked]
    pack [ttk::separator   $labelFrame1.sep -orient horizontal]
    pack [ttk::radiobutton $labelFrame1.radio1 -text "Radiobutton 1" -variable radio -value 0]
    pack [ttk::radiobutton $labelFrame1.radio2 -text "Radiobutton 2" -variable radio -value 1]
    pack [ttk::radiobutton $labelFrame1.radio3 -text "Radiobutton 3" -variable radio -value 2]


    set labelFrame2 [ttk::labelframe $frame.labelFrame2 -padding 10 -text "Label 2"]
    pack $labelFrame2 -side left -anchor n -padx 5

    pack [ttk::combobox $labelFrame2.combo -text "Combobox" -textvariable combo \
        -values [list "Combobox Item 1" "Combobox Item 2"]] -fill x

    set progressFrame [ttk::frame $labelFrame2.progressDeterminate]
    pack [ttk::label $progressFrame.label -text "Progress 75% "] -side left
    pack [ttk::progressbar $progressFrame.progress -orient horizontal -value 75] -side left
    pack $progressFrame

    global progress 0
    after 50 [list incrBusyProgress progress]
    set progressFrame [ttk::frame $labelFrame2.progressIndeterminate]
    pack [ttk::label $progressFrame.label -text "Progress "] -side left
    pack [ttk::progressbar $progressFrame.progress -orient horizontal \
        -mode indeterminate -variable progress] -side left
    pack $progressFrame -anchor e
    
    set spin [ttk::spinbox $labelFrame2.spin -from 0 -to 100 -increment 1]
    $spin set 25
    pack $spin -fill x
    
    set scale [ttk::scale $labelFrame2.scale -from 0 -to 100 -orient horizontal]
    $scale set 25
    pack $scale -fill x


    set labelFrame3 [ttk::labelframe $frame.labelFrame3 -padding 10 -text "Label 3"]
    pack $labelFrame3 -side left -anchor n -padx 5

    set tkImage [image create photo -file "images/tk_24x24.png"]
    pack [ttk::button $labelFrame3.button -text "Button" -image $tkImage -compound left] -fill x
    pack [ttk::menubutton $labelFrame3.menubutton -text "Menu Button" \
        -image $tkImage -compound left] -fill x


    set labelFrame4 [ttk::labelframe $frame.labelFrame4 -padding 10 -text "Label 4"]
    pack $labelFrame4 -side left -anchor n -padx 5

    variable listVar [list "Item 1" "Item 2" "Item 3" "Item 4" "Item 5"]
    set listBox [listbox $labelFrame4.listbox -listvariable listVar \
        -height [expr [llength $listVar] + 1]]
    $listBox selection set 1
    pack $listBox -fill x

    set textFrame [ttk::labelframe $verticalPane.textFrame -text "Text"]
    pack [createText $textFrame.text] -fill both -expand 1
    pack $textFrame -fill both -expand 1
    
    set canvasFrame [ttk::labelframe $verticalPane.canvasFrame -text "Canvas"]
    pack [createCanvas $canvasFrame.canvas] -fill x
    pack $canvasFrame -fill x

    return $verticalPane
}

#------------------------------------------------------------------------------
proc main {} {

    wm title . "Tk-Demo"
    wm geometry . 1245x700

    createSystemMenu . .menu

    set nb [ttk::notebook .nb]
    pack $nb -fill both -expand yes

    set tkImage [image create photo -file "images/tk_32x32.png"]

    set firstPage [createPage $nb.p1]

    $nb add $firstPage     -text "Page 1" -image [list $tkImage] -compound left
    $nb add [frame $nb.p2] -text "Page 2" -image [list $tkImage] -compound left
    $nb add [frame $nb.p3] -text "Page 3" -image [list $tkImage] -compound left
    $nb select $firstPage
}

#------------------------------------------------------------------------------
main