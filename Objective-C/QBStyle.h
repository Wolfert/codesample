//
//  QBStyle.h
//  QApp
//
//  Created by Wolfert de Kraker on 2/8/12.
//  Copyright (c) 2012 ~. All rights reserved.
//

#import "QBLib.h"

/*
 
 Verzamel stylesheet:
 
 Importeer deze één keer in je class en krijg extra gratis voorgedefineerde stijlen ter beschikking.
 
 */

// - kleuren
//   pastel stijl kleuren (opentbl):
#define pastelblauw UIColorFromRGB(0xD3EFFF)
#define pasteloranje UIColorFromRGB(0xffe3a1)
#define pastelpaars UIColorFromRGB(0xfadfff)

//   relatie highlight kleuren (mmt)
#define SELECTED_BACKGROUND_COLOR UIColorFromRGB(0xdca421)
#define NOT_SELECTED_BACKGROUND_COLOR [UIColor clearColor]
#define HIGHLIGHTED_BACKGROUND_COLOR UIColorFromRGB(0xD3EFFF)
#define NOT_HIGHLIGHTED_BACKGROUND_COLOR [UIColor clearColor]

//    thema kleur (quism blauw of qbism oranje)
#ifdef QUISM_VER
#define themakleur UIColorFromRGB(0x002ec0)
#else  
#define themakleur UIColorFromRGB(0xF0BA2D)
#endif 

// - Plaatjes
#define QNavbarPNG [UIImage imageNamed:@"navbar.png"]

//   tableview ()
#define tableviewAchtergrond UIColorFromRGB(0x8ccdff)

//   datumkleur (opentbl, vng)
#define datumkleur UIColorFromRGB(0x1464F4)


// - fonts
#define QFont [UIFont fontWithName:@"HelveticaNeue" size:12]
#define QFontBold [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]
#define QFont2Bold [UIFont fontWithName:@"HelveticaNeue-Bold" size:13]
#define QFont2 [UIFont fontWithName:@"HelveticaNeue" size:13]
#define QFont3 [UIFont fontWithName:@"HelveticaNeue" size:11];

//  system fonts:
#define SF12 SF12

