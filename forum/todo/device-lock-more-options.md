## Device lock more options

Adding more options for device lock considering that 1 minute seems to be the finest granularity.

> > @robang74 wrote:
> > 
> > @Simerax wrote:
> > 
> > My Request is to either allow custom timeout settings (like the timer dialog in the clock app) or more options in the current combo box to allow shorter durations like 5, 10, 30 & 60 seconds
> 
> It is enough a check box: quick autolock [0/1]
> 
> [_] means 5/10/30/60 minutes
> [X] means 5/10/30/60 seconds
> 
> That’s all. Curious that nobody implemented it.

### Proof of concept by @wetab73

The patch is very simple. The file to patch is

* `/usr/share/jolla-settings/pages/devicelock/devicelock.qml

Example. The following patch adds two new device lock timeout options: 1 minute and 2 hours

<sup>

```
--- a/usr/share/jolla-settings/pages/devicelock/devicelock.qml	Sat Jun 17 04:08:28 2023
+++ b/usr/share/jolla-settings/pages/devicelock/devicelock.qml	Sat Jun 17 04:33:14 2023
@@ -155,6 +155,13 @@
                         onClicked: lockingCombobox.setAutomaticLocking(0)
                     }
                     MenuItem {
+                        //% "1 minute"
+                        text: "1 minute"
+                        visible: deviceLockSettings.maximumAutomaticLocking === -1
+                                    || deviceLockSettings.maximumAutomaticLocking >= 1
+                        onClicked: lockingCombobox.setAutomaticLocking(1)
+                    }
+                    MenuItem {
                         //% "5 minutes"
                         text: qsTrId("settings_devicelock-me-on5")
                         visible: deviceLockSettings.maximumAutomaticLocking === -1
@@ -182,6 +189,13 @@
                                     || deviceLockSettings.maximumAutomaticLocking >= 60
                         onClicked: lockingCombobox.setAutomaticLocking(60)
                     }
+                    MenuItem {
+                        //% "2 hours"
+                        text: "120 minutes"
+                        visible: deviceLockSettings.maximumAutomaticLocking === -1
+                                    || deviceLockSettings.maximumAutomaticLocking >= 120
+                        onClicked: lockingCombobox.setAutomaticLocking(120)
+                    }
                 }

                 function setAutomaticLocking(minutes) {
@@ -205,14 +219,18 @@
                         return 0
                     } else if (value === 0) {
                         return 1
-                    } else if (value === 5) {
+                    } else if (value === 1) {
                         return 2
-                    } else if (value === 10) {
+                    } else if (value === 5) {
                         return 3
-                    } else if (value === 30) {
+                    } else if (value === 10) {
                         return 4
-                    } else if (value === 60) {
+                    } else if (value === 30) {
                         return 5
+                    } else if (value === 60) {
+                        return 6
+                    } else if (value === 120) {
+                        return 7
                     }
                 }
             }
```

</sup>

Note: those two new options are not localized. They’re shown in English on the Settings page (i.e. “1 minute” and “120 minutes”). If you want them localized to your language, edit it in the patch.

The same way as above, you can add any further timeout options you want. It takes values in minutes, so I haven’t tested and do not know if timeouts shorter than 1 minute would work. Please try it yourself.

