# Instagram Liker
 Chromedriver based script to like photos based on hashtags on Instagram


# How to set up
- Install ruby if neccessary (likely you will have it already)
- Open the Terminal (just search for the Terminal app)
- Go to the project folder (use this command)
  - `cd ` and drag the folder into the terminal which will fill the path automatically
  - press `enter`
  - You're now in the folder
- Run the command to set up your configuration
  - `mv configuration.sample configuration.rb`
- Open the `configuration.rb` file in a text editor and configure it with your details
- Install the required libraries (in the Ternimal)
  - `gem install bundler`
  - `bundle install`
- Make sure you have [Chrome](https://www.google.com/chrome/) installed
- Download and install [ChromeDriver](https://chromedriver.chromium.org/)
- Run this command in the Terminal to run the script
  - `ruby InstagramLiker.rb`