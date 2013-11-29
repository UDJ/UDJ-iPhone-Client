#UDJ

UDJ is a social music player. It allows many people to control
a single music player democratically. Checkout the
[UDJ homepage][home] for more information. This is the official
UDJ iPhone App. For more details on actually interacting with
UDJ (so you can do something like creating your own client), see the [UDJ Server Repository][server].

## Who Are You?

The primary developer for the UDJ iPhone app is me, [Matt Graf][mg]. You can contact me via email at themattgraf@gmail.com.   
UDJ as a whole, however, is a team project led by [Kurtis Nusbaum][kln].

## Requirements
The UDJ iPhone is currently using iOS SDK 5.1. You will have to clone the [RestKit][rk] and [ShareKit][shk] repositories since we're making use of both of those frameworks in the iPhone app. Getting those frameworks to work with your Xcode project may not be a very straightforward process so feel free to shoot me an email and I'll help you get everything set up.   
   
ShareKit is used for sharing on social networks (we're using Facebook and Twitter). ShareKit requires a Configurator file that basically holds information that links our app to our respective pages on Twitter and Facebook. The **UDJConfigurator** file has been removed from the repo since it has some sensitive data, but I've added a dummy file **UDJConfigurator dummy** that you can rename to **UDJConfigurator** so that you can still compile the project. You just won't be able to actually use the sharing feature of the app.

## License
UDJ is licensed under the [GPLv2][gpl].

## Questions/Comments?

For the UDJ iPhone app, I've been the sole developer so far. If you have any problems working with the UDJ Xcode project, email me at themattgraf@gmail.com. Its possible that there are required files that I've forgotten to add the Git repo so just let me know what you need so I can fix it.   
   
If you have any questions or comments about UDJ in general, feel free to post them to
the [UDJ mailing list][mailing].

[home]:https://www.udjplayer.com
[server]:https://github.com/klnusbaum/UDJ
[kln]:https://github.com/klnusbaum/
[gpl]:https://github.com/yourmattg/UDJ/blob/master/LICENSE
[mailing]:mailto:udjdev@bazaarsolutions.com
[mg]:https://github.com/yourmattg/
[rk]:https://github.com/RestKit/RestKit
[shk]:https://github.com/ShareKit/ShareKit
