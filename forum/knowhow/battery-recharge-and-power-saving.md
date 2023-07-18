[quote="spiiroin, post:7, topic:7322"]
[quote="Seven.of.nine, post:1, topic:7322"]
> Presently there’s only possible to automatically activate the power saving mode depending on the accu charge level (20%, 15%, 10%, 5%, off), or set manually until next time charger is connected.
> [/quote]
>
>
>
> Note that from command line you can select any percentage value, e.g.
>
>
>
>
>
> ```
> mcetool --set-psm-threshold=100 --set-power-saving-mode=enabled
> ```
[/quote]

IMHO, this group of settings `{20%, 15%, 10%, 5%, off}` should be extended with two others values `{90%, 50%, 20%, 15%, 10%, 5%, off}` where `50%` indicates a strong propency to saving energy and `90%` almost keep the phone locked in energy saving mode.

Moreover, the option:

* *Enable battery saving mode until charger is connected the next time*

should change in this more useful:

* *Enable battery saving mode until next time got charged at 90%*

The reason it is obvious, it is enough that I connect the smartphone just the time to trasfer some data from it with the MTP via USB and the energy saving mode will be reset to the normal but no a very little charge has been transfered to the battery.

Finally, the threshold in charging at `{80%, 90%}` will do the rest. In order to keep the smartphone always in energy saving mode. At the cost of few meaningful changes. Personally, I would add `70%` at the values above, for those the battery is somehow compromised.

Is it possible to generate a patch for `PatchManager` to changes this behaviour? Which files are involved in changing reconfiguring the UI and/or its business logic? Because for the message to change, it is supposed to be translated in many languages in order to correctly address the various localisations.

**POST SCRIPTUM**

The `mcetool` command line should be installed with

> `devel-su pkcon install mce-tools`

