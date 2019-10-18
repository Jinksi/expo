//  Copyright © 2019-present 650 Industries. All rights reserved.

#import "EXThreadSafePostOffice.h"
#import "EXSimplePostOffice.h"
#import "EXNotificationRepository.h"
#import "EXSimpleNotificationRepository.h"

@interface EXThreadSafePostOffice()

@property (atomic) id<EXPostOffice> insecurePostOffice;

@end

@implementation EXThreadSafePostOffice

static dispatch_queue_t queue;

- (instancetype)init
{
  if (self = [super init]) {
    id<EXNotificationRepository> notificationRepostory = [EXSimpleNotificationRepository new];
    self.insecurePostOffice = [[EXSimplePostOffice alloc] initWithNotificationRepository:notificationRepostory];
  }
  return self;
}

+ (id<EXPostOffice>)sharedInstance
{
  static EXThreadSafePostOffice *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[EXThreadSafePostOffice alloc] init];
    queue = dispatch_queue_create("host.exp.exponent.EXThreadSafePostOffice", DISPATCH_QUEUE_SERIAL);
  });
  return sharedInstance;
}

- (void)notifyAboutUserInteractionForAppId:(NSString *)appId userInteraction:(NSDictionary *)userInteraction {
  dispatch_async(queue, ^{
    [self.insecurePostOffice notifyAboutUserInteractionForAppId:appId userInteraction:userInteraction];
  });
}

- (void)registerModuleAndGetInitialNotificationWithAppId:(NSString *)appId
          mailbox:(id<EXMailbox>)mailbox
completionHandler:(void (^)(NSDictionary*))completionHandler
{
  dispatch_async(queue, ^{
    [self.insecurePostOffice registerModuleAndGetInitialNotificationWithAppId:appId mailbox:mailbox completionHandler:completionHandler];
  });
}

- (void)unregisterModuleWithAppId:(NSString *)appId {
  dispatch_async(queue, ^{
    [self.insecurePostOffice unregisterModuleWithAppId:appId];
  });
}

- (void)tryToSendForegroundNotificationTo:(NSString*)appId foregroundNotification:(NSDictionary*)foregroundNotification completionHandler:(void (^)(BOOL))completionHandler
{
  dispatch_async(queue, ^{
    [self.insecurePostOffice tryToSendForegroundNotificationTo:appId foregroundNotification:foregroundNotification completionHandler:completionHandler];
  });
}

@end
