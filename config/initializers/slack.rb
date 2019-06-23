Slack = Slack::Notifier.new ENV['slack_webhook_url'] do
  defaults channel: "#events",
           username: ENV["name"]
end
