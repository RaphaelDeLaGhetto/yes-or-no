namespace :post do
  desc "Add images in directory to agent's account. Usage: post:images['email','./public/path/to/images']"
  task :images, [:email, :path] => :environment do |task, args|
    next puts "Usage: post:images['email','./public/path/to/images']" if args.count != 2

    agent = Agent.find_by(email: args[:email])
    agent = Agent.new(email: args[:email]) if agent.nil?
    
    if !agent.save
      puts agent.errors.full_messages
      next
    end

    begin
      Dir.entries(args[:path]).each do |file|
        next if File.directory? file
        post = agent.posts.new(agent: agent,
                               url: "#{args[:path].gsub(/(^\.\/public)|(\/$)/, '')}/#{file}",
                               tag: file.split('.')[0])
        if !post.save
          puts post.errors.inspect
        end
      end
    rescue Errno::ENOENT => e
      puts e
    end
  end
end
