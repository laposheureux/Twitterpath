# Twitterpath

This is an application that provides a lightweight interface to Twitter for one user.

## Description

This app will authenticate with the Twitter API, display your timeline, allow you to favorite and retweet and reply from it and to compose tweets.

## Codepath Details

Time spent: 17 hours

## User Stories

#### Search results page

* [x] Required: User can sign in using OAuth login flow
* [x] Required: User can view last 20 tweets from their home timeline
* [x] Required: Signed in user will be persisted across restarts
* [x] Required: In the home timeline, user can view tweets with the user profile picture, username, tweet text, and timestamp laid out with Auto Layout.
* [x] Required: User can pull to refresh
* [x] Required: User can compose a new tweet by tapping on a compose button
* [x] Required: User can tap on a tweet to view it, with controls to retweet, favorite, and reply
* [x] Optional: Countdown for the tweet character limit
* [x] Optional: After creating a tweet, it should be visible immediately in the timeline
* [x] / [ Mostly ] Optional: Retweeting and favoriting should increment the retweet and favorite count
  * If retweeting/favoriting from the list and then the user pushes to single view, the count is wrong.
* [x] Optional: Replies should be prefixed with the username and the reply_id should be set when posting the tweet
* [ ] Optional: User can load more tweets once they reach the bottom of the feed using infinte loading.
* [x] Extra: User can also tap on reply/retweet/favorite from their home timeline


## GIF Walkthrough

  ![twitterpath](twitterpath.gif)

Verification of the last state of the app can be seen here: https://twitter.com/aarontesterson1 - example of replies here: https://twitter.com/aarontesterson1/status/793292220530950145

