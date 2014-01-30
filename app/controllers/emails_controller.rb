require 'csv'

class EmailsController < ApplicationController

  def new
    @email = Email.new
  end

  def create
    @email = Email.new(params[:email])
    if @email.valid?

      @header, *data = CSV.parse(@email.contacts)
      @col_header = (1..@header.count).map{|i| "col#{i}"}

      data.each do |fields|

          email = {
            campaign: @email.campaign,
            subject:  insert_dynamic_fields(@email.subject, fields),
            from:     "#{insert_dynamic_fields(@email.from_name, fields)} <#{insert_dynamic_fields(@email.from_email, fields)}>",
            to:       insert_dynamic_fields(@email.to, fields),
            cc:       insert_dynamic_fields(@email.cc, fields),
            bcc:      insert_dynamic_fields(@email.bcc, fields),
            body:     insert_dynamic_fields(@email.body, fields)
          }

          ApplicationMailer.email(OpenStruct.new(email)).deliver
      end

      flash[:sucess] = "#{data.count} email were sent through mailjet for campaign '#{@email.campaign}'"

      redirect_to new_email_path
    else
      render :new
    end
  end

  private

  def insert_dynamic_fields(string, fields)
    @header.each_with_index do |h, i|
      string.gsub!(/\{\{#{Regexp.escape(h.downcase)}\}\}/i, fields[i])
    end
    @col_header.each_with_index do |h, i|
      string.gsub!(/\{\{#{Regexp.escape(h.downcase)}\}\}/i, fields[i])
    end
    string
  end

end
