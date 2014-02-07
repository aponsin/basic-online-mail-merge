require 'csv'

class EmailsController < ApplicationController

  EMAIL_REGEXP = /^(\W?([\w\s]+)\W+)?(\w[\w\+\-\.]+@[\w\-\.]+)\W?$/i

  def new
    @email = Email.new
  end

  def create
    @email = Email.new(params[:email])
    if @email.valid?

      @header, *data = CSV.parse(@email.contacts)
      @header.map!{ |h| h.try :strip }
      data.map!{|f| f.map{ |i| i.try :strip} }
      @col_header = (1..@header.count).map{|i| "col#{i}"}

      emails = []

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

        [:to, :cc, :bcc].each do |f|
          unless valid_field?(f, email[f], @email)
            flash[:error] = "No emails were sent due to invalid email encountered in at least one attempt."
            render :new
            return
          end
        end

        emails << email
      end

      emails.each do |email|
        ApplicationMailer.email(OpenStruct.new(email)).deliver
      end

      flash[:sucess] = "#{data.count} email were sent through mailjet for campaign '#{@email.campaign}'"

      redirect_to new_email_path
    else
      render :new
    end
  end

  private

  def valid_field?(field_type, value, email_object)
    if value =~ EMAIL_REGEXP || value.blank?
      true
    else
      email_object.errors.add(field_type, " field: \"#{value}\" is an invalid email address")
      false
    end
  end

  def insert_dynamic_fields(string, fields)
    replaced_field = string.dup
    @header.each_with_index do |h, i|
      replaced_field.gsub!(/\{\{#{Regexp.escape(h.downcase)}\}\}/i, fields[i] || "")
    end
    @col_header.each_with_index do |h, i|
      replaced_field.gsub!(/\{\{#{Regexp.escape(h.downcase)}\}\}/i, fields[i] || "")
    end
    replaced_field
  end

end
