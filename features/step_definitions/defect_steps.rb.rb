When /^I receive pivotal tracker activity:$/ do |table|
  table.hashes.each do |data|
    PivotalService.activity(data)
  end
end

Then /^the pivotal tracker defects for "([^"]*)" should be:$/ do |repo_name, table|
  repo = Repo.find_by_name! repo_name
  assert_equal table.hashes.map {|data| data["id"] }, repo.pivotal_defects.bugs.pluck(:ticket_id)
end

Given /^I have a repository "([^"]*)" with a pivotal project id "([^"]*)"$/ do |repo_name, project_id|
  Repo.create! name: repo_name, url: ""
  PivotalService.stubs(:config).returns({repo_name => [project_id]})
end