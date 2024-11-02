#import "InvoiceGeneratorPlugin.h"
#if __has_include(<invoice_generator/invoice_generator-Swift.h>)
#import <invoice_generator/invoice_generator-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "invoice_generator-Swift.h"
#endif

@implementation InvoiceGeneratorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftInvoiceGeneratorPlugin registerWithRegistrar:registrar];
}
@end
