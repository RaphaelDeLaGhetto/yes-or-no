# Seed add you the ability to populate your db.
# We provide you a basic shell for interaction with the end user.
# So try some code like below:
#
#   name = shell.ask("What's your name?")
#   shell.say name
#
email     = shell.ask "Which email do you want use for logging into admin?"
password  = shell.ask "Tell me the password to use:", :echo => false

shell.say ""

account = Account.new(:email => email, :name => "Foo", :surname => "Bar", :password => password, :password_confirmation => password, :role => "admin")

if account.valid?
  account.save
  shell.say "================================================================="
  shell.say "Account has been successfully created, now you can login with:"
  shell.say "================================================================="
  shell.say "   email: #{email}"
  shell.say "   password: #{?* * password.length}"
  shell.say "================================================================="
else
  shell.say "Sorry, but something went wrong!"
  shell.say ""
  account.errors.full_messages.each { |m| shell.say "   - #{m}" }
end

shell.say ""

agent = Agent.create(email: 'daniel@capitolhill.ca', password: 'secret')
posts = [
  { url: 'http://terrygurno.com/wp-content/uploads/2016/02/Yes-or-no.jpg', tag: 'Written on palms', approved: true, agent_id: agent.id },
  { url: 'http://denisewakeman.com/wp-content/uploads/2015/07/Ghost-Blogging-Yes-or-No-Poll-c.png', tag: 'Ghost blogging', approved: true, agent_id: agent.id },
  { url: 'http://4.bp.blogspot.com/-MBQjm0C9UhE/UReuPAbyovI/AAAAAAAAATY/RaKP2UoFsZ0/s1600/Yes-no.jpg', tag: 'Thai movie', approved: true, agent_id: agent.id }
]

posts.each do |post|
  Post.create(post)
end
