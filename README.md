A simple reddit client
===================

Hello there!

Welcome to my simple reddit client example for **Swift 3**.  This project was based on iOS 10.2 and has some must-know skills applied on features that compose many of the current and latest mobile application.

----------


Features
-------------
- Present the [/top](https://www.reddit.com/top/) reddit entires on a nice clean and dynamic CollectionView
- Remembers user credentials for automatic login
- Supports Portrait and Landscape for all iOS devices with dynamic columns for each configuration
- Content storing on camera roll / photos 
- Continuous scroll pagination with a "Load more" button ( you shall never leave the timeline muahahaha )

Development things
-------------
- oAuth token generation from [Reddit APIs](https://www.reddit.com/dev/api) 
- Storyboard with auto-layout for view design, also used for app flow with navigation control and navigation segues.
- User defaults for app state-preservation/restoration of login credentials
- Network request to [/top](https://www.reddit.com/top/) using authentication token using URLSession and URLRequest, also translating result into JSON
- NotificationCenter methods for trading information between viewcontrollers
- Singletones for strong reference of network communications and authorization
- Class extension for helper methods reusability
- Extra Info.plist configuration for allowing external request to non https:// protocol
- Extra Info.plist configuration for app launching with query parameters 

How does it look like?
-------------

[Here](http://imgur.com/a/l4K3U) there's some nice screenshots and a preview videos can be found [here](https://vid.me/YrW9)

----------
This repository is under MIT licence, find it helpful? Share it!

Hope you like it!

Bye!
