//
//  EventParser.h
//  iStager
//
//  Created by Wolfert de Kraker on 21-02-12.

#import <Foundation/Foundation.h>
#import "TouchXML.h"
#import "Event.h"

@interface EventParser : NSObject {
	CXMLElement * _element;
	Event		* _event;
	NSDictionary* _mappings;
	NSDateFormatter * _df;
}

- (id) initWithMappings:(NSDictionary*)mappings;
- (Event*) parseEvent:(CXMLElement*)element;
- (Location*) parseLocation:(CXMLDocument*) addres;

@end
