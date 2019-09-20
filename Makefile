THEOS_DEVICE_IP = 192.168.1.67
THEOS_DEVICE_PORT = 22
ARCHS := armv7 armv7s arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EasyAccess
EasyAccess_FILES = EasyAccess.xm Classes/EasyAccessController.m Classes/EABaseView.m Classes/PIWindow.m Classes/EACell.m Classes/EAGradientView.m
EasyAccess_PRIVATE_FRAMEWORKS = FrontBoard FrontBoardServices SpringBoardServices
EasyAccess_EXTRA_FRAMEWORKS += KBAppList

EasyAccess_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += EasyAccessPreferences
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
