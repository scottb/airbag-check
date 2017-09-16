module Api
  class AirbagController < ApplicationController
    def show
      browser = Capybara::Session.new(:selenium_chrome_headless)
      begin
        browser.visit "https://www.airbagrecall.com/en/check-your-vehicle"
        browser.click_on("Enter a license plate or VIN manually")
        browser.fill_in("vin", with: params[:plate].upcase)
        browser.select(params[:state].gsub(/\s+/, '').upcase)
        browser.click_on("Check my vehicle")

        wait = Selenium::WebDriver::Wait.new(timeout: 30)
        wait.until { /(Are You At Risk|We are having trouble identifying your vehicle)/.match(browser.body) }

        if browser.has_no_css?("#notice.correction")
          details = browser.all("#vehicle-details .detail").map(&:text)

          browser.click_on("Yes, this is my vehicle!")

          recall_info = browser.find("#recall-info")
          has_recalls = recall_info.find("h1").text == "There are active recalls on your vehicle."
          airbag_recalls = has_recalls && !recall_info.has_no_css?("span.airbag-icon")
          render json: { recalls: airbag_recalls, details: details }
        else
          render json: { recalls: false, details: nil }
        end
      rescue
        render json: { error: true }
      ensure
        browser.try(&:driver).try(&:quit)
      end
    end
  end
end
