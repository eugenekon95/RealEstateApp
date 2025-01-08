class EmailInterceptor
  def self.delivering_email(mail)
    return if mail.to.all? { |email| email.ends_with?('@anadeainc.com') }

    mail.to = ['estateryapp@gmail.com']
    mail.subject = "EMAIL FROM : #{Rails.env.upcase} #{mail.subject}"
  end
end
