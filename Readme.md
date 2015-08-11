#News Hack - for iOS
[by Lukas Carvajal](https://lcarvajal.github.io)

###Free The News
In this day and age, restricting people from accessing information is restricting them from their freedom to aquire knowledge.
News Hack aims to get high quality news content and make it available to those who do not have the means to afford the tremendous cost of newspaper subscriptions.
To give people their right to attain greater knowledge.

News Hack has developed tremendously since its first version for Android back in 2014. Originally, the application would parse through web pages itself, taking 1-2 minutes to access The Wall Street Journal and The New York Times articles for free. 
Now, News Hack has a server on AWS that uses a combination of parsing web pages and making API requests to pull article info from news sources and store it in the cloud. 
The iOS app accesses this database through a JSON response emitted from the server, taking only a couple of seconds before the user gets a list of detailed article information.
News Hack now also offers free access to USAToday articles.
Below you'll find some information on how News Hack brings free news to the world.


###Pulling Article Titles and URLs
The News Hack web service is hosted on Amazon Web Services with a LAMP architecture. 
It is responsible for pulling article titles, authors, urls, and snippets from different news sources.
For The New York Times and USAToday, it can do this by making API requests with a bit of php.
However, since The Wall Street Journal has no API, it has no other option but to parse through http://wsj.com to pull this information from the web.
In order to keep information up-to-date, the News Hack API has a script that makes these php files run every hour.

All this information gets stored in a MySQL database in the cloud.
In order to access this information, the web service has a couple of php pages that emit JSON responses with nicely formatted article information.
This makes it easy for the iOS app to quickly display the information in a Table View.
By having its own web service, News Hack can get article information faster to the app than relying on API requests which are not only slower, but also limit the number of requests that can be made per day.
Parsing web pages with the backend is also much faster than doing it through the app, also saving battery power and memory usage on the app.

###Getting Past Paywalls
The iOS app relies on google translate to break through paywalls news content providers put up.
By manipulating the article url, the iOS app can open a web page to view a 'translated' page from Japanese to English.
Since Google has special access to The New York Times, The Wall Street Journal, and USAToday so that subscribers can read their content in other languages, News Hack can take advantage of 'translating' an article into English.
This gets the user past the paywall, with the only disadvantage being a 'translating' redirect which takes a couple seconds to actually display the page.
If someone manages to parse a google translated page for article content, the News Hack web service could make access to article content much faster.

###Choosing Sources
Since making a request and formating article data takes a few seconds, the time to download article info from the web service can grow quickly if multiple news sources are requested at the same time.
To fix this issue, News Hack allows users to select their favorite sources with switches so that only their favorite sources load everytime the app opens.
This helps cut down the time it takes to load content significantly, enhancing ux tremendously.

###Search
Currently search is in beta and only available for The New York Times articles using their API.
Requests are made directly to The New York Times API and take several seconds.
This feature is really only there to allow users to search past content and access it for free.
It will most likely be improved once the USAToday API is back from its redesign.
 

