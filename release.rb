require 'rubygems'

def install_gem(name, version=Gem::Requirement.default)
  begin
    gem name, version
  rescue LoadError
    print "ruby gem '#{name}' not found, " <<
      "would you like to install it (y/N)? : "
    answer = "y"
    if answer[0].downcase.include? "y"
      Gem.install name, version
    else
      exit(1)
    end
  end
end

install_gem 'axlsx'

require 'axlsx'
require 'rest-client'
require 'json'

p = Axlsx::Package.new
p.use_shared_strings = true

# Fetch from JIRA
project_key = ENV['PROJECT_KEY']
user = 'Kalauzovic'
password = 'dummy'
jira_path = 'jira.fidor.de'
jira_url = "http://#{user}:#{password}@#{jira_path}/rest/api/2/search?"
filter_label = ENV['FILTER_LABEL']
# filter = "fields=urlPath,key,self,labels,type,priority,summary&jql=project+%3D+%22#{project_key}%22+AND+type+%3D+%22Change Request%22+AND+status+%3D+%22Backlog%22"
filter = "fields=issueType,key,priority,labels,summary,customfield_13035&jql=project+%3D+%22#{project_key}%22+AND+%22Patch+number%22+%7E+%22#{filter_label}%22"

response = RestClient::Request.execute(:method => :get, :url => jira_url+filter, :timeout => 90000000)
#RestClient.get(jira_url+filter)
if(response.code != 200)
 raise "Error with the http request!"
end


data = JSON.parse(response.body)

p.workbook do |wb|
  # define your regular styles
  styles = wb.styles
  title = styles.add_style :sz => 15, :u => true
  header = styles.add_style :bg_color => '355275', :fg_color => 'FF'

  release_name = `echo "${RELEASE_NAME}"`
  wb.add_worksheet(:name => '#{filter_label}') do  |ws|
     ws.add_row ['Release tickets'], :style => title
     ws.add_row
     ws.add_row ['Ticket', 'Summary','Priority', 'URL'], :style => header
     data['issues'].each do |issue|
       ws.add_row [ issue['key'], issue['fields']['summary'], issue['fields']['priority']['name'],"http://#{jira_path}/browse/#{issue['key']}"]
     end
   end
end
p.serialize 'release.xlsx'

