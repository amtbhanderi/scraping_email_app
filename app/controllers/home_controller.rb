require 'open-uri'
require 'selenium-webdriver'
require 'headless'


class HomeController < ApplicationController
  def index
  end

  def get_data

  	doc = Nokogiri::HTML(open(params["url"]))
  	#get all the links from home page and add it to one variable
  	community_links = doc.css('[class="community"] [class="cats"] ul a[href]').map {|element| element["href"]}
  	housing_links = doc.css('[class="housing"] [class="cats"] ul a[href]').map {|element| element["href"]}
  	jobs_links = doc.css('[class="jobs"] [class="cats"] ul a[href]').map {|element| element["href"]}

  	all_links = []
  	all_links = all_links + community_links
  	all_links = all_links + housing_links
  	all_links = all_links + jobs_links
  	all_links = all_links.uniq
  	@emails = []

  	all_links.each do |link|
  		#click on the link and open list page for that link
			parsh_post_list = Nokogiri::HTML(open("#{params["url"][0...-1]}#{link}"))
	  	post_list_links = parsh_post_list.css('[class="content"] ul a[href]').map {|element| element["href"]}.uniq
	  	post_list_links.delete("#")

			post_list_links.each do |post_link|
				port = post_link.split("//")[0]
				if port == "https:" || port == "http:"
					begin
						#click on the link and open cotent page for post
						parsh_job_detail = Nokogiri::HTML(open("#{post_link}"))

						#initializ Selenium
						options = Selenium::WebDriver::Chrome::Options.new
						options.add_argument('--headless')
						driver = Selenium::WebDriver.for :chrome, options: options

						#navigate to the url
						driver.navigate.to "#{post_link}"
						#click on the email button
						driver.find_element(:class,'reply_button').click
						sleep 10

						#get email and save it to email array
						if driver.find_element(:class,'anonemail').text
							@emails << driver.find_element(:class,'anonemail').text
						end	
						#close the window
						driver.close
					rescue
						driver.close
					end	
				end	
			end	
  	end	

  	respond_to do |format|
      format.js {}
    end
  end
end
