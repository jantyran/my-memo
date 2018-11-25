require "rubygems"
require 'bundler/setup'
require "sinatra"
require 'active_record'
require 'sinatra/reloader'
# require 'rack-contrib'
require 'json'

enable :method_override

#
# ------------ global variable -----------
#

$json_file_path = 'json/test.json'
$json_data = open($json_file_path) do |io|
  JSON.load(io)
end
# get memos array from json data
$memos = $json_data['memos']

#
# ----------- method -----------
#

# return the memo related with the id
def getMemo(m_id)
  r_memo = ""
  $memos.each do |memo|
    if memo['id'].to_s == m_id.to_s then
      r_memo = memo
      break
    else
      r_memo = "unko"
    end 
  end
  return r_memo
end

# rewrite the json_data
def rewriteJson
  File.open("json/test.json", 'w') do |file|
    JSON.dump($json_data, file)
  end
end

#  
# ----------- routing -----------
#

# root
get "/" do
  @memos = $memos
  erb :index
end

# show memo contents
get "/memo/:id" do
  @memo = getMemo(params[:id])
  erb :memo_details
end

# to create page
get "/create" do
	erb :addNew
end

# creating process
post "/addNew" do

  # create id for new memo_data
  last_id = 0
  $memos.each do |memo|
    if last_id <= memo['id'].to_i then
      last_id = memo['id'].to_i + 1
    end
  end

  # create new json data with appended new memo
  new_memo = {"id" => last_id.to_s, "title" => params[:title], "body" => params[:body]}
  $json_data['memos'].push(new_memo)
  # new_json = JSON.pretty_generate(json_data) ---- JSON.dumpでhashから自動的にjsonフォーマットに変更されるからいらなかった。

  rewriteJson

	redirect '/'
	erb :index
end

# deleting process
delete '/memo/delete/:id' do

  num = 0
  $memos.each do |memo|
    if memo['id'].to_s == params[:id].to_s then
      $json_data["memos"].delete_at(num)
      break
    end 
    num += 1
  end

  rewriteJson

  redirect '/'
  erb :index
end

# to editer page.
get '/memo/edit/:id' do
  @memo = getMemo(params[:id])
  erb :edit
end

# editing process
patch '/memo/do-edit/:id' do

  new_memo = {"id" => params[:id].to_s, "title" => params[:title], "body" => params[:body]}
  
  # create new data
  num = 0
  $memos.each do |memo|
    if memo['id'].to_s == params[:id].to_s then
      $json_data["memos"][num]["title"] = new_memo["title"]
      $json_data["memos"][num]["body"] = new_memo["body"]
      break
    end 
    num += 1
  end

  rewriteJson
  
  redirect '/'
  erb :index
end






