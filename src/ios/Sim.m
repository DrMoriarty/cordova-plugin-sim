// MCC and MNC codes on Wikipedia
// http://en.wikipedia.org/wiki/Mobile_country_code

// Mobile Network Codes (MNC) for the international identification plan for public networks and subscriptions
// http://www.itu.int/pub/T-SP-E.212B-2014

// class CTCarrier
// https://developer.apple.com/reference/coretelephony/ctcarrier?language=objc

#import "Sim.h"
#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation Sim

- (void)getSimInfo:(CDVInvokedUrlCommand*)command
{
  NSMutableArray *cardsArray = [NSMutableArray new];
  CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
  CTCarrier *carrier = nil;
  if (@available(iOS 12.1, *)) {
      NSDictionary<NSString *,CTCarrier *> *services = [networkInfo serviceSubscriberCellularProviders];
      for (NSString * key in services.allKeys) {
          CTCarrier *c = services[key];

          BOOL allowsVOIPResult = [c allowsVOIP];
          NSString *carrierNameResult = [c carrierName];
          NSString *carrierCountryResult = [c isoCountryCode];
          NSString *carrierCodeResult = [c mobileCountryCode];
          NSString *carrierNetworkResult = [c mobileNetworkCode];

          if (!carrierNameResult) { carrierNameResult = @""; }
          if (!carrierCountryResult) { carrierCountryResult = @""; }
          if (!carrierCodeResult) { carrierCodeResult = @""; }
          if (!carrierNetworkResult) { carrierNetworkResult = @""; }

          NSDictionary *simData = [NSDictionary dictionaryWithObjectsAndKeys:
            @(allowsVOIPResult), @"allowsVOIP",
            carrierNameResult, @"carrierName",
            carrierCountryResult, @"countryCode",
            carrierCodeResult, @"mcc",
            carrierNetworkResult, @"mnc",
            nil];
          [cardsArray addObject:simData];

          // take first found with non-empty name
          if (c.isoCountryCode != nil && ![c.isoCountryCode isEqual:@""]) {
              carrier = c;
              break;
          }
      }
  } else {
      carrier = [networkInfo subscriberCellularProvider];
  }

  BOOL allowsVOIPResult = [carrier allowsVOIP];
  NSString *carrierNameResult = [carrier carrierName];
  NSString *carrierCountryResult = [carrier isoCountryCode];
  NSString *carrierCodeResult = [carrier mobileCountryCode];
  NSString *carrierNetworkResult = [carrier mobileNetworkCode];

  if (!carrierNameResult) {
    carrierNameResult = @"";
  }
  if (!carrierCountryResult) {
    carrierCountryResult = @"";
  }
  if (!carrierCodeResult) {
    carrierCodeResult = @"";
  }
  if (!carrierNetworkResult) {
    carrierNetworkResult = @"";
  }

  NSDictionary *simData = [NSDictionary dictionaryWithObjectsAndKeys:
    @(allowsVOIPResult), @"allowsVOIP",
    carrierNameResult, @"carrierName",
    carrierCountryResult, @"countryCode",
    carrierCodeResult, @"mcc",
    carrierNetworkResult, @"mnc",
    cardsArray, @"cards",
    nil];

  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:simData];

  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
