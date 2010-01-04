require 'rubygems'
require 'date'
require 'time'
require 'sinatra'
require 'inquisition'

module Rump
  def self.load_log(log)
    date = Date.today
    lines = []
    logfile = File.new(log,"r")
    logfile.each_line do |line|
      date = has_date(line) if has_date(line)
      lines << Line.new(line,date) if has_url(line) 
    end
    logfile.close
    lines
  end

  class Line
    attr_accessor :line_string, :time, :url, :user

    def initialize(line, date)
      @line_string = line
      set_url
      set_user
      set_time(date)
    end

    def to_s
      "#{time} #{user}: #{url}"
    end

    private
    def set_time(date)
      @time = Time.parse(/^\d\d:\d\d/.match(line_string).to_s, date)
    end

    def set_user
      @user = /<[\s]?[^\s]*>/.match(line_string)
    end

    def set_url
      @url = /http[s]?[^\s]*/.match(line_string)
    end
  end

  private
  def self.has_url(line)
    line.match(/http[s]?[^\s]*/) && !line.match(/-!-/)
  end

  def self.has_date(line)
    Date.parse(line) if /^---/.match(line)
  end

end

get '/' do
  "Hi"
end

get '/links/:logfile' do
  logfile = Inquisition.sanitize(params[:logfile],nil)
  Rump.load_log("input/##{logfile}.log").sort_by{|line|line.time}.reverse.map{|line|line.to_s}.join("<br/>")
end
