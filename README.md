# Instagram Liker
 Chromedriver based script to like photos based on hashtags on Instagram


# How it works
The script will do the following when run:
- Log you in and save cookies so no login is required next time
- Shuffle the list of Instagram URLs you provided and go through them one by one
  - For each Tag/Location it will go through the "Most Recent" posts
  - If the post has more likes than the like limit (set in `MIN_LIKES_TO_LIKE`) the script will like the post
  - Move to the next post until there are no more posts or the like limit has been reached (`MAX_PHOTOS`)
- Once all URLs have been liked it waits (`SLEEP_TIME_BETWEEN_ITTERATIONS`) and then restarts from the beginning

`VARIABLES` are set in the `configuration.rb` file.

# How to set up
- Install ruby if neccessary (likely you will have it already)
- Open the Terminal (just search for the Terminal app)
- Go to the project folder (use this command)
  - `cd ` and drag the folder into the terminal which will fill the path automatically
  - press `enter`
  - You're now in the folder
- Run the command to set up your configuration
  - `cp configuration.sample configuration.rb`
- Open the `configuration.rb` file in a text editor and configure it with your details
- Install the required libraries (in the Ternimal)
  - `gem install bundler`
  - `bundle install`
- Make sure you have [Chrome](https://www.google.com/chrome/) installed
- Download and install [ChromeDriver](https://chromedriver.chromium.org/)
- Run this command in the Terminal to run the script
  - `ruby InstagramLiker.rb`
  - To stop the script press `CTRL + C`