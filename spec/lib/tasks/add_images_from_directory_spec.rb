require "spec_helper"
require "rake"
require "./lib/tasks/add_images_from_directory"

RSpec.describe "post:images", type: :rake do
  it { is_expected.to depend_on(:environment) }

  context 'errors' do
    it "returns usage info if fewer than two params are passed" do
      expect { subject.execute }.to output("Usage: post:images['email','./public/path/to/images']\n").to_stdout
    end

    it "returns usage info if greater than two params are passed" do
      expect { subject.execute ['a', 'b', 'c'] }.to output("Usage: post:images['email','./public/path/to/images']\n").to_stdout
    end

    context 'email mangled' do
      it "outputs an error" do
        expect { subject.execute({ email: 'notanemail.com',
                                   path: 'fake/path/' }) }.to output("Email is invalid\n").to_stdout
      end

      it "does not add a new agent to the database" do
        expect(Agent.count).to eq(0)
        subject.execute({ email: 'notanemail.com', path: 'fake/path/' })
        expect(Agent.count).to eq(0)
      end
    end

    context 'path does not exist' do
      it "outputs an error" do
        expect { subject.execute({ email: 'someguy@example.com',
                                   path: 'fake/path/' }) }.
          to output("No such file or directory @ dir_initialize - fake/path/\n").to_stdout
      end
    end
  end

  context 'success' do
    before :each do
      @files = ["image1.jpg", "image2.jpg", "image3.jpg"]
      allow(Dir).to receive(:entries).and_return(@files)
    end

    context 'agent not registered' do
      it 'adds agent to the database' do
        expect(Agent.count).to eq(0)
        subject.execute({ email: 'someguy@example.com', path: './public/path/' })
        expect(Agent.count).to eq(1)
        expect(Agent.first.posts.count).to eq(3)
      end

      it 'adds three posts to the database' do
        expect(Post.count).to eq(0)
        subject.execute({ email: 'someguy@example.com', path: './public/path/' })
        posts = Post.all
        expect(posts.count).to eq(3)
        expect(posts[0].url).to eq("/path/#{@files[0]}")
        expect(posts[0].tag).to eq("image1")
        expect(posts[0].agent).to eq(Agent.first)
        expect(posts[1].url).to eq("/path/#{@files[1]}")
        expect(posts[1].tag).to eq("image2")
        expect(posts[1].agent).to eq(Agent.first)
        expect(posts[2].url).to eq("/path/#{@files[2]}")
        expect(posts[2].tag).to eq("image3")
        expect(posts[2].agent).to eq(Agent.first)
      end
    end

    context 'agent registered' do
      before :each do
        @agent = create(:agent)
      end

      it 'adds agent to the database' do
        expect(Agent.count).to eq(1)
        subject.execute({ email: @agent.email, path: './public/path/' })
        expect(Agent.count).to eq(1)
        expect(Agent.first.posts.count).to eq(3)
      end

      it 'adds three posts to the database' do
        expect(Post.count).to eq(0)
        subject.execute({ email: @agent.email, path: './public/path/' })
        posts = Post.all
        expect(posts.count).to eq(3)
        expect(posts[0].url).to eq("/path/#{@files[0]}")
        expect(posts[0].tag).to eq("image1")
        expect(posts[0].agent).to eq(@agent)
        expect(posts[1].url).to eq("/path/#{@files[1]}")
        expect(posts[1].tag).to eq("image2")
        expect(posts[1].agent).to eq(@agent)
        expect(posts[2].url).to eq("/path/#{@files[2]}")
        expect(posts[2].tag).to eq("image3")
        expect(posts[2].agent).to eq(@agent)
      end
    end
  end

  #
  # 2017-5-29
  # Just keeping this here as a reference
  #
  context 'fantaskspec features' do
    it "executes some code" do
      expect(subject.execute).to eq(task.execute)
    end
  
    it "uses 'post:images' as the name of the task" do
      expect(task_name).to eq("post:images")
      expect(task_name).to eq(subject.name)
    end
  end
end
