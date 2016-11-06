package require Ttk

#------------------------------------------------------------------------------
proc createSystemMenu {root pathName} {

    set menu [menu $pathName]

    $root configure -menu $menu
    foreach name [list File Edit View Help] {
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
    set tree [ttk::treeview $frame.tree -columns [list 1] -yscrollcommand [list $scroll set]]
    pack $tree -side left -fill both -expand 1
    pack $scroll -side left -fill y -expand 0

    set tkImage [image create photo -file "images/tk_16x16.png"]
    set wishImage [image create photo -file "images/wish_16x16.png"]

    $tree heading #0 -text "Year"
    $tree heading 1  -text "Detail"

    foreach year [list 2009 2010 2011 2012 2013 2014 2015 2016] {
        set entry [$tree insert {} end -text $year -image [list $tkImage]]
        $tree set $entry 1 "The year [set year]" 
        foreach month [list January February March April May June July \
                            August September October November December] {
            $tree insert $entry end -text $month -image [list $wishImage]
        }
    }

    return $frame
}


#------------------------------------------------------------------------------
proc incrVariable {var} {
    global $var
    incr $var 10
    if {$var == 100} {
        set $var 0
    }
    after 100 [list incrVariable $var]
}

#------------------------------------------------------------------------------
proc createRightSide {pathName} {

    set rightSide [ttk::panedwindow $pathName -orient vertical]
    pack $rightSide -fill both -expand yes

    set frame [ttk::frame $rightSide.f]
    $rightSide add $frame

    set left [ttk::frame $frame.left -padding 10]
    set right [ttk::frame $frame.right -padding 10]
    pack $left -side left
    pack [ttk::separator $frame.sep -orient horizontal]
    pack $right -side left -fill x

    variable checked 1
    variable unchecked 0
    variable radio 1
    variable combo "Combobox Item 1"

    pack [ttk::checkbutton $left.chk1 -text "Checkbutton 1" -variable checked]
    pack [ttk::checkbutton $left.chk2 -text "Checkbutton 2" -variable unchecked]
    pack [ttk::separator $left.sep -orient vertical]
    pack [ttk::radiobutton $left.radio1 -text "Radiobutton 1" -variable radio -value 0]
    pack [ttk::radiobutton $left.radio2 -text "Radiobutton 2" -variable radio -value 1]
    pack [ttk::radiobutton $left.radio3 -text "Radiobutton 3" -variable radio -value 2]

    pack [ttk::combobox $right.combo -text "Combobox" -textvariable combo -values [list "Combobox Item 1" "Combobox Item 2"]]

    set progressFrame [ttk::frame $right.progressDeterminate]
    pack [ttk::label $progressFrame.label -text "Progress 75% "] -side left
    pack [ttk::progressbar $progressFrame.progress -orient horizontal -value 75] -side left
    pack $progressFrame

    global progress 0
    after 100 [list incrVariable progress]
    set progressFrame [ttk::frame $right.progressIndeterminate]
    pack [ttk::label $progressFrame.label -text "Progress "] -side left
    pack [ttk::progressbar $progressFrame.progress -orient horizontal -mode indeterminate -variable progress] -side left
    pack $progressFrame -anchor e



    return $rightSide
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