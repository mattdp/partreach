desc "Provide basic sample data so site has some examples"
task populate: :environment do
	User.create_with_dummy_password("Matt","mdpfwds@gmail.com",true)
	User.create_with_dummy_password("Matt","rob@supplybetter.com",true)
end