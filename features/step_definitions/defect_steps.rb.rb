Given /^I receive pivotal tracker activity:$/ do |table|
  # table is a | 1  | 50         | story_create | New bug     | bug        |pending
  table.hashes.each do |data|
    PivotalService.activity(data)
  end
end

Then /^the pivotal tracker defects should be:$/ do |table|
  assert_equal table.hashes.map {|data| data["id"] }, PivotalDefect.bugs.pluck(:ticket_id)
end