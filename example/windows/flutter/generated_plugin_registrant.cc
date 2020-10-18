//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <in_app_review/in_app_review_plugin.h>
#include <url_launcher_windows/url_launcher_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  InAppReviewPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("InAppReviewPlugin"));
  UrlLauncherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherPlugin"));
}
