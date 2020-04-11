#!/usr/bin/env ruby

#
#  InstagramLiker.rb
#
#  Created by Christian Lerke on 03/12/2016.
#  Copyright © 2016 Christian Lerke. christianlerke.com. All rights reserved.
#

require "selenium-webdriver"
load './configuration.rb'

@wait = Selenium::WebDriver::Wait.new timeout: 30

options = Selenium::WebDriver::Chrome::Options.new
# options.add_argument("--window-size=3000,10000)
options.add_argument('--headless') if HEADLESS
      
@driver = Selenium::WebDriver.for :chrome, options: options

total_new_likes = 0
total_old_likes = 0
total_browsed = 0
total_itterations = 0

def login_and_save_cookies
  puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Logging In"
  @driver.navigate.to 'https://www.instagram.com/accounts/login/'
  sleep 5

  @wait.until { @driver.find_element css: "input[name=username]" }
  @wait.until { @driver.find_element css: "input[name=password]" }
  username = @driver.find_element css: "input[name=username]"
  password = @driver.find_element css: "input[name=password]"
  username.send_keys INSTAGRAM_USER
  password.send_keys INSTAGRAM_PASS
  password.send_keys :enter

  sleep 5

  # check that login was successfull
  @wait.until { @driver.find_element css: "#react-root main[role=main] article img" }
  puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Login successfull" if VERBOSE

  if (notification_popup_buttons = @driver.find_elements css: "div[role=presentation] div[role=dialog] button").count > 0
    puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Popup found" if VERBOSE
    notification_popup_buttons.last.click
    puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Popup dismissed" if VERBOSE
  end

  sleep 1

  save_cookies!
end

def save_cookies!
  cookies = @driver.manage.all_cookies
  File.write('cookies.dump', Marshal.dump(cookies))
  puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Cookies saved for next time" if VERBOSE
end

begin
  
  if File.exists? 'cookies.dump'
    puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Cookies found, attempting to load" if VERBOSE

    @driver.navigate.to 'https://www.instagram.com'
    sleep 3

    cookies = Marshal.load(File.read('cookies.dump'))
    cookies.each do |cookie|
      @driver.manage.add_cookie cookie
    end

    @driver.navigate.to 'https://www.instagram.com'
    sleep 3
    
    if(@driver.find_elements(css: "#react-root main[role=main] article img").count > 0)
      puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Logged in with cookies" if VERBOSE
    else
      puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Cookies invalid, logging in" if VERBOSE
      login_and_save_cookies
    end
  else
    login_and_save_cookies
  end

  while true
    INSTAGRAM_URLS.shuffle.each do |url|

      puts "\n#{Time.now.strftime("%d %b %H:%M:%S")} | #{url}"

      @driver.navigate.to url
      sleep 5

      @wait.until { @driver.find_element(xpath: "//h2[normalize-space() = 'Most recent']/following-sibling::div") }

      # open the preview
      puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Opening first Photo" if VERBOSE
      @driver.find_element(xpath: "//h2[normalize-space() = 'Most recent']/following-sibling::div//img/../..").click
      sleep 3
      @wait.until { @driver.find_element(css: 'svg[aria-label="Share Post"]') }

      photos_browsed = 0
      new_likes = 0
      old_likes = 0

      while @driver.find_elements(xpath: "//a[contains(@class, 'coreSpriteRightPaginationArrow') and normalize-space() = 'Next']").count > 0 and photos_browsed < MAX_PHOTOS
        likes = if @driver.find_elements(xpath: "//button[boolean(number(substring-before(normalize-space(), ' likes')))]").count > 0
          @driver.find_element(xpath: "//button[boolean(number(substring-before(normalize-space(), ' likes')))]").text.gsub(/[,\.\D\s]/, "").to_i
        end
        if !likes.nil? and likes >= MIN_LIKES_TO_LIKE
          if @driver.find_elements(css: "svg[aria-label=Like]").count > 0
            puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Liking Photo (#{likes} likes)" if VERBOSE
            new_likes += 1
            total_new_likes += 1
            sleep SLEEP_TIME_BETWEEN_LIKES.sample
            @driver.find_element(css: "svg[aria-label=Like]").click
            sleep 1
          else
            old_likes += 1
            total_old_likes += 1
            puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Already Liked" if VERBOSE
          end
        else
          puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Too Few Likes (min #{MIN_LIKES_TO_LIKE})" if VERBOSE
        end

        photos_browsed += 1
        total_browsed += 1

        print "#{Time.now.strftime("%d %b %H:%M:%S")} | New Likes #{new_likes} | Old Likes #{old_likes} | Browsed #{photos_browsed}\r"
        $stdout.flush
        puts "\n" if VERBOSE

        if @driver.find_elements(xpath: "//a[contains(@class, 'coreSpriteRightPaginationArrow') and normalize-space() = 'Next']").count > 0
          puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Moving to next photo" if VERBOSE
          @driver.find_element(xpath: "//a[contains(@class, 'coreSpriteRightPaginationArrow') and normalize-space() = 'Next']").click
          sleep 3
          @wait.until { @driver.find_element(css: 'svg[aria-label="Share Post"]') }
        end
      end

      puts "#{Time.now.strftime("%d %b %H:%M:%S")} | No Next Link or MAX_PHOTOS reached" if VERBOSE
      
      sleep SLEEP_TIME_BETWEEN_URLS

    end

    puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Completed Iterations: #{i}"

    total_itterations += 1

    sleep SLEEP_TIME_BETWEEN_ITTERATIONS
    
  end

rescue => e
  puts "#{Time.now.strftime("%d %b %H:%M:%S")} | Completed Iterations: #{total_itterations} | New Likes #{total_new_likes} | Old Likes #{total_old_likes}"
  raise e
end

@driver.close
