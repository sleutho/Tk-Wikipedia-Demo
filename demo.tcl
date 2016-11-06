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

    set frame [frame $pathName]
    set scroll [ttk::scrollbar $frame.y -ori vert -command [list $frame.tree yview]]
    set tree [ttk::treeview $frame.tree -columns [list 1] -yscrollcommand [list $scroll set]]
    pack $tree -side left -fill both
    pack $scroll -side left -fill y

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
proc createRightSide {pathName} {

    set rightSide [ttk::panedwindow $pathName -orient vertical]
    pack $rightSide -fill both -expand yes
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