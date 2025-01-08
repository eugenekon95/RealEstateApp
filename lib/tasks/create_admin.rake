# frozen_string_literal: true

task create_admin: :environment do
  puts 'Creating admin'
  User.create!(
    email: 'admin@estatery.com',
    password: 'nimdassap',
    password_confirmation: 'nimdassap',
    role: :admin
  )
  puts 'Done! Now you can login with "admin@estatery.com" using password "nimdassap"'
end
