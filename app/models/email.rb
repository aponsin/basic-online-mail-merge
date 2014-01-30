class Email
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :campaign, :from_email, :from_name, :contacts, :subject, :to, :cc, :bcc, :body

  validates_presence_of :campaign, :from_email, :from_name, :contacts, :subject, :to, :body


  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end