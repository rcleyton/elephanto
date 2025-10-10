require "simplecov"

SimpleCov.start "rails" do
  SimpleCov.command_name "test_process_#{Process.pid}"
  merge_timeout 3600
  add_filter "app/channels"
  add_filter "app/jobs"
  add_filter "app/mailers"
end

puts "SimpleCov started (PID #{Process.pid})"
