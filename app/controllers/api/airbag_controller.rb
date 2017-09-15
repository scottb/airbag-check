module Api
  class AirbagController < ApplicationController
    def show
      session = Capybara::Session.new(:headless_chrome)
      begin
        session.visit "https://www.airbagrecall.com/en/check-your-vehicle"
        session.click_on("Enter a license plate or VIN manually")
        session.fill_in("vin", with: params[:plate].upcase)
        session.select(params[:state].gsub(/\s+/, '').upcase)
        session.click_on("Check my vehicle")

        wait = Selenium::WebDriver::Wait.new(timeout: 30)
        wait.until { /(Are You At Risk|We are having trouble identifying your vehicle)/.match(session.body) }

        if session.has_no_css?("#notice.correction")
          details = session.all("#vehicle-details .detail").map(&:text)

          session.click_on("Yes, this is my vehicle!")

          recall_info = session.find("#recall-info")
          has_recalls = recall_info.find("h1").text == "There are active recalls on your vehicle."
          airbag_recalls = has_recalls && !recall_info.has_no_css?("span.airbag-icon")
          render json: { recalls: airbag_recalls, details: details }
        else
          render json: { recalls: false, details: nil }
        end
      rescue
        render json: { error: true }
      ensure
        session.try(&:driver).try(&:quit)
      end
    end
  end
end
