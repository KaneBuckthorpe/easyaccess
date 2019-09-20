ARCHS := armv7 armv7s arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = EasyAccessPreferences
EasyAccessPreferences_FILES =EARootListController.m
EasyAccessPreferences_INSTALL_PATH = /Library/PreferenceBundles
EasyAccessPreferences_FRAMEWORKS = UIKit
EasyAccessPreferences_PRIVATE_FRAMEWORKS = Preferences
EasyAccessPreferences_EXTRA_FRAMEWORKS += KBPreferences KBAppList

EasyAccessPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/EasyAccessPreferences.plist$(ECHO_END)
