When /^I receive pivotal tracker activity:$/ do |table|
  table.hashes.each do |data|
    PivotalService.activity(data)
  end
end

Then /^the pivotal tracker open defects for "([^"]*)" should be:$/ do |repo_name, table|
  repo = Repo.find_by_name! repo_name
  assert_equal table.hashes.map {|data| data["id"] }, repo.pivotal_defects.open_defects.pluck(:ticket_id)
end

Given /^I have a repository "([^"]*)"$/ do |repo_name|
  @repo = Repo.create! name: repo_name, url: ""
end

def resolve_status(status_phrase)
  case status_phrase
    when "open" then PivotalDefect::OPEN
    when "closed" then PivotalDefect::CLOSED
    else nil
  end
end

Given /^I have a pivotal tracker defect:$/ do |table|
  table.hashes.each do |defect_data|
    defect_title = defect_data["title"]
    defect_status = resolve_status(defect_data["status"])
    ticket_id = defect_data["id"]
    PivotalDefect.create! title: defect_title, status: defect_status, repo: @repo, ticket_id: ticket_id
  end
end

When /^I receive zendesk activity:$/ do |table|
  # table is a | 123 | urgent   | Broken | new    |pending
  table.hashes.each do |zendesk_data|
    ZendeskService.activity(zendesk_data)
  end
end

Then /^I should have the following open zendesk defects:$/ do |table|
  # table is a | 123 |pending
  expected_ids = table.hashes.map {|assert_data| assert_data["id"] }
  result = @repo.zendesk_defects.open_defects.map &:ticket_id
  assert_equal expected_ids, result
end

When /^the repository "([^"]*)" has a pivotal project id "([^"]*)"$/ do |repo_name, project_id|
  PivotalService.stubs(:config).returns({repo_name => [project_id]})
end

When /^the repository "([^"]*)" has a zendesk identifier "([^"]*)"$/ do |repo_name, zendesk_id|
  ZendeskService.stubs(:config).returns({zendesk_id => repo_name})
end