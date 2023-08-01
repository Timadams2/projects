#! /usr/bin/env ruby

require "sinatra"
require "sinatra/content_for"
require "sinatra/reloader"
require "tilt/erubis"

require_relative "database_persistence"

configure do 
  enable :sessions
  set :session_secret, "da5a1b209532b4f2f6d73b63dc9f8adb3f5bd0d838c08a83f8fa849f4d45d514"
  also_reload "database_persistence.rb"
end 

helpers do
  
  def find_total
    ints = []
    @storage.amounts.each do |row|
      ints << row["amount"].to_f
    end
    fix_payment(ints.sum.to_s)
  end
  
  
  def find_total_for_cat(category)
    ints = []
    @storage.amounts_for_category(category).each do |row|
      ints << row["amount"].to_f 
    end
    fix_payment(ints.sum.to_s)
  end
  
  def fix_date(date_from_db)
    new_date = fix_month(date_from_db.split('-')[1]) + '-' + date_from_db.split('-')[2] + '-' + date_from_db.split('-')[0][-2, 2]
    new_date
  end
  
  def fix_month(month)
    return month unless month[0] == '0'
    return month[1]
  end
end

def valid_amount?(amount)
  valid_format?(amount)
  amount.chars.map {|char| return false if %w(1 2 3 4 5 6 7 8 9 0 .).include?(char) == false}
  
  dollars_cents = amount.split('.')
  return false if (amount.to_i == 0) || (dollars_cents[0].size > 6) || (dollars_cents[1].size > 2)
  true
end

def valid_format?(amount)
  amount.split('.').size == 2
end

def valid_category?(category)
  return false if (category.size > 30) || (category.size == 0)
  true
end

def valid_date?(date)
  date_pieces = date.split("-")
  return false unless date_pieces.size == 3
  return false unless (date_pieces[0].length == 2) && (date_pieces[0].to_i > 0) && (date_pieces[0].to_i <= 12)
  return false unless (date_pieces[1].length == 2) && (date_pieces[1].to_i > 0) && (date_pieces[1].to_i <= 31)
  return false unless (date_pieces[2].length == 4) && (date_pieces[2].to_i > 1995) && (date_pieces[2].to_i <= 2023)
  true
end

def revert_date(date)
  new_date = date.split('-')[2] + '-' + date.split('-')[0] + '-' + date.split('-')[1]
  new_date
end 

def fix_payment(amount)
  if amount.chars.include?('.') == false
    amount.concat('.00')
  elsif amount.chars.count('.') == 1 && amount.split(".")[1].size == 1
    amount.concat('0')
  else
    amount
  end
end

before do
  @storage = DatabasePersistence.new
end

get "/" do
  @payments = @storage.display_payments
  erb :home
end

get "/new" do
  erb :date_or_not
end

post "/date_or_not" do
  if params[:y_or_n].downcase == "y"
    erb :new_today
  elsif params[:y_or_n].downcase == "n"
    erb :new_with_date
  else 
    redirect "/new"
  end
end

post "/new_today" do 
  category = params[:new_category]
  payment = fix_payment(params[:new_amount])
  if valid_amount?(payment) && valid_category?(category)
    session[:success] = "New Payment Recorded"
    @storage.new_payment(payment, category)
    redirect "/"
  else 
    session[:error] = "Invalid input, please try again"
    redirect "/new"
  end
end

post "/new_with_date" do 
  category = params[:new_category]
  amount = fix_payment(params[:new_amount])
  date = params[:new_date]
  if valid_amount?(amount) && valid_category?(category) && valid_date?(date)
    session[:success] = "New Payment Recorded"
    @storage.new_payment_with_date(amount, revert_date(date), category)
    redirect "/"
  else 
    session[:error] = "Invalid input, please try again"
    redirect "/new"
  end
end

get "/delete/:amount/:category/:date" do
  id = @storage.find_payment_id(params[:amount], params[:category], params[:date]).first["id"]
  @storage.delete_payment(id)
  redirect "/"
end

get "/sort" do
  erb :sort
end

get "/sort/:month/:year" do
  @month = params[:month]
  @year = params[:year]
  @payments = @storage.payments_for_month(@month, @year)
  erb :month
end

post "/sort" do 
  month = params[:month]
  year = params[:year]
  redirect "/sort/#{month}/#{year}"
end

get "/:category" do
  @category = params[:category]
  @payments = @storage.payments_for_category(@category)
  erb :category
end 

