# Pawdoption

This app helps you find your next pet from local animal shelters!
Swipe through pets in a Tinder like interface to search for your next pet.
Swipring right will save the pet to your saved list for later viewing.

All pets have information such as age, breed, biograph and which shelter
they are located in! It gives you the contact and general information 
necessary to adopt the pet.

Pawdoption allows you to choose between swiping through dogs or cats.
(Option for both coming soon!)


![demo](screenshots/demo.gif)

<img src="screenshots/saved.png" width="500px"/>



## Get it for Android

Pawdoption is currently live on the Google Play Store!


<a href='https://play.google.com/store/apps/details?id=com.pybanana.pawdoption&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_gb/badges/images/generic/en_badge_web_generic.png'/></a>

## Get it on iOS

**Coming soon!**



# Development details

## The Pet API

All pet information was gathered through the [PetFinder](http://www.petfinder.com) API. 

I initially protyped this application by getting pet information from PetHarbor. I would
just generate the queries I needed and then scrape the page to get the information I needed.
PetHarbor doesn't have an API and I know scraping a website is generally frowned upon especially for
production apps so I emailed PetHarbor asking if it was okay if I did.

They said no.

So I ended up finding PetFinder and it saved the application! Luckily, PetFinder had everything I needed
and basically the same pets as PetHarbor so the app stayed the same, just the working's under the hood
changed. The only downside is that the API only allows 10k requests a day, anymore requests and you have to 
ask for special permission from PetFinder to go above that. I suspect you have to start paying at that
point. 