require 'json'
require 'net/http'
require 'uri'
require 'date'

# send message
class SlackWraper
  def self.post(text)
    data = { "text" => text,"unfurl_links": true,"unfurl_media": true }
    request_url = "https://hooks.slack.com/services/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"
    uri = URI.parse(request_url)
    Net::HTTP.post_form(uri, {"payload" => data.to_json})
  end
end



def lambda_handler(event:, context:)
    # TODO implement
    # { statusCode: 200, body: JSON.generate('Hello from Lambda!') }

    # core imple
    forgetting_curve_array = [1,7,14,30,60]
    my_daily_repo_url = "https://github.com/neco3s/daily_repo/blob/main/"
    first_day = Date.parse('2023-04-18')
    today = Date.today
    # puts first_day

    match_dates = Array(first_day...today).select do |date|
        forgetting_curve_array.find do |day|
            if date + day ==today
                true
            else
                false
            end
        end
    end

    # send daily_report
    match_dates.each do |date|
        directory_structure = date.to_s.gsub(/-/,'/')
        daily_report_url = my_daily_repo_url + directory_structure +".md/"
        uri = URI.parse(daily_report_url)
        response = Net::HTTP.get_response(uri)
        if response.is_a?(Net::HTTPSuccess)
          puts '日報が存在します'
          SlackWraper.post(daily_report_url)
        else
          puts '日報が存在しません'
        end
        sleep 3
    end

    # SlackWraper.post("forgetting_curve_daily_report")

    #note, slackへ同じURLをすぐに送信するとmediaが展開されないことがある
end
