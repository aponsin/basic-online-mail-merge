class ApplicationMailer < ActionMailer::Base

  def email(email)
    @subject = email.subject
    @body    = email.body

    headers({
      'X-No-Spam'                     => 'True',
      'X-Mailjet-Campaign'            => email.campaign
    })

    mail({
      from:    email.from,
      to:      email.to,
      cc:      email.cc,
      bcc:     email.bcc,
      subject: email.subject
    })
  end

end