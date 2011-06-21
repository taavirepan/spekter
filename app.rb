require 'rubygems'
#require 'mongo'
#require 'bson'
require 'sinatra'
require 'erb'
require 'net/http'
require 'nokogiri'
require 'json'

get '/' do
  @header = "Search"
  
  @main = "<form action='/view'>"
  @main += "<input type='text' name='query'>"
  @main += "<input type='submit' value='Search'>"
  @main += "</form>"

  erb :index
end

def get_spectrum(q)
  post_data = {:spectra => q, :low_wl => 380, :upp_wl => 780, :unit => 1,
               :show_av => 4, :allowed_out => 1, :forbid_out => 1,
               :intens_out => 1, :show_obs_wl => 1}
  res = Net::HTTP.post_form(URI.parse("http://physics.nist.gov/cgi-bin/ASD/lines1.pl"), post_data)
  
  doc = Nokogiri::HTML(res.body.gsub("&nbsp;", " "))
  
  ret = Array.new
  doc.css('.odd').each do |row|
    arr = row.children().to_a()
    ret << {:wavelength => arr[0].inner_text.to_f, :intensity => arr[2].inner_text.to_f}
  end
  doc.css('.evn').each do |row|
    arr = row.children().to_a()
    ret << {:wavelength => arr[0].inner_text.to_f, :intensity => arr[2].inner_text.to_f}
  end
  
  ret
end

get '/view' do
  @header = "Search results"
  
  s = get_spectrum(params[:query])
  @json = s.to_json
  
  @main = "<canvas id='spectrum' width='800' height='200'>" 
  @main += "Your browser doesn't support <b>canvas</b> element."
  @main += "</canvas><br>"
  @main += "<input id='minL' value='380'>..<input value='780' id='maxL'> nm<br>";
  @main += "Exposure: <input id='exp' value='1.0'><input value='Draw' type='button'><br>";
  @main += "<div id='info'></div>"

  erb :index
end

get '/debug' do
  post_data = {:spectra => "Hg I", :low_wl => 380, :upp_wl => 780, :unit => 1,
               :show_av => 4, :allowed_out => 1, :forbid_out => 1,
               :intens_out => 1, :show_obs_wl => 1}
  res = Net::HTTP.post_form(URI.parse("http://physics.nist.gov/cgi-bin/ASD/lines1.pl"), post_data)

  res.body
end
